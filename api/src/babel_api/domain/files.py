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
    # Read from the file itself when it was first imported.
    title: str | None = None
    authors: tuple[str, ...] = ()

    @property
    def available(self) -> bool:
        return self.withdrawn_at is None

    @property
    def cover_path(self) -> str | None:
        """Where the API serves the cover found in the file (it may still have none)."""
        if self.format in (BookFormat.EPUB, BookFormat.CBZ):
            return f"/v1/files/{self.sha256}/cover"
        return None


@dataclass(frozen=True, slots=True)
class Cover:
    """A cover image read from a book file."""

    content: bytes
    media_type: str


class ReadingStatus(StrEnum):
    """Where a reader is with a book, set by hand or followed from the reading position."""

    TO_READ = "to_read"
    READING = "reading"
    FINISHED = "finished"
    ABANDONED = "abandoned"


@dataclass(frozen=True, slots=True)
class ReadingState:
    """A reader's status and declared progress for a book.

    ``progress`` is a percentage given by hand (a book read elsewhere, on paper…); the
    reading positions of the devices stay separate. ``client_time`` orders concurrent
    edits: the latest one wins.
    """

    status: ReadingStatus | None = None
    progress: float | None = None
    client_time: datetime | None = None
    started_at: datetime | None = None
    finished_at: datetime | None = None
    # Kept but out of sight: the library hides it unless asked, other readers never see it.
    hidden: bool = False


@dataclass(frozen=True, slots=True)
class LibraryItem:
    """A book in a reader's library: a stored file, a paper copy, or both."""

    id: UUID
    user_id: UUID
    file: StoredFile | None
    title: str
    authors: tuple[str, ...]
    added_at: datetime
    state: ReadingState = ReadingState()
    # Taken out of the library by its reader. The book's data stays (status, review,
    # notes, positions) and comes back if the same file is added again.
    removed_at: datetime | None = None
    # The catalog work this book is an edition of: reviews and shared notes are gathered
    # per work, whatever the edition or file. Found from the ISBN or the title, or chosen
    # by the reader.
    work_id: UUID | None = None
    # The reader owns it on paper (with or without a file to read it on devices too).
    paper: bool = False
    # The work's cover, for paper books without a file.
    work_cover_id: int | None = None

    @property
    def sha256(self) -> str | None:
        return self.file.sha256 if self.file else None

    @property
    def format_name(self) -> str:
        """The file's format, or "paper" for a paper book without one."""
        return self.file.format.value if self.file else "paper"

    @property
    def cover_path(self) -> str | None:
        if self.file and self.file.cover_path:
            return self.file.cover_path
        if self.work_cover_id:
            return f"/v1/catalog/covers/{self.work_cover_id}/M"
        return None
