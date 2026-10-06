"""Importing a book from a link pasted (or shared) by a reader.

AO3 works become EPUBs through the AO3 connector (so they share its pacing), Project
Gutenberg pages their EPUB, and any other link is downloaded as a file. A version already
imported by anyone is added without downloading it again.
"""

import hashlib
from dataclasses import dataclass
from enum import StrEnum
from typing import Any
from uuid import UUID

from babel_api.adapters.sources.ao3 import Ao3Connector
from babel_api.adapters.sources.links import (
    AO3_WORK,
    GUTENBERG,
    GUTENBERG_BOOK,
    LinkFetcher,
    file_name,
)
from babel_api.domain.errors import UnsupportedLinkError
from babel_api.domain.files import LibraryItem
from babel_api.domain.ports import FileRepository, SourceRepository
from babel_api.domain.sources import RemoteEntry
from babel_api.services.files import FileService, stored_sha
from babel_api.services.follows import FollowService


class LinkKind(StrEnum):
    AO3 = "ao3"
    GUTENBERG = "gutenberg"
    FILE = "file"


@dataclass(frozen=True, slots=True)
class LinkPreview:
    kind: LinkKind
    title: str | None
    authors: tuple[str, ...]
    # Chapters for AO3 works ("12/12", "3/?").
    detail: str | None
    # A version of this book is already on Babel: no download needed.
    on_babel: bool


class LinkService:
    def __init__(
        self,
        library: FileService,
        files: FileRepository,
        known: SourceRepository,
        ao3: Ao3Connector,
        fetcher: LinkFetcher,
        follows: FollowService,
    ) -> None:
        self._library = library
        self._files = files
        self._sources = known
        self._ao3 = ao3
        self._fetcher = fetcher
        self._follows = follows

    async def _resolve(self, url: str) -> tuple[LinkKind, RemoteEntry]:
        url = url.strip()
        if match := AO3_WORK.match(url):
            return LinkKind.AO3, await self._ao3.work(match.group(1))
        if match := GUTENBERG_BOOK.match(url):
            book_id = match.group(1)
            title, authors = await self._fetcher.gutenberg_details(book_id)
            download = f"{GUTENBERG}/ebooks/{book_id}.epub3.images"
            return LinkKind.GUTENBERG, RemoteEntry(
                path=download,
                size=0,
                remote_id=f"gutenberg:{book_id}",
                title=title,
                authors=authors,
                locator=download,
                format="epub",
            )
        if not url.lower().startswith(("http://", "https://")) or len(url) > 2000:
            raise UnsupportedLinkError
        return LinkKind.FILE, RemoteEntry(
            path=url,
            size=0,
            remote_id=hashlib.sha256(url.encode()).hexdigest(),
            title=None,
            locator=url,
        )

    async def _known(self, kind: LinkKind, entry: RemoteEntry) -> str | None:
        sha256 = await self._sources.known_file(kind.value, entry.remote_id)
        stored = await self._files.get_file(sha256) if sha256 else None
        return sha256 if stored is not None and stored.available else None

    async def preview(self, url: str) -> LinkPreview:
        kind, entry = await self._resolve(url)
        detail = entry.remote_id.split(":", 1)[1].split("|")[0] if kind is LinkKind.AO3 else None
        return LinkPreview(
            kind=kind,
            title=entry.title or (file_name(url) if kind is LinkKind.FILE else None),
            authors=entry.authors,
            detail=detail or None,
            on_babel=await self._known(kind, entry) is not None,
        )

    async def import_link(
        self, user_id: UUID, url: str, device_id: UUID | None = None
    ) -> LibraryItem:
        kind, entry = await self._resolve(url)
        if sha256 := await self._known(kind, entry):
            item = await self._library.add_existing(user_id, sha256, device_id)
            await self._follow(kind, item, url, entry)
            return item
        config: dict[str, Any] = {"username": ""}
        chunks = (
            self._ao3.fetch(config, None, entry)
            if kind is LinkKind.AO3
            else self._fetcher.stream(entry.locator or entry.path)
        )
        name = f"{entry.title}.epub" if entry.title else file_name(entry.path)
        result = await self._library.import_file(user_id, chunks, name, device_id)
        await self._sources.remember_file(kind.value, entry.remote_id, stored_sha(result.item))
        await self._sources.commit()
        await self._follow(kind, result.item, url, entry)
        return result.item

    async def _follow(
        self, kind: LinkKind, item: LibraryItem, url: str, entry: RemoteEntry
    ) -> None:
        """Unfinished AO3 works are followed: new chapters arrive by themselves."""
        if kind is LinkKind.AO3:
            await self._follows.follow_ao3(item, entry.path.rsplit("/", 1)[-1], url, entry)
            await self._sources.commit()
