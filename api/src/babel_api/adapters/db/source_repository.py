"""SQLAlchemy implementation of the source repository."""

from datetime import UTC, datetime
from typing import Any
from uuid import UUID

from sqlalchemy import delete, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from babel_api.adapters.db.models import (
    DisabledConnectorRow,
    KnownSourceFileRow,
    SourceEntryRow,
    SourceQuotaRow,
    SourceRow,
    UserRow,
)
from babel_api.domain.sources import EntryStatus, RemoteEntry, Source, SourceEntry, SourceKind


def _aware(value: datetime | None) -> datetime | None:
    if value is None:
        return None
    return value if value.tzinfo else value.replace(tzinfo=UTC)


def _to_source(row: SourceRow, entry_count: int = 0) -> Source:
    return Source(
        id=row.id,
        user_id=row.user_id,
        kind=SourceKind(row.kind),
        name=row.name,
        config=dict(row.config or {}),
        has_credentials=row.encrypted_token is not None,
        created_at=_aware(row.created_at) or datetime.now(UTC),
        last_scan_at=_aware(row.last_scan_at),
        last_error=row.last_error,
        entry_count=entry_count,
    )


class SqlSourceRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def add(
        self,
        user_id: UUID,
        kind: SourceKind,
        name: str,
        config: dict[str, Any],
        encrypted_token: str | None,
    ) -> Source:
        row = SourceRow(
            user_id=user_id,
            kind=kind.value,
            name=name,
            config=config,
            encrypted_token=encrypted_token,
        )
        self._session.add(row)
        await self._session.flush()
        return _to_source(row)

    async def get(self, source_id: UUID) -> Source | None:
        row = await self._session.get(SourceRow, source_id)
        return _to_source(row) if row else None

    async def encrypted_token(self, source_id: UUID) -> str | None:
        row = await self._session.get(SourceRow, source_id)
        return row.encrypted_token if row else None

    async def list_sources(self, user_id: UUID) -> list[Source]:
        rows = (
            await self._session.scalars(
                select(SourceRow).where(SourceRow.user_id == user_id).order_by(SourceRow.created_at)
            )
        ).all()
        result = await self._session.execute(
            select(SourceEntryRow.source_id, func.count())
            .join(SourceRow, SourceRow.id == SourceEntryRow.source_id)
            .where(SourceRow.user_id == user_id)
            .group_by(SourceEntryRow.source_id)
        )
        counts: dict[UUID, int] = {source_id: count for source_id, count in result}
        return [_to_source(row, counts.get(row.id, 0)) for row in rows]

    async def count(self, user_id: UUID) -> int:
        total = await self._session.scalar(
            select(func.count()).select_from(SourceRow).where(SourceRow.user_id == user_id)
        )
        return int(total or 0)

    async def quota(self, user_id: UUID) -> int | None:
        row = await self._session.get(SourceQuotaRow, user_id)
        return row.max_sources if row else None

    async def set_quota(self, user_id: UUID, max_sources: int | None) -> None:
        row = await self._session.get(SourceQuotaRow, user_id)
        if max_sources is None:
            if row:
                await self._session.delete(row)
        elif row:
            row.max_sources = max_sources
        else:
            self._session.add(SourceQuotaRow(user_id=user_id, max_sources=max_sources))

    async def disabled_kinds(self) -> set[str]:
        return set(await self._session.scalars(select(DisabledConnectorRow.kind)))

    async def set_disabled(self, kind: SourceKind, disabled: bool) -> None:
        row = await self._session.get(DisabledConnectorRow, kind.value)
        if disabled and row is None:
            self._session.add(DisabledConnectorRow(kind=kind.value))
        elif not disabled and row is not None:
            await self._session.delete(row)

    async def all_sources(self) -> list[tuple[str, Source]]:
        """Every source with its owner's email, for the administrator's health view."""
        result = await self._session.execute(
            select(SourceRow, UserRow.email)
            .join(UserRow, UserRow.id == SourceRow.user_id)
            .order_by(SourceRow.created_at)
        )
        counts = {
            sid: n
            for sid, n in await self._session.execute(
                select(SourceEntryRow.source_id, func.count()).group_by(SourceEntryRow.source_id)
            )
        }
        return [(email, _to_source(row, counts.get(row.id, 0))) for row, email in result]

    async def delete(self, source_id: UUID) -> None:
        # Explicit: SQLite does not enforce ON DELETE CASCADE by default.
        await self._session.execute(
            delete(SourceEntryRow).where(SourceEntryRow.source_id == source_id)
        )
        await self._session.execute(delete(SourceRow).where(SourceRow.id == source_id))

    async def record_scan(
        self, source_id: UUID, entries: list[RemoteEntry], at: datetime, error: str | None
    ) -> None:
        row = await self._session.get_one(SourceRow, source_id)
        row.last_scan_at = at
        row.last_error = error
        if error is None:
            existing = {
                e.path: e
                for e in await self._session.scalars(
                    select(SourceEntryRow).where(SourceEntryRow.source_id == source_id)
                )
            }
            found = {e.path: e for e in entries}
            for path, stale in existing.items():
                if path not in found:
                    await self._session.delete(stale)
            for path, entry in found.items():
                current = existing.get(path)
                if current is None:
                    current = SourceEntryRow(
                        source_id=source_id, path=path, size=entry.size, remote_id=entry.remote_id
                    )
                    self._session.add(current)
                elif current.remote_id != entry.remote_id:
                    # New content: worth trying again even if the old one was unreadable.
                    current.size, current.remote_id = entry.size, entry.remote_id
                    current.unreadable = False
                current.title = entry.title[:500] if entry.title else None
                current.authors = list(entry.authors[:5])
                current.locator = entry.locator
                current.format = entry.format
        await self._session.flush()

    async def entries(self, source_id: UUID) -> list[SourceEntry]:
        rows = await self._session.scalars(
            select(SourceEntryRow)
            .where(SourceEntryRow.source_id == source_id)
            .order_by(func.coalesce(SourceEntryRow.title, SourceEntryRow.path))
        )
        return [
            SourceEntry(
                id=row.id,
                source_id=row.source_id,
                path=row.path,
                size=row.size,
                remote_id=row.remote_id,
                status=EntryStatus.UNREADABLE if row.unreadable else EntryStatus.NEW,
                title=row.title,
                authors=tuple(row.authors or ()),
                locator=row.locator,
                format=row.format,
            )
            for row in rows
        ]

    async def get_entry(self, entry_id: UUID) -> SourceEntry | None:
        row = await self._session.get(SourceEntryRow, entry_id)
        if row is None:
            return None
        return SourceEntry(
            id=row.id,
            source_id=row.source_id,
            path=row.path,
            size=row.size,
            remote_id=row.remote_id,
            status=EntryStatus.UNREADABLE if row.unreadable else EntryStatus.NEW,
            title=row.title,
            authors=tuple(row.authors or ()),
            locator=row.locator,
            format=row.format,
        )

    async def mark_unreadable(self, entry_id: UUID) -> None:
        row = await self._session.get_one(SourceEntryRow, entry_id)
        row.unreadable = True

    async def known_file(self, kind: str, remote_id: str) -> str | None:
        row = await self._session.get(KnownSourceFileRow, (str(kind), remote_id))
        return row.sha256 if row else None

    async def remember_file(self, kind: str, remote_id: str, sha256: str) -> None:
        if await self._session.get(KnownSourceFileRow, (str(kind), remote_id)) is None:
            self._session.add(
                KnownSourceFileRow(kind=str(kind), remote_id=remote_id, sha256=sha256)
            )
            await self._session.flush()

    async def commit(self) -> None:
        await self._session.commit()
