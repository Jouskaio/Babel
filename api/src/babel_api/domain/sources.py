"""User-defined sources of book files (ADR 0009)."""

from dataclasses import dataclass, field
from datetime import datetime
from enum import StrEnum
from typing import Any
from uuid import UUID


class SourceKind(StrEnum):
    """Implemented connectors."""

    GITHUB = "github"
    OPDS = "opds"  # Calibre-Web, Kavita, Komga, COPS…
    WEBDAV = "webdav"  # Nextcloud, ownCloud, NAS
    AO3 = "ao3"  # Archive of Our Own: bookmarks and subscriptions
    GENERIC = "generic"  # any address serving a Babel source manifest


class EntryStatus(StrEnum):
    NEW = "new"  # never imported by anyone: Babel downloads it from the source
    ON_BABEL = "on_babel"  # already stored: added without downloading it again
    IN_LIBRARY = "in_library"  # already in this reader's library
    UNREADABLE = "unreadable"  # not a book Babel can read; tried again if the file changes


@dataclass(frozen=True, slots=True)
class Source:
    id: UUID
    user_id: UUID
    kind: SourceKind
    name: str
    config: dict[str, Any]
    has_credentials: bool
    created_at: datetime
    last_scan_at: datetime | None = None
    last_error: str | None = None
    # Book files found by the last scan.
    entry_count: int = 0
    # What the last successful scan found new, and what had gone from the source.
    last_added: int = 0
    last_removed: int = 0


@dataclass(frozen=True, slots=True)
class RemoteEntry:
    """A book file found in a source."""

    # Unique within the source; shown to the reader when nothing better is known.
    path: str
    size: int
    # Identifies the content on the source side (the git blob SHA for GitHub, a hash of
    # the URL and version elsewhere): the same id means the same file.
    remote_id: str
    title: str | None = None
    authors: tuple[str, ...] = ()
    # Where the connector fetches the file from, when the path is not enough.
    locator: str | None = None
    # epub, pdf, cbz or cbr when the source says so (from the extension otherwise).
    format: str | None = None

    @property
    def name(self) -> str:
        return self.path.rstrip("/").rsplit("/", 1)[-1]


@dataclass(frozen=True, slots=True)
class SourceEntry:
    id: UUID
    source_id: UUID
    path: str
    size: int
    remote_id: str
    status: EntryStatus = EntryStatus.NEW
    item_id: UUID | None = None
    # Given by the source, or read from the file once it is on Babel.
    title: str | None = None
    authors: tuple[str, ...] = ()
    cover_path: str | None = None
    locator: str | None = None
    format: str | None = None

    @property
    def name(self) -> str:
        return self.path.rstrip("/").rsplit("/", 1)[-1]

    def remote(self) -> RemoteEntry:
        return RemoteEntry(
            path=self.path,
            size=self.size,
            remote_id=self.remote_id,
            title=self.title,
            authors=self.authors,
            locator=self.locator,
            format=self.format,
        )


@dataclass(frozen=True, slots=True)
class SourceDetail:
    source: Source
    entries: list[SourceEntry] = field(default_factory=list[SourceEntry])
