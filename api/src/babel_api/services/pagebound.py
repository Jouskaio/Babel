"""A reader's Pagebound account: their public username, and their reviews brought into Babel.

Nothing private is read and no password is kept: Pagebound's public pages show a reader's
reviews by their username. Importing adds each reviewed book as a paper book (finished) with its
rating and text as a private Babel review; books the library already has are skipped.
"""

import math
from dataclasses import dataclass
from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from babel_api.adapters.db.models import PageboundLinkRow
from babel_api.adapters.pagebound import PageboundClient
from babel_api.domain.errors import NotFoundError
from babel_api.domain.files import ReadingStatus
from babel_api.services.imports import ImportResult, ImportRow, ImportService


@dataclass(frozen=True, slots=True)
class PageboundLink:
    username: str
    linked_at: datetime
    imported_at: datetime | None


def _stars(value: float | None) -> int | None:
    """Pagebound rates by half stars; Babel by whole ones (4.5 reads as 5)."""
    return min(5, math.floor(value + 0.5)) if value else None


def _date(text: str | None) -> datetime | None:
    for fmt in ("%b %d, %Y", "%B %d, %Y"):
        try:
            return datetime.strptime(text or "", fmt).replace(tzinfo=UTC)
        except ValueError:
            continue
    return None


class PageboundService:
    def __init__(
        self, session: AsyncSession, client: PageboundClient, imports: ImportService
    ) -> None:
        self._session = session
        self._client = client
        self._imports = imports

    async def link(self, user_id: UUID, username: str) -> PageboundLink:
        """Keeps a Pagebound username after checking that the reader exists there."""
        name = username.strip().lstrip("@")
        remote = await self._client.user_id(name) if name else None
        if remote is None:
            raise NotFoundError
        row = await self._session.get(PageboundLinkRow, user_id)
        if row is None:
            row = PageboundLinkRow(user_id=user_id)
            self._session.add(row)
        row.username, row.remote_id, row.linked_at = name, remote, datetime.now(UTC)
        await self._session.commit()
        return PageboundLink(name, row.linked_at, row.imported_at)

    async def status(self, user_id: UUID) -> PageboundLink | None:
        row = await self._session.scalar(
            select(PageboundLinkRow).where(PageboundLinkRow.user_id == user_id)
        )
        return PageboundLink(row.username, row.linked_at, row.imported_at) if row else None

    async def unlink(self, user_id: UUID) -> None:
        await self._session.execute(
            delete(PageboundLinkRow).where(PageboundLinkRow.user_id == user_id)
        )
        await self._session.commit()

    async def import_reviews(self, user_id: UUID) -> ImportResult:
        row = await self._session.get(PageboundLinkRow, user_id)
        if row is None:
            raise NotFoundError
        reviews = await self._client.user_reviews(row.remote_id)
        rows = [
            ImportRow(
                r.title,
                r.authors,
                ReadingStatus.FINISHED,
                _date(r.date),
                _stars(r.rating),
                r.text,
            )
            for r in reviews
        ]
        result = await self._imports.import_rows(user_id, rows)
        row.imported_at = datetime.now(UTC)
        await self._session.commit()
        return result
