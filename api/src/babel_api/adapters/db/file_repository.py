"""SQLAlchemy implementation of the file repository."""

from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from babel_api.adapters.db.models import (
    BlockedFileRow,
    FollowRow,
    LibraryItemRow,
    ReadingPositionRow,
    ShelfItemRow,
    StoredFileRow,
)
from babel_api.domain.files import (
    BookFormat,
    LibraryItem,
    ReadingState,
    ReadingStatus,
    StoredFile,
)


def _aware(value: datetime) -> datetime:
    return value if value.tzinfo else value.replace(tzinfo=UTC)


def _to_file(row: StoredFileRow) -> StoredFile:
    return StoredFile(
        sha256=row.sha256,
        size=row.size,
        format=BookFormat(row.format),
        original_name=row.original_name,
        created_at=_aware(row.created_at),
        edition_id=row.edition_id,
        uploaded_by=row.uploaded_by,
        withdrawn_at=_aware(row.withdrawn_at) if row.withdrawn_at else None,
        title=row.title,
        authors=tuple(row.authors or ()),
    )


def _maybe(value: datetime | None) -> datetime | None:
    return _aware(value) if value else None


def _to_item(row: LibraryItemRow) -> LibraryItem:
    return LibraryItem(
        id=row.id,
        user_id=row.user_id,
        file=_to_file(row.file),
        title=row.title,
        authors=tuple(row.authors or ()),
        added_at=_aware(row.added_at),
        state=ReadingState(
            status=ReadingStatus(row.status) if row.status else None,
            progress=row.progress,
            client_time=_maybe(row.state_time),
            started_at=_maybe(row.started_at),
            finished_at=_maybe(row.finished_at),
        ),
    )


class SqlFileRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def get_file(self, sha256: str) -> StoredFile | None:
        row = await self._session.get(StoredFileRow, sha256)
        return _to_file(row) if row else None

    async def add_file(self, file: StoredFile) -> None:
        self._session.add(
            StoredFileRow(
                sha256=file.sha256,
                size=file.size,
                format=file.format.value,
                original_name=file.original_name,
                edition_id=file.edition_id,
                uploaded_by=file.uploaded_by,
                created_at=file.created_at,
                title=file.title,
                authors=list(file.authors),
            )
        )
        await self._session.flush()

    async def withdraw_file(self, sha256: str, at: datetime) -> None:
        row = await self._session.get(StoredFileRow, sha256)
        if row is not None:
            row.withdrawn_at = at
            await self._session.flush()

    async def reinstate_file(self, sha256: str, uploaded_by: UUID) -> None:
        row = await self._session.get_one(StoredFileRow, sha256)
        row.withdrawn_at = None
        row.uploaded_by = uploaded_by
        await self._session.flush()

    async def is_blocked(self, sha256: str) -> bool:
        return await self._session.get(BlockedFileRow, sha256) is not None

    async def block(self, sha256: str, reason: str, by: UUID | None, at: datetime) -> None:
        if await self._session.get(BlockedFileRow, sha256) is None:
            self._session.add(
                BlockedFileRow(sha256=sha256, reason=reason, blocked_by=by, blocked_at=at)
            )
            await self._session.flush()

    async def add_item(
        self, user_id: UUID, sha256: str, title: str, authors: tuple[str, ...]
    ) -> LibraryItem:
        row = LibraryItemRow(
            user_id=user_id, file_sha256=sha256, title=title[:500], authors=list(authors)
        )
        self._session.add(row)
        await self._session.flush()
        await self._session.refresh(row, ["file"])
        return _to_item(row)

    async def find_item(self, user_id: UUID, sha256: str) -> LibraryItem | None:
        row = await self._session.scalar(
            select(LibraryItemRow).where(
                LibraryItemRow.user_id == user_id, LibraryItemRow.file_sha256 == sha256
            )
        )
        return _to_item(row) if row else None

    async def get_item(self, item_id: UUID) -> LibraryItem | None:
        row = await self._session.get(LibraryItemRow, item_id)
        return _to_item(row) if row else None

    async def list_items(self, user_id: UUID) -> list[LibraryItem]:
        rows = await self._session.scalars(
            select(LibraryItemRow)
            .join(StoredFileRow)
            .where(LibraryItemRow.user_id == user_id, StoredFileRow.withdrawn_at.is_(None))
            .order_by(LibraryItemRow.added_at.desc())
        )
        return [_to_item(row) for row in rows]

    async def save_state(self, item_id: UUID, state: ReadingState) -> LibraryItem:
        row = await self._session.get_one(LibraryItemRow, item_id)
        row.status = state.status.value if state.status else None
        row.progress = state.progress
        row.state_time = state.client_time
        row.started_at = state.started_at
        row.finished_at = state.finished_at
        await self._session.flush()
        return _to_item(row)

    async def delete_item(self, item_id: UUID) -> None:
        await self._session.execute(
            delete(ReadingPositionRow).where(ReadingPositionRow.item_id == item_id)
        )
        await self._session.execute(delete(ShelfItemRow).where(ShelfItemRow.item_id == item_id))
        await self._session.execute(delete(FollowRow).where(FollowRow.item_id == item_id))
        await self._session.execute(delete(LibraryItemRow).where(LibraryItemRow.id == item_id))

    async def replace_item_file(
        self, item_id: UUID, sha256: str, title: str, authors: tuple[str, ...]
    ) -> LibraryItem:
        row = await self._session.get_one(LibraryItemRow, item_id)
        row.file_sha256 = sha256
        row.title = title[:500]
        row.authors = list(authors)
        await self._session.flush()
        await self._session.refresh(row, ["file"])
        return _to_item(row)

    async def items_of_file(self, sha256: str) -> list[LibraryItem]:
        rows = await self._session.scalars(
            select(LibraryItemRow).where(LibraryItemRow.file_sha256 == sha256)
        )
        return [_to_item(row) for row in rows]

    async def delete_items_of_file(self, sha256: str) -> None:
        items = select(LibraryItemRow.id).where(LibraryItemRow.file_sha256 == sha256)
        await self._session.execute(
            delete(ReadingPositionRow).where(ReadingPositionRow.item_id.in_(items))
        )
        await self._session.execute(delete(ShelfItemRow).where(ShelfItemRow.item_id.in_(items)))
        await self._session.execute(
            delete(LibraryItemRow).where(LibraryItemRow.file_sha256 == sha256)
        )

    async def commit(self) -> None:
        await self._session.commit()
