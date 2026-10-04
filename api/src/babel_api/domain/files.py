"""Book files and the reader's library (ADR 0010)."""

from dataclasses import dataclass
from datetime import datetime
from enum import StrEnum
from uuid import UUID


class BookFormat(StrEnum):
    """File formats accepted for import, detected from the content, not the name."""

    EPUB = "epub"
    PDF = "pdf"
    CBZ = "cbz"
    CBR = "cbr"

    @property
    def media_type(self) -> str:
        return {
            BookFormat.EPUB: "application/epub+zip",
            BookFormat.PDF: "application/pdf",
            BookFormat.CBZ: "application/vnd.comicbook+zip",
            BookFormat.CBR: "application/vnd.comicbook-rar",
        }[self]


@dataclass(frozen=True, slots=True)
class BookMetadata:
    """What could be read from the file itself (EPUB package metadata)."""

    title: str | None = None
    authors: tuple[str, ...] = ()
    isbn13: str | None = None
    language: str | None = None


@dataclass(frozen=True, slots=True)
class StoredFile:
    """A file kept once in the store, whoever imported it."""

    sha256: str
    size: int
    format: BookFormat
    original_name: str
    created_at: datetime
    edition_id: UUID | None = None
    uploaded_by: UUID | None = None
    withdrawn_at: datetime | None = None

    @property
    def available(self) -> bool:
        return self.withdrawn_at is None


@dataclass(frozen=True, slots=True)
class LibraryItem:
    """A book in a reader's library, backed by a stored file."""

    id: UUID
    user_id: UUID
    file: StoredFile
    title: str
    authors: tuple[str, ...]
    added_at: datetime
