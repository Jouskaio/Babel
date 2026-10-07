"""Book requests in the database."""

from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from babel_api.adapters.db.models import BookRequestRow
from babel_api.domain.requests import BookRequest, RequestStatus


def _to_request(row: BookRequestRow) -> BookRequest:
    created = row.created_at if row.created_at.tzinfo else row.created_at.replace(tzinfo=UTC)
    return BookRequest(
        id=row.id,
        user_id=row.user_id,
        work_id=row.work_id,
        status=RequestStatus(row.status),
        created_at=created,
        chaptarr_id=row.chaptarr_id,
    )


class SqlRequestRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def get(self, user_id: UUID, work_id: UUID) -> BookRequest | None:
        row = await self._session.scalar(
            select(BookRequestRow).where(
                BookRequestRow.user_id == user_id, BookRequestRow.work_id == work_id
            )
        )
        return _to_request(row) if row else None

    async def list_for(self, user_id: UUID) -> list[BookRequest]:
        rows = await self._session.scalars(
            select(BookRequestRow)
            .where(BookRequestRow.user_id == user_id)
            .order_by(BookRequestRow.created_at.desc())
        )
        return [_to_request(r) for r in rows]

    async def save(
        self, user_id: UUID, work_id: UUID, status: RequestStatus, chaptarr_id: int | None
    ) -> BookRequest:
        """Creates the request, or updates its status."""
        row = await self._session.scalar(
            select(BookRequestRow).where(
                BookRequestRow.user_id == user_id, BookRequestRow.work_id == work_id
            )
        )
        if row is None:
            row = BookRequestRow(
                user_id=user_id,
                work_id=work_id,
                status=status.value,
                chaptarr_id=chaptarr_id,
                created_at=datetime.now(UTC),
            )
            self._session.add(row)
        else:
            row.status = status.value
            row.chaptarr_id = chaptarr_id if chaptarr_id is not None else row.chaptarr_id
        await self._session.flush()
        return _to_request(row)

    async def commit(self) -> None:
        await self._session.commit()
