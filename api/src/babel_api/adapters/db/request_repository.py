"""Book requests in the database."""

from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from babel_api.adapters.db.models import BookRequestRow, ChaptarrLinkRow, ShelfmarkLinkRow
from babel_api.domain.requests import BookRequest, ChaptarrLink, RequestStatus

_LINKS = {"chaptarr": ChaptarrLinkRow, "shelfmark": ShelfmarkLinkRow}


def _to_request(row: BookRequestRow) -> BookRequest:
    created = row.created_at if row.created_at.tzinfo else row.created_at.replace(tzinfo=UTC)
    return BookRequest(
        id=row.id,
        user_id=row.user_id,
        work_id=row.work_id,
        status=RequestStatus(row.status),
        created_at=created,
        chaptarr_id=row.chaptarr_id,
        language=row.language,
        alt_chaptarr_id=row.alt_chaptarr_id,
        shelfmark_ref=row.shelfmark_ref,
    )


class SqlRequestRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def get(self, user_id: UUID, work_id: UUID, language: str = "") -> BookRequest | None:
        row = await self._session.scalar(
            select(BookRequestRow).where(
                BookRequestRow.user_id == user_id,
                BookRequestRow.work_id == work_id,
                BookRequestRow.language == language,
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
        self,
        user_id: UUID,
        work_id: UUID,
        status: RequestStatus,
        chaptarr_id: int | None,
        language: str = "",
        alt_chaptarr_id: int | None = None,
        shelfmark_ref: str | None = None,
    ) -> BookRequest:
        """Creates the request, or updates its status."""
        row = await self._session.scalar(
            select(BookRequestRow).where(
                BookRequestRow.user_id == user_id,
                BookRequestRow.work_id == work_id,
                BookRequestRow.language == language,
            )
        )
        if row is None:
            row = BookRequestRow(
                user_id=user_id,
                work_id=work_id,
                status=status.value,
                chaptarr_id=chaptarr_id,
                language=language,
                alt_chaptarr_id=alt_chaptarr_id,
                shelfmark_ref=shelfmark_ref,
                created_at=datetime.now(UTC),
            )
            self._session.add(row)
        else:
            row.status = status.value
            row.chaptarr_id = chaptarr_id if chaptarr_id is not None else row.chaptarr_id
            row.alt_chaptarr_id = alt_chaptarr_id or row.alt_chaptarr_id
            row.shelfmark_ref = shelfmark_ref or row.shelfmark_ref
        await self._session.flush()
        return _to_request(row)

    async def delete(self, user_id: UUID, work_id: UUID, language: str = "") -> None:
        await self._session.execute(
            delete(BookRequestRow).where(
                BookRequestRow.user_id == user_id,
                BookRequestRow.work_id == work_id,
                BookRequestRow.language == language,
            )
        )

    async def link(self, user_id: UUID, kind: str = "chaptarr") -> ChaptarrLink | None:
        """The reader's own Chaptarr (or Shelfmark, by [kind])."""
        row = await self._session.get(_LINKS[kind], user_id)
        if row is None:
            return None
        updated = row.updated_at if row.updated_at.tzinfo else row.updated_at.replace(tzinfo=UTC)
        return ChaptarrLink(row.user_id, row.base_url, row.secret, updated)

    async def save_link(self, link: ChaptarrLink, kind: str = "chaptarr") -> None:
        row = await self._session.get(_LINKS[kind], link.user_id)
        if row is None:
            row = _LINKS[kind](user_id=link.user_id)
            self._session.add(row)
        row.base_url, row.secret, row.updated_at = link.base_url, link.secret, link.updated_at
        await self._session.flush()

    async def delete_link(self, user_id: UUID, kind: str = "chaptarr") -> None:
        await self._session.execute(delete(_LINKS[kind]).where(_LINKS[kind].user_id == user_id))

    async def commit(self) -> None:
        await self._session.commit()
