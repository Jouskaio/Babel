"""User-defined sources of book files (ADR 0009)."""

from dataclasses import dataclass, field
from datetime import datetime
from enum import StrEnum
from typing import Any
from uuid import UUID


class SourceKind(StrEnum):
    """Implemented connectors. OPDS, WebDAV, fanfiction and generic will join this list."""

    GITHUB = "github"


class EntryStatus(StrEnum):
    NEW = "new"  # never imported by anyone: Babel downloads it from the source
    ON_BABEL = "on_babel"  # already stored: added without downloading it again
    IN_LIBRARY = "in_library"  # already in this reader's library


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


@dataclass(frozen=True, slots=True)
class RemoteEntry:
    """A book file found in a source."""

    path: str
    size: int
    # Identifies the content on the source side (the git blob SHA for GitHub).
    remote_id: str

    @property
    def name(self) -> str:
        return self.path.rsplit("/", 1)[-1]


@dataclass(frozen=True, slots=True)
class SourceEntry:
    id: UUID
    source_id: UUID
    path: str
    size: int
    remote_id: str
    status: EntryStatus = EntryStatus.NEW
    item_id: UUID | None = None

    @property
    def name(self) -> str:
        return self.path.rsplit("/", 1)[-1]


@dataclass(frozen=True, slots=True)
class SourceDetail:
    source: Source
    entries: list[SourceEntry] = field(default_factory=list[SourceEntry])
