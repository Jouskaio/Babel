"""KOReader sync data in the database."""

from dataclasses import dataclass
from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from babel_api.adapters.db.models import (
    DeviceRow,
    KoreaderHashRow,
    KoreaderKeyRow,
    KoreaderProgressRow,
    LibraryItemRow,
    ReadingPositionRow,
)


@dataclass(frozen=True, slots=True)
class KoreaderContact:
    """When KOReader last called, and when it last asked for a book Babel does not have."""

    last_seen_at: datetime | None
    last_unmatched_at: datetime | None


@dataclass(frozen=True, slots=True)
class RecentSync:
    """A book KOReader reported a position for."""

    item_id: UUID
    title: str
    authors: tuple[str, ...]
    percent: float
    at: datetime
    device: str


@dataclass(frozen=True, slots=True)
class OrphanProgress:
    """A position KOReader sent for a book that is not in the reader's library."""

    progress: str
    percentage: float
    device: str
    device_id: str
    at: datetime


def _aware(moment: datetime | None) -> datetime | None:
    return moment.replace(tzinfo=UTC) if moment is not None and moment.tzinfo is None else moment


class SqlKoreaderRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def key(self, user_id: UUID) -> str | None:
        return await self._session.scalar(
            select(KoreaderKeyRow.key).where(KoreaderKeyRow.user_id == user_id)
        )

    async def set_key(self, user_id: UUID, key: str) -> None:
        row = await self._session.get(KoreaderKeyRow, user_id)
        if row is None:
            self._session.add(KoreaderKeyRow(user_id=user_id, key=key))
        else:
            row.key = key
        await self._session.flush()

    async def mark(self, user_id: UUID, *, unmatched: bool = False) -> None:
        """KOReader called (or asked for a book Babel did not know)."""
        row = await self._session.get(KoreaderKeyRow, user_id)
        if row is None:
            return
        now = datetime.now(UTC)
        if unmatched:
            row.last_unmatched_at = now
        else:
            row.last_seen_at = now
        await self._session.flush()

    async def contact(self, user_id: UUID) -> KoreaderContact:
        row = await self._session.get(KoreaderKeyRow, user_id)
        if row is None:
            return KoreaderContact(None, None)
        return KoreaderContact(_aware(row.last_seen_at), _aware(row.last_unmatched_at))

    async def recent(self, user_id: UUID, limit: int = 8) -> list[RecentSync]:
        """The latest positions KOReader sent, newest first."""
        rows = await self._session.execute(
            select(ReadingPositionRow, LibraryItemRow, DeviceRow.name)
            .join(LibraryItemRow, LibraryItemRow.id == ReadingPositionRow.item_id)
            .join(DeviceRow, DeviceRow.id == ReadingPositionRow.device_id)
            .where(
                ReadingPositionRow.user_id == user_id,
                ReadingPositionRow.locator.like("koreader:%"),
                LibraryItemRow.removed_at.is_(None),
            )
            .order_by(ReadingPositionRow.client_time.desc())
            .limit(limit)
        )
        return [
            RecentSync(
                item.id,
                item.title,
                tuple(item.authors or ()),
                position.percent,
                _aware(position.client_time) or datetime.now(UTC),
                device,
            )
            for position, item, device in rows.all()
        ]

    async def put_orphan(
        self,
        user_id: UUID,
        document: str,
        progress: str,
        percentage: float,
        device: str,
        device_id: str,
    ) -> None:
        row = await self._session.get(KoreaderProgressRow, (user_id, document))
        if row is None:
            row = KoreaderProgressRow(user_id=user_id, document=document)
            self._session.add(row)
        row.progress = progress[:1000]
        row.percentage = percentage
        row.device = device[:80]
        row.device_id = device_id[:80]
        row.updated_at = datetime.now(UTC)
        await self._session.flush()

    async def get_orphan(self, user_id: UUID, document: str) -> OrphanProgress | None:
        row = await self._session.get(KoreaderProgressRow, (user_id, document))
        if row is None:
            return None
        return OrphanProgress(
            row.progress,
            row.percentage,
            row.device,
            row.device_id,
            _aware(row.updated_at) or datetime.now(UTC),
        )

    async def orphan_count(self, user_id: UUID) -> int:
        return int(
            await self._session.scalar(
                select(func.count())
                .select_from(KoreaderProgressRow)
                .where(KoreaderProgressRow.user_id == user_id)
            )
            or 0
        )

    async def hashes(self, shas: list[str]) -> dict[str, str]:
        """md5 -> sha256 for the files whose identifier is known."""
        if not shas:
            return {}
        rows = await self._session.execute(
            select(KoreaderHashRow.md5, KoreaderHashRow.sha256).where(
                KoreaderHashRow.sha256.in_(shas)
            )
        )
        return {md5: sha for md5, sha in rows.all()}

    async def save_hash(self, sha256: str, md5: str) -> None:
        if await self._session.get(KoreaderHashRow, sha256) is None:
            self._session.add(KoreaderHashRow(sha256=sha256, md5=md5))
            await self._session.flush()

    async def commit(self) -> None:
        await self._session.commit()
