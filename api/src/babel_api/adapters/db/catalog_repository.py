"""SQLAlchemy implementation of the catalog repository."""

from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from babel_api.adapters.db.models import EditionIdentifierRow, EditionRow, WorkRow
from babel_api.domain.catalog import (
    Edition,
    Identifier,
    IdentifierKind,
    SourceEdition,
    SourceWork,
    Work,
)


def _aware(value: datetime | None) -> datetime | None:
    if value is None:
        return None
    return value if value.tzinfo else value.replace(tzinfo=UTC)


def _to_work(row: WorkRow) -> Work:
    return Work(
        id=row.id,
        title=row.title,
        authors=tuple(row.authors or ()),
        first_publish_year=row.first_publish_year,
        cover_id=row.cover_id,
        description=row.description,
        open_library_id=row.open_library_id,
        edition_count=row.edition_count,
        editions_synced_at=_aware(row.editions_synced_at),
    )


def _to_edition(row: EditionRow) -> Edition:
    return Edition(
        id=row.id,
        work_id=row.work_id,
        title=row.title,
        language=row.language,
        publisher=row.publisher,
        published=row.published,
        page_count=row.page_count,
        format=row.format,
        cover_id=row.cover_id,
        identifiers=tuple(
            Identifier(IdentifierKind(i.kind), i.value)
            for i in sorted(row.identifiers, key=lambda i: (i.kind, i.value))
        ),
    )


class SqlCatalogRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def upsert_work(self, work: SourceWork) -> Work:
        """Insert or refresh a work; fields unknown to the source keep their stored value."""
        row = await self._session.scalar(
            select(WorkRow).where(WorkRow.open_library_id == work.open_library_id)
        )
        if row is None:
            row = WorkRow(open_library_id=work.open_library_id, title=work.title, authors=[])
            self._session.add(row)
        row.title = work.title or row.title
        if work.authors:
            row.authors = list(work.authors)
        row.first_publish_year = work.first_publish_year or row.first_publish_year
        row.cover_id = work.cover_id or row.cover_id
        row.description = work.description or row.description
        row.edition_count = work.edition_count or row.edition_count
        row.updated_at = datetime.now(UTC)
        await self._session.flush()
        return _to_work(row)

    async def get_work(self, work_id: UUID) -> Work | None:
        row = await self._session.get(WorkRow, work_id)
        return _to_work(row) if row else None

    async def get_work_by_open_library_id(self, open_library_id: str) -> Work | None:
        row = await self._session.scalar(
            select(WorkRow).where(WorkRow.open_library_id == open_library_id)
        )
        return _to_work(row) if row else None

    async def upsert_editions(self, work_id: UUID, editions: list[SourceEdition]) -> None:
        for source in editions:
            row = await self._session.scalar(
                select(EditionRow).where(EditionRow.open_library_id == source.open_library_id)
            )
            if row is None:
                # An empty collection up front: lazy loading is not possible with asyncio.
                row = EditionRow(
                    open_library_id=source.open_library_id,
                    work_id=work_id,
                    title="",
                    identifiers=[],
                )
                self._session.add(row)
            row.work_id = work_id
            row.title = source.title or row.title
            row.language = source.language
            row.publisher = source.publisher
            row.published = source.published
            row.page_count = source.page_count
            row.format = source.format
            row.cover_id = source.cover_id
            await self._session.flush()
            wanted = {(IdentifierKind.OPEN_LIBRARY.value, source.open_library_id)}
            wanted |= {(IdentifierKind.ISBN13.value, i) for i in source.isbn13}
            wanted |= {(IdentifierKind.ISBN10.value, i) for i in source.isbn10}
            have = {(i.kind, i.value) for i in row.identifiers}
            for kind, value in wanted - have:
                # An identifier already claimed by another edition stays there.
                taken = await self._session.scalar(
                    select(EditionIdentifierRow.id).where(
                        EditionIdentifierRow.kind == kind, EditionIdentifierRow.value == value
                    )
                )
                if taken is None:
                    row.identifiers.append(EditionIdentifierRow(kind=kind, value=value))
            await self._session.flush()

    async def list_editions(self, work_id: UUID) -> list[Edition]:
        rows = await self._session.scalars(
            select(EditionRow).where(EditionRow.work_id == work_id).order_by(EditionRow.title)
        )
        return [_to_edition(row) for row in rows]

    async def find_edition(self, kind: IdentifierKind, value: str) -> Edition | None:
        row = await self._session.scalar(
            select(EditionRow)
            .join(EditionIdentifierRow)
            .where(EditionIdentifierRow.kind == kind.value, EditionIdentifierRow.value == value)
        )
        return _to_edition(row) if row else None

    async def mark_editions_synced(self, work_id: UUID, at: datetime) -> None:
        row = await self._session.get_one(WorkRow, work_id)
        row.editions_synced_at = at
        await self._session.flush()

    async def commit(self) -> None:
        await self._session.commit()
