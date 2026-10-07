"""SQLAlchemy implementation of the file repository."""

import re
from datetime import UTC, datetime
from typing import Any
from uuid import UUID

from sqlalchemy import delete, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from babel_api.adapters.db.models import (
    BlockedFileRow,
    EditionRow,
    FollowRow,
    LibraryItemRow,
    ShelfItemRow,
    StoredFileRow,
    WorkRow,
)
from babel_api.domain.files import (
    AudioRef,
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
        subjects=tuple(row.subjects) if row.subjects is not None else None,
    )


def _plain(text: str) -> str:
    """Lowercase words only, accents kept: "Jane  Eyre!" and "jane eyre" compare equal."""
    return " ".join(re.findall(r"\w+", text.lower()))


def _maybe(value: datetime | None) -> datetime | None:
    return _aware(value) if value else None


def _to_item(row: LibraryItemRow) -> LibraryItem:
    return LibraryItem(
        id=row.id,
        user_id=row.user_id,
        file=_to_file(row.file) if row.file else None,
        title=row.title,
        authors=tuple(row.authors or ()),
        added_at=_aware(row.added_at),
        state=ReadingState(
            status=ReadingStatus(row.status) if row.status else None,
            progress=row.progress,
            client_time=_maybe(row.state_time),
            started_at=_maybe(row.started_at),
            finished_at=_maybe(row.finished_at),
            hidden=row.hidden,
        ),
        removed_at=_maybe(row.removed_at),
        work_id=row.work_id,
        paper=row.paper,
        work_cover_id=row.work.cover_id if row.work else None,
        audio=AudioRef(row.audio_id, row.audio_duration or 0, row.audio_cover)
        if row.audio_id
        else None,
        series=row.series,
        series_index=row.series_index,
        cover_id=row.cover_id,
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
                subjects=list(file.subjects) if file.subjects is not None else None,
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

    async def set_subjects(self, sha256: str, subjects: tuple[str, ...]) -> None:
        row = await self._session.get(StoredFileRow, sha256)
        if row is not None:
            row.subjects = list(subjects)
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
        self,
        user_id: UUID,
        sha256: str | None,
        title: str,
        authors: tuple[str, ...],
        work_id: UUID | None = None,
        paper: bool = False,
        series: str | None = None,
        series_index: float | None = None,
    ) -> LibraryItem:
        row = LibraryItemRow(
            user_id=user_id,
            file_sha256=sha256,
            title=title[:500],
            authors=list(authors),
            work_id=work_id,
            paper=paper,
            series=series[:200] if series else None,
            series_index=series_index,
        )
        self._session.add(row)
        await self._session.flush()
        await self._session.refresh(row, ["file", "work"])
        return _to_item(row)

    async def find_audio_item(self, user_id: UUID, remote_id: str) -> LibraryItem | None:
        """The reader's audiobook of this Audiobookshelf item, removed ones included."""
        row = await self._session.scalar(
            select(LibraryItemRow)
            .where(LibraryItemRow.user_id == user_id, LibraryItemRow.audio_id == remote_id)
            .limit(1)
        )
        return _to_item(row) if row else None

    async def add_audio_item(
        self,
        user_id: UUID,
        title: str,
        authors: tuple[str, ...],
        audio: AudioRef,
        work_id: UUID | None,
        series: str | None = None,
        series_index: float | None = None,
    ) -> LibraryItem:
        row = LibraryItemRow(
            user_id=user_id,
            file_sha256=None,
            title=title[:500],
            authors=list(authors),
            work_id=work_id,
            audio_id=audio.remote_id,
            audio_duration=audio.duration,
            audio_cover=audio.cover,
            series=series[:200] if series else None,
            series_index=series_index,
        )
        self._session.add(row)
        await self._session.flush()
        await self._session.refresh(row, ["file", "work"])
        return _to_item(row)

    async def find_item_of_work(self, user_id: UUID, work_id: UUID) -> LibraryItem | None:
        """The reader's book of this work, removed ones included (the latest)."""
        row = await self._session.scalar(
            select(LibraryItemRow)
            .where(LibraryItemRow.user_id == user_id, LibraryItemRow.work_id == work_id)
            .order_by(LibraryItemRow.removed_at.is_not(None), LibraryItemRow.added_at.desc())
            .limit(1)
        )
        return _to_item(row) if row else None

    async def update_details(self, item_id: UUID, changes: dict[str, Any]) -> LibraryItem:
        """Sets the given fields of a book (title, authors, series, series_index, cover_id)."""
        row = await self._session.get_one(LibraryItemRow, item_id)
        for field, value in changes.items():
            setattr(row, field, value)
        await self._session.flush()
        await self._session.refresh(row, ["file", "work"])
        return _to_item(row)

    async def set_file(self, item_id: UUID, sha256: str) -> LibraryItem:
        row = await self._session.get_one(LibraryItemRow, item_id)
        row.file_sha256 = sha256
        await self._session.flush()
        await self._session.refresh(row, ["file", "work"])
        return _to_item(row)

    async def clear_file(self, item_id: UUID) -> None:
        row = await self._session.get_one(LibraryItemRow, item_id)
        row.file_sha256 = None
        await self._session.flush()

    async def set_paper(self, item_id: UUID, paper: bool) -> LibraryItem:
        row = await self._session.get_one(LibraryItemRow, item_id)
        row.paper = paper
        await self._session.flush()
        return _to_item(row)

    async def find_item(
        self, user_id: UUID, sha256: str, *, removed: bool = False
    ) -> LibraryItem | None:
        """The reader's book for this file; with [removed], also one they took out."""
        query = select(LibraryItemRow).where(
            LibraryItemRow.user_id == user_id, LibraryItemRow.file_sha256 == sha256
        )
        if not removed:
            query = query.where(LibraryItemRow.removed_at.is_(None))
        row = await self._session.scalar(query)
        return _to_item(row) if row else None

    async def get_item(self, item_id: UUID) -> LibraryItem | None:
        """A book in a library (not one its reader removed)."""
        row = await self._session.get(LibraryItemRow, item_id)
        return _to_item(row) if row and row.removed_at is None else None

    async def all_items(self, user_id: UUID) -> list[LibraryItem]:
        """Every book the reader ever had, removed ones included, latest first."""
        rows = await self._session.scalars(
            select(LibraryItemRow)
            .where(LibraryItemRow.user_id == user_id)
            .order_by(LibraryItemRow.added_at.desc())
        )
        return [_to_item(row) for row in rows]

    async def list_items(self, user_id: UUID) -> list[LibraryItem]:
        rows = await self._session.scalars(
            select(LibraryItemRow)
            .join(StoredFileRow)
            .where(
                LibraryItemRow.user_id == user_id,
                LibraryItemRow.removed_at.is_(None),
                StoredFileRow.withdrawn_at.is_(None),
            )
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
        row.hidden = state.hidden
        await self._session.flush()
        return _to_item(row)

    async def set_work(self, item_id: UUID, work_id: UUID | None) -> LibraryItem:
        row = await self._session.get_one(LibraryItemRow, item_id)
        row.work_id = work_id
        await self._session.flush()
        await self._session.refresh(row, ["work"])
        return _to_item(row)

    async def guess_work(
        self, edition_id: UUID | None, title: str, authors: tuple[str, ...]
    ) -> UUID | None:
        """The work of the file's edition, else a known work with the same title and author."""
        if edition_id is not None:
            edition = await self._session.get(EditionRow, edition_id)
            if edition is not None:
                return edition.work_id
        wanted = _plain(title)
        if not wanted:
            return None
        candidates = await self._session.scalars(
            select(WorkRow).where(func.lower(WorkRow.title) == title.strip().lower()).limit(20)
        )
        names = {_plain(a) for a in authors}
        for work in candidates:
            if _plain(work.title) != wanted:
                continue
            # Same title is not enough when both sides name authors: one must match.
            if not names or not work.authors or names & {_plain(a) for a in work.authors}:
                return work.id
        return None

    async def remove_item(self, item_id: UUID, at: datetime) -> None:
        """Out of the library, off its shelves, no longer followed; its data is kept."""
        await self._session.execute(delete(FollowRow).where(FollowRow.item_id == item_id))
        await self._session.execute(delete(ShelfItemRow).where(ShelfItemRow.item_id == item_id))
        row = await self._session.get_one(LibraryItemRow, item_id)
        row.removed_at = at
        await self._session.flush()

    async def restore_item(self, item_id: UUID, at: datetime) -> LibraryItem:
        row = await self._session.get_one(LibraryItemRow, item_id)
        row.removed_at = None
        row.added_at = at
        await self._session.flush()
        return _to_item(row)

    async def replace_item_file(
        self, item_id: UUID, sha256: str, title: str, authors: tuple[str, ...]
    ) -> LibraryItem:
        row = await self._session.get_one(LibraryItemRow, item_id)
        row.file_sha256 = sha256
        row.title = title[:500]
        row.authors = list(authors)
        await self._session.flush()
        await self._session.refresh(row, ["file", "work"])
        return _to_item(row)

    async def items_of_file(self, sha256: str) -> list[LibraryItem]:
        rows = await self._session.scalars(
            select(LibraryItemRow).where(LibraryItemRow.file_sha256 == sha256)
        )
        return [_to_item(row) for row in rows]

    async def remove_items_of_file(self, sha256: str, at: datetime) -> None:
        for item in await self.items_of_file(sha256):
            if item.removed_at is None:
                await self.remove_item(item.id, at)

    async def commit(self) -> None:
        await self._session.commit()
