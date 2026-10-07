"""What statistics are computed from: library items, reading activity, notes, reviews."""

from collections.abc import Sequence
from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from babel_api.adapters.db.file_repository import _to_item  # pyright: ignore[reportPrivateUsage]
from babel_api.adapters.db.models import (
    AnnotationRow,
    ChangeRow,
    LibraryItemRow,
    ReviewRow,
    UserRow,
    WorkRow,
)
from babel_api.domain.files import LibraryItem
from babel_api.domain.sync import EntityKind


def _aware(value: datetime) -> datetime:
    return value if value.tzinfo else value.replace(tzinfo=UTC)


class SqlStatsRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def items(self, user_id: UUID) -> list[LibraryItem]:
        """Every book the reader ever had, removed ones included."""
        rows = await self._session.scalars(
            select(LibraryItemRow).where(LibraryItemRow.user_id == user_id)
        )
        return [_to_item(row) for row in rows]

    async def work_subjects(self, work_ids: Sequence[UUID]) -> dict[UUID, tuple[str, ...]]:
        if not work_ids:
            return {}
        rows = await self._session.execute(
            select(WorkRow.id, WorkRow.subjects).where(WorkRow.id.in_(list(work_ids)))
        )
        return {work: tuple(subjects or ()) for work, subjects in rows.all()}

    async def goal(self, user_id: UUID) -> int | None:
        return await self._session.scalar(select(UserRow.reading_goal).where(UserRow.id == user_id))

    async def set_goal(self, user_id: UUID, books: int | None) -> None:
        await self._session.execute(
            update(UserRow).where(UserRow.id == user_id).values(reading_goal=books)
        )
        await self._session.commit()

    async def ratings(self, user_id: UUID) -> dict[UUID, int]:
        rows = await self._session.execute(
            select(ReviewRow.item_id, ReviewRow.rating).where(
                ReviewRow.user_id == user_id, ReviewRow.rating.is_not(None)
            )
        )
        return {item: rating for item, rating in rows.all() if rating is not None}

    async def review_times(self, user_id: UUID) -> Sequence[datetime]:
        rows = await self._session.scalars(
            select(ReviewRow.created_at).where(ReviewRow.user_id == user_id)
        )
        return [_aware(at) for at in rows]

    async def note_times(self, user_id: UUID) -> Sequence[datetime]:
        rows = await self._session.scalars(
            select(AnnotationRow.client_time).where(AnnotationRow.user_id == user_id)
        )
        return [_aware(at) for at in rows]

    async def reading_times(self, user_id: UUID) -> Sequence[datetime]:
        """When the reader's devices recorded reading positions (device clock when known)."""
        rows = await self._session.execute(
            select(ChangeRow.data, ChangeRow.created_at).where(
                ChangeRow.user_id == user_id,
                ChangeRow.entity == EntityKind.READING_POSITION.value,
            )
        )
        times: list[datetime] = []
        for data, created in rows.all():
            raw = data.get("client_time")
            try:
                times.append(_aware(datetime.fromisoformat(str(raw))) if raw else _aware(created))
            except ValueError:
                times.append(_aware(created))
        return times
