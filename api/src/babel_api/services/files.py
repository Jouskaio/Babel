"""Importing, downloading and withdrawing book files (ADR 0010)."""

from collections.abc import AsyncIterator
from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path, PurePath
from typing import Any, Literal
from uuid import UUID

from babel_api.domain.catalog import IdentifierKind
from babel_api.domain.errors import (
    BlockedFileError,
    ForbiddenError,
    NotFoundError,
    UnsupportedFileError,
)
from babel_api.domain.files import LibraryItem, StoredFile
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
        "format": item.file.format.value,
        "size": item.file.size,
        "sha256": item.file.sha256,
        "edition_id": str(item.file.edition_id) if item.file.edition_id else None,
        "cover_path": item.file.cover_path,
        "added_at": item.added_at.isoformat(),
    }


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
    ) -> None:
        self._files = files
        self._catalog = catalog
        self._changes = changes
        self._store = store
        self._reader = reader
        self._covers = covers
        self._access = access
        self._max_bytes = max_bytes

    async def import_file(
        self,
        user_id: UUID,
        chunks: AsyncIterator[bytes],
        filename: str,
        device_id: UUID | None = None,
    ) -> ImportResult:
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
            item = await self._files.find_item(user_id, sha256)
            if item is None:
                item = await self._add_item(user_id, existing, path, filename, device_id)
            return ImportResult(item, deduplicated=existing.uploaded_by != user_id)

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
        item = await self._add_item(user_id, stored, path, filename, device_id)
        return ImportResult(item, deduplicated=False)

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

    async def remove_from_library(
        self, user_id: UUID, item_id: UUID, device_id: UUID | None = None
    ) -> None:
        """The file itself stays stored: other readers may have it."""
        item = await self._files.get_item(item_id)
        if item is None or item.user_id != user_id:
            raise NotFoundError
        await self._files.delete_item(item_id)
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
        await self._files.delete_items_of_file(sha256)
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
        metadata = self._reader.metadata(path, file.format)
        title = metadata.title or PurePath(filename).stem or file.original_name
        item = await self._files.add_item(user_id, file.sha256, title, metadata.authors)
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
