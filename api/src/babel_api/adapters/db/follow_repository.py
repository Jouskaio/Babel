"""Followed works (new chapters checked daily)."""

from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import delete, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from babel_api.adapters.db.models import FollowRow
from babel_api.domain.follows import Follow


def _aware(value: datetime | None) -> datetime | None:
    return value.replace(tzinfo=UTC) if value and value.tzinfo is None else value


def _to_follow(row: FollowRow) -> Follow:
    return Follow(
        id=row.id,
        user_id=row.user_id,
        item_id=row.item_id,
        kind=row.kind,
        ref=row.ref,
        url=row.url,
        version=row.version,
        chapters=row.chapters,
        complete=row.complete,
        created_at=_aware(row.created_at) or datetime.now(UTC),
        last_checked_at=_aware(row.last_checked_at),
        last_error=row.last_error,
        updated_at=_aware(row.updated_at),
    )


class SqlFollowRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def save(self, follow: Follow) -> Follow:
        """Adds the follow, or updates the one of the same library item."""
        row = await self._session.scalar(
            select(FollowRow).where(FollowRow.item_id == follow.item_id)
        )
        if row is None:
            row = FollowRow(id=follow.id, user_id=follow.user_id, item_id=follow.item_id)
            self._session.add(row)
        row.kind, row.ref, row.url = follow.kind, follow.ref, follow.url[:2000]
        row.version, row.chapters, row.complete = follow.version, follow.chapters, follow.complete
        row.last_checked_at, row.last_error = follow.last_checked_at, follow.last_error
        row.updated_at = follow.updated_at
        await self._session.flush()
        return _to_follow(row)

    async def get(self, follow_id: UUID) -> Follow | None:
        row = await self._session.get(FollowRow, follow_id)
        return _to_follow(row) if row else None

    async def list_follows(self, user_id: UUID) -> list[Follow]:
        rows = await self._session.scalars(
            select(FollowRow).where(FollowRow.user_id == user_id).order_by(FollowRow.created_at)
        )
        return [_to_follow(row) for row in rows]

    async def due(self, checked_before: datetime, limit: int) -> list[Follow]:
        """Unfinished works not checked since ``checked_before``, the oldest first."""
        rows = await self._session.scalars(
            select(FollowRow)
            .where(
                FollowRow.complete.is_(False),
                or_(
                    FollowRow.last_checked_at.is_(None),
                    FollowRow.last_checked_at < checked_before,
                ),
            )
            .order_by(FollowRow.last_checked_at.nulls_first())
            .limit(limit)
        )
        return [_to_follow(row) for row in rows]

    async def delete(self, follow_id: UUID) -> None:
        await self._session.execute(delete(FollowRow).where(FollowRow.id == follow_id))

    async def commit(self) -> None:
        await self._session.commit()
