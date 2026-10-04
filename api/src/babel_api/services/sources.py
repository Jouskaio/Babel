"""Sources of book files: connecting, scanning and importing (ADR 0009)."""

import logging
from dataclasses import dataclass, replace
from datetime import UTC, datetime
from typing import Any
from uuid import UUID

from babel_api.adapters.security.secrets import SecretBox
from babel_api.domain.errors import (
    DomainError,
    NotFoundError,
    SourceConnectionError,
    TooManySourcesError,
    UnsupportedFileError,
)
from babel_api.domain.files import LibraryItem
from babel_api.domain.ports import FileRepository, SourceConnector, SourceRepository
from babel_api.domain.sources import (
    EntryStatus,
    Source,
    SourceDetail,
    SourceEntry,
    SourceKind,
)
from babel_api.services.files import FileService

logger = logging.getLogger(__name__)

# At most this many books per "import all" call, to keep requests short.
IMPORT_BATCH = 50


@dataclass(frozen=True, slots=True)
class BatchImport:
    imported: int
    failed: int


class SourceService:
    def __init__(
        self,
        sources: SourceRepository,
        files: FileRepository,
        library: FileService,
        connectors: dict[SourceKind, SourceConnector],
        secrets: SecretBox,
        *,
        max_sources: int,
    ) -> None:
        self._sources = sources
        self._files = files
        self._library = library
        self._connectors = connectors
        self._secrets = secrets
        self._max_sources = max_sources

    # ------------------------------------------------------------ sources
    async def create(
        self,
        user_id: UUID,
        kind: SourceKind,
        name: str,
        config: dict[str, Any],
        token: str | None,
    ) -> SourceDetail:
        if await self._sources.count(user_id) >= self._max_sources:
            raise TooManySourcesError
        token = (token or "").strip() or None
        encrypted = self._secrets.encrypt(token) if token else None
        checked = await self._connectors[kind].check(config, token)
        source = await self._sources.add(user_id, kind, name.strip()[:120], checked, encrypted)
        await self._sources.commit()
        return await self.scan(user_id, source.id)

    async def check(self, kind: SourceKind, config: dict[str, Any], token: str | None) -> int:
        """Tries a source without saving it: the number of books it holds."""
        token = (token or "").strip() or None
        connector = self._connectors[kind]
        return len(await connector.list_entries(await connector.check(config, token), token))

    async def list_sources(self, user_id: UUID) -> list[Source]:
        return await self._sources.list_sources(user_id)

    async def detail(self, user_id: UUID, source_id: UUID) -> SourceDetail:
        source = await self._own(user_id, source_id)
        entries = [
            await self._with_status(user_id, source.kind, e)
            for e in await self._sources.entries(source_id)
        ]
        return SourceDetail(replace(source, entry_count=len(entries)), entries)

    async def delete(
        self,
        user_id: UUID,
        source_id: UUID,
        *,
        remove_books: bool = False,
        device_id: UUID | None = None,
    ) -> int:
        """Forgets the source and its credentials.

        Imported books stay in the library unless ``remove_books``: then the books matching
        the source's files leave the library (the stored files stay, for other readers).
        Returns the number of books removed.
        """
        removed = 0
        if remove_books:
            detail = await self.detail(user_id, source_id)
            item_ids = {e.item_id for e in detail.entries if e.item_id is not None}
            for item_id in item_ids:
                await self._library.remove_from_library(user_id, item_id, device_id)
                removed += 1
        else:
            await self._own(user_id, source_id)
        await self._sources.delete(source_id)
        await self._sources.commit()
        return removed

    async def scan(self, user_id: UUID, source_id: UUID) -> SourceDetail:
        source = await self._own(user_id, source_id)
        now = datetime.now(UTC)
        try:
            found = await self._connectors[source.kind].list_entries(
                source.config, await self._token(source)
            )
            await self._sources.record_scan(source_id, found, now, None)
        except SourceConnectionError as error:
            await self._sources.record_scan(source_id, [], now, f"connection: {error}")
        await self._sources.commit()
        return await self.detail(user_id, source_id)

    # ------------------------------------------------------------ import
    async def import_entry(
        self, user_id: UUID, source_id: UUID, entry_id: UUID, device_id: UUID | None = None
    ) -> LibraryItem:
        source = await self._own(user_id, source_id)
        entry = await self._sources.get_entry(entry_id)
        if entry is None or entry.source_id != source_id:
            raise NotFoundError
        known = await self._sources.known_file(source.kind, entry.remote_id)
        if known is not None:
            stored = await self._files.get_file(known)
            if stored is not None and stored.available:
                # Already on Babel: no download from the source.
                return await self._library.add_existing(user_id, known, device_id)
        chunks = self._connectors[source.kind].fetch(
            source.config, await self._token(source), entry.remote()
        )
        try:
            result = await self._library.import_file(user_id, chunks, entry.name, device_id)
        except UnsupportedFileError:
            await self._sources.mark_unreadable(entry.id)
            await self._sources.commit()
            raise
        await self._sources.remember_file(source.kind, entry.remote_id, result.item.file.sha256)
        await self._sources.commit()
        return result.item

    async def import_new(
        self, user_id: UUID, source_id: UUID, device_id: UUID | None = None
    ) -> BatchImport:
        detail = await self.detail(user_id, source_id)
        pending = [e for e in detail.entries if e.status in (EntryStatus.NEW, EntryStatus.ON_BABEL)]
        imported = failed = 0
        for entry in pending[:IMPORT_BATCH]:
            try:
                await self.import_entry(user_id, source_id, entry.id, device_id)
                imported += 1
            except DomainError as error:
                logger.warning("Import of %s failed: %s", entry.path, type(error).__name__)
                failed += 1
        return BatchImport(imported, failed)

    # ------------------------------------------------------------ internals
    async def _own(self, user_id: UUID, source_id: UUID) -> Source:
        source = await self._sources.get(source_id)
        if source is None or source.user_id != user_id:
            raise NotFoundError
        return source

    async def _token(self, source: Source) -> str | None:
        encrypted = await self._sources.encrypted_token(source.id)
        return self._secrets.decrypt(encrypted) if encrypted else None

    async def _with_status(
        self, user_id: UUID, kind: SourceKind, entry: SourceEntry
    ) -> SourceEntry:
        sha256 = await self._sources.known_file(kind, entry.remote_id)
        stored = await self._files.get_file(sha256) if sha256 else None
        if sha256 is None or stored is None:
            return entry
        known = replace(
            entry,
            title=stored.title or entry.title,
            authors=stored.authors or entry.authors,
            cover_path=stored.cover_path,
        )
        item = await self._files.find_item(user_id, sha256)
        if item is not None:
            return replace(known, status=EntryStatus.IN_LIBRARY, item_id=item.id)
        if stored.available:
            return replace(known, status=EntryStatus.ON_BABEL)
        return entry
