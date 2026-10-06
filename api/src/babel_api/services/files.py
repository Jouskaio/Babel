"""Importing, downloading and withdrawing book files (ADR 0010)."""

from collections.abc import AsyncIterator
from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path, PurePath
from typing import Any, Literal
from uuid import UUID

from babel_api.adapters.files.comics import ComicConverter
from babel_api.domain.catalog import IdentifierKind
from babel_api.domain.errors import (
    BlockedFileError,
    BookAlreadyInLibraryError,
    ForbiddenError,
    NotFoundError,
    UnsupportedFileError,
)
from babel_api.domain.files import BookFormat, LibraryItem, StoredFile
from babel_api.domain.ports import (
    BlobStore,
    CatalogRepository,
    ChangeLog,
    CoverCache,
    FileRepository,
    MetadataReader,
)
from babel_api.domain.sync import ChangeOp, EntityKind

FileAccess = Literal["everyone", "entitled"]


def item_data(item: LibraryItem) -> dict[str, Any]:
    """Library item as written in the change log (same shape as the API response)."""
    return {
        "id": str(item.id),
        "title": item.title,
        "authors": list(item.authors),
        "format": item.file.format.value if item.file else None,
        "size": item.file.size if item.file else None,
        "sha256": item.sha256,
        "edition_id": str(item.file.edition_id) if item.file and item.file.edition_id else None,
        "cover_path": item.cover_path,
        "paper": item.paper,
        "added_at": item.added_at.isoformat(),
        "status": item.state.status.value if item.state.status else None,
        "progress": item.state.progress,
        "state_time": _iso(item.state.client_time),
        "started_at": _iso(item.state.started_at),
        "finished_at": _iso(item.state.finished_at),
        "hidden": item.state.hidden,
        "work_id": str(item.work_id) if item.work_id else None,
    }


def stored_sha(item: LibraryItem) -> str:
    """The file of a book that was just imported (it has one)."""
    if item.sha256 is None:
        raise UnsupportedFileError
    return item.sha256


def _iso(value: datetime | None) -> str | None:
    return value.isoformat() if value else None


@dataclass(frozen=True, slots=True)
class ImportResult:
    item: LibraryItem
    # True when the same file was already stored: nothing new was written.
    deduplicated: bool


@dataclass(frozen=True, slots=True)
class Download:
    file: StoredFile
    path: Path


class FileService:
    def __init__(
        self,
        files: FileRepository,
        catalog: CatalogRepository,
        changes: ChangeLog,
        store: BlobStore,
        reader: MetadataReader,
        covers: CoverCache,
        *,
        access: FileAccess,
        max_bytes: int,
        comics: ComicConverter | None = None,
    ) -> None:
        self._files = files
        self._catalog = catalog
        self._changes = changes
        self._store = store
        self._reader = reader
        self._covers = covers
        self._access = access
        self._max_bytes = max_bytes
        self._comics = comics

    async def import_file(
        self,
        user_id: UUID,
        chunks: AsyncIterator[bytes],
        filename: str,
        device_id: UUID | None = None,
    ) -> ImportResult:
        stored, path, existed = await self.store(user_id, chunks, filename)
        item = await self._files.find_item(user_id, stored.sha256)
        if item is None:
            item = await self._add_item(user_id, stored, path, filename, device_id)
        return ImportResult(item, deduplicated=existed and stored.uploaded_by != user_id)

    async def store(
        self, user_id: UUID, chunks: AsyncIterator[bytes], filename: str
    ) -> tuple[StoredFile, Path, bool]:
        """Keeps a file in the shared store: (the stored file, its path, already there)."""
        sha256, size, path = await self._store.put(chunks, self._max_bytes)
        existing = await self._files.get_file(sha256)
        if await self._files.is_blocked(sha256):
            # A blocked file has no available copy: the bytes just written must not stay.
            if existing is None or not existing.available:
                await self._store.delete(sha256)
            raise BlockedFileError
        if existing is not None:
            if not existing.available:
                # Withdrawn without being blocked: importing it again makes it available.
                await self._files.reinstate_file(sha256, user_id)
                existing = await self._files.get_file(sha256) or existing
            return existing, path, True

        file_format = self._reader.detect(path)
        if file_format is None:
            await self._store.delete(sha256)
            raise UnsupportedFileError
        metadata = self._reader.metadata(path, file_format)
        edition = (
            await self._catalog.find_edition(IdentifierKind.ISBN13, metadata.isbn13)
            if metadata.isbn13
            else None
        )
        stored = StoredFile(
            sha256=sha256,
            size=size,
            format=file_format,
            original_name=PurePath(filename).name[:255] or f"{sha256}.{file_format.value}",
            created_at=datetime.now(UTC),
            edition_id=edition.id if edition else None,
            uploaded_by=user_id,
            title=metadata.title,
            authors=metadata.authors,
        )
        await self._files.add_file(stored)
        return stored, path, False

    async def replace_file(
        self, item: LibraryItem, stored: StoredFile, path: Path, device_id: UUID | None = None
    ) -> LibraryItem:
        """A new version of a book (new chapters): same library item, new file."""
        metadata = self._reader.metadata(path, stored.format)
        updated = await self._files.replace_item_file(
            item.id, stored.sha256, metadata.title or item.title, metadata.authors or item.authors
        )
        await self._changes.record(
            item.user_id,
            EntityKind.LIBRARY_ITEM,
            str(item.id),
            ChangeOp.UPSERT,
            item_data(updated),
            device_id,
        )
        return updated

    async def library(self, user_id: UUID) -> list[LibraryItem]:
        return await self._files.list_items(user_id)

    async def add_existing(
        self, user_id: UUID, sha256: str, device_id: UUID | None = None
    ) -> LibraryItem:
        """Add a file already on Babel to the library, without uploading it again."""
        file = await self._files.get_file(sha256)
        path = self._store.path(sha256)
        if file is None or not file.available or path is None:
            raise NotFoundError
        await self._check_access(user_id, file)
        item = await self._files.find_item(user_id, sha256)
        return item or await self._add_item(user_id, file, path, file.original_name, device_id)

    async def add_paper(
        self, user_id: UUID, work_id: UUID, device_id: UUID | None = None
    ) -> LibraryItem:
        """A book the reader owns on paper, from its catalog work. The same book when they
        already have (or had) it: it is marked as owned on paper and comes back."""
        work = await self._catalog.get_work(work_id)
        if work is None:
            raise NotFoundError
        item = await self._files.find_item_of_work(user_id, work_id)
        if item is None:
            item = await self._files.add_item(
                user_id, None, work.title, tuple(work.authors), work_id, paper=True
            )
        else:
            if item.removed_at is not None:
                item = await self._files.restore_item(item.id, datetime.now(UTC))
            item = await self._files.set_paper(item.id, True)
        await self._record(item, device_id)
        return item

    async def set_paper(
        self, user_id: UUID, item_id: UUID, paper: bool, device_id: UUID | None = None
    ) -> LibraryItem:
        """Whether the reader owns the book on paper. A paper book without a file that is
        no longer owned on paper leaves the library (its data stays)."""
        item = await self._own(user_id, item_id)
        if not paper and item.file is None:
            await self.remove_from_library(user_id, item_id, device_id)
            return item
        item = await self._files.set_paper(item_id, paper)
        await self._record(item, device_id)
        return item

    async def attach_file(
        self,
        user_id: UUID,
        item_id: UUID,
        chunks: AsyncIterator[bytes],
        filename: str,
        device_id: UUID | None = None,
    ) -> LibraryItem:
        """Gives a book (a paper one, say) a file, to read it on devices too. Status,
        progress, review and notes stay the book's."""
        item = await self._own(user_id, item_id)
        stored, _, _ = await self.store(user_id, chunks, filename)
        if item.sha256 == stored.sha256:
            return item
        other = await self._files.find_item(user_id, stored.sha256, removed=True)
        if other is not None and other.id != item_id:
            if other.removed_at is None:
                raise BookAlreadyInLibraryError
            # A removed book had this file: it keeps its data, the file moves here.
            await self._files.clear_file(other.id)
        updated = await self._files.set_file(item_id, stored.sha256)
        if updated.work_id is None and stored.edition_id is not None:
            work = await self._files.guess_work(stored.edition_id, updated.title, ())
            if work is not None:
                updated = await self._files.set_work(item_id, work)
        await self._record(updated, device_id)
        return updated

    async def _own(self, user_id: UUID, item_id: UUID) -> LibraryItem:
        item = await self._files.get_item(item_id)
        if item is None or item.user_id != user_id:
            raise NotFoundError
        return item

    async def _record(self, item: LibraryItem, device_id: UUID | None) -> None:
        await self._changes.record(
            item.user_id,
            EntityKind.LIBRARY_ITEM,
            str(item.id),
            ChangeOp.UPSERT,
            item_data(item),
            device_id,
        )
        await self._files.commit()

    async def link_work(
        self, user_id: UUID, item_id: UUID, work_id: UUID | None, device_id: UUID | None = None
    ) -> LibraryItem:
        """The reader says which catalog work a book is (or that it is none)."""
        item = await self._files.get_item(item_id)
        if item is None or item.user_id != user_id:
            raise NotFoundError
        if work_id is not None and await self._catalog.get_work(work_id) is None:
            raise NotFoundError
        updated = await self._files.set_work(item_id, work_id)
        await self._changes.record(
            user_id,
            EntityKind.LIBRARY_ITEM,
            str(item_id),
            ChangeOp.UPSERT,
            item_data(updated),
            device_id,
        )
        await self._files.commit()
        return updated

    async def remove_from_library(
        self, user_id: UUID, item_id: UUID, device_id: UUID | None = None
    ) -> None:
        """Takes a book out of the library. The file stays stored (other readers may have
        it) and so does everything about the book: status, review, notes, positions. Adding
        the same file again brings it all back."""
        item = await self._files.get_item(item_id)
        if item is None or item.user_id != user_id:
            raise NotFoundError
        await self._files.remove_item(item_id, datetime.now(UTC))
        await self._changes.record(
            user_id, EntityKind.LIBRARY_ITEM, str(item_id), ChangeOp.DELETE, device_id=device_id
        )
        await self._files.commit()

    async def cover(self, sha256: str) -> tuple[Path, str]:
        """The cover found in a stored file, extracted once then cached."""
        file = await self._files.get_file(sha256)
        path = self._store.path(sha256)
        if file is None or not file.available or path is None or file.cover_path is None:
            raise NotFoundError
        cached = self._covers.get(sha256)
        if cached is False:
            raise NotFoundError
        if cached is None:
            cached = self._covers.put(sha256, self._reader.cover(path, file.format))
        if cached is None:
            raise NotFoundError
        return cached

    async def download(self, user_id: UUID, sha256: str) -> Download:
        file = await self._files.get_file(sha256)
        path = self._store.path(sha256)
        if file is None or not file.available or path is None:
            raise NotFoundError
        await self._check_access(user_id, file)
        return Download(file, path)

    async def as_cbz(self, user_id: UUID, sha256: str) -> Download:
        """A comic as CBZ, so every device can read it: CBR files are converted once."""
        download = await self.download(user_id, sha256)
        if download.file.format is BookFormat.CBZ:
            return download
        if download.file.format is not BookFormat.CBR or self._comics is None:
            raise UnsupportedFileError
        return Download(download.file, await self._comics.cbz(sha256, download.path))

    async def withdraw(self, admin_id: UUID, sha256: str, reason: str, *, block: bool) -> None:
        """Remove a file from every library and delete its bytes; optionally block its hash."""
        file = await self._files.get_file(sha256)
        if file is None:
            raise NotFoundError
        now = datetime.now(UTC)
        await self._files.withdraw_file(sha256, now)
        for item in await self._files.items_of_file(sha256):
            await self._changes.record(
                item.user_id, EntityKind.LIBRARY_ITEM, str(item.id), ChangeOp.DELETE
            )
        await self._files.remove_items_of_file(sha256, now)
        if block:
            await self._files.block(sha256, reason, admin_id, now)
        await self._files.commit()
        await self._store.delete(sha256)

    # ------------------------------------------------------------ internals
    async def _check_access(self, user_id: UUID, file: StoredFile) -> None:
        if self._access == "everyone":
            return
        if await self._files.find_item(user_id, file.sha256) is None:
            raise ForbiddenError

    async def _add_item(
        self,
        user_id: UUID,
        file: StoredFile,
        path: Path,
        filename: str,
        device_id: UUID | None,
    ) -> LibraryItem:
        removed = await self._files.find_item(user_id, file.sha256, removed=True)
        if removed is not None:
            # Back in the library with everything it had.
            item = await self._files.restore_item(removed.id, datetime.now(UTC))
        else:
            metadata = self._reader.metadata(path, file.format)
            title = metadata.title or PurePath(filename).stem or file.original_name
            work = await self._files.guess_work(file.edition_id, title, metadata.authors)
            item = await self._files.add_item(user_id, file.sha256, title, metadata.authors, work)
        await self._changes.record(
            user_id,
            EntityKind.LIBRARY_ITEM,
            str(item.id),
            ChangeOp.UPSERT,
            item_data(item),
            device_id,
        )
        await self._files.commit()
        return item
