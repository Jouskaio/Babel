"""SQLAlchemy implementation of the source repository."""

from datetime import UTC, datetime
from typing import Any
from uuid import UUID

from sqlalchemy import delete, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from babel_api.adapters.db.models import KnownSourceFileRow, SourceEntryRow, SourceRow
from babel_api.domain.sources import EntryStatus, RemoteEntry, Source, SourceEntry, SourceKind


def _aware(value: datetime | None) -> datetime | None:
    if value is None:
        return None
    return value if value.tzinfo else value.replace(tzinfo=UTC)


def _to_source(row: SourceRow) -> Source:
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
        rows = await self._session.scalars(
            select(SourceRow).where(SourceRow.user_id == user_id).order_by(SourceRow.created_at)
        )
        return [_to_source(row) for row in rows]

    async def count(self, user_id: UUID) -> int:
        total = await self._session.scalar(
            select(func.count()).select_from(SourceRow).where(SourceRow.user_id == user_id)
        )
        return int(total or 0)

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
                    self._session.add(
                        SourceEntryRow(
                            source_id=source_id,
                            path=path,
                            size=entry.size,
                            remote_id=entry.remote_id,
                        )
                    )
                elif current.remote_id != entry.remote_id:
                    # New content: worth trying again even if the old one was unreadable.
                    current.size, current.remote_id = entry.size, entry.remote_id
                    current.unreadable = False
        await self._session.flush()

    async def entries(self, source_id: UUID) -> list[SourceEntry]:
        rows = await self._session.scalars(
            select(SourceEntryRow)
            .where(SourceEntryRow.source_id == source_id)
            .order_by(SourceEntryRow.path)
        )
        return [
            SourceEntry(
                id=row.id,
                source_id=row.source_id,
                path=row.path,
                size=row.size,
                remote_id=row.remote_id,
                status=EntryStatus.UNREADABLE if row.unreadable else EntryStatus.NEW,
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
        )

    async def mark_unreadable(self, entry_id: UUID) -> None:
        row = await self._session.get_one(SourceEntryRow, entry_id)
        row.unreadable = True

    async def known_file(self, kind: SourceKind, remote_id: str) -> str | None:
        row = await self._session.get(KnownSourceFileRow, (kind.value, remote_id))
        return row.sha256 if row else None

    async def remember_file(self, kind: SourceKind, remote_id: str, sha256: str) -> None:
        if await self._session.get(KnownSourceFileRow, (kind.value, remote_id)) is None:
            self._session.add(
                KnownSourceFileRow(kind=kind.value, remote_id=remote_id, sha256=sha256)
            )
            await self._session.flush()

    async def commit(self) -> None:
        await self._session.commit()
