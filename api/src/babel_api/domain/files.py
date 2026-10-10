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
    subjects: tuple[str, ...] = ()
    # The series the file says it belongs to, and its volume number.
    series: str | None = None
    series_index: float | None = None


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
    # From the file itself; None until read (files stored before subjects were kept).
    subjects: tuple[str, ...] | None = None

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
class AudioRef:
    """Where an audiobook lives: an item of the reader's Audiobookshelf."""

    remote_id: str
    duration: float
    cover: str | None = None  # key of the cover kept by Babel


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
    # Where the work's cover was found when Open Library had none (served by Babel).
    work_cover_url: str | None = None
    # An audiobook of the reader's Audiobookshelf, streamed through Babel.
    audio: "AudioRef | None" = None
    # The series the book belongs to and its volume number (from the file, a guess from the
    # title, or the reader's own); and a cover the reader chose from the catalog's.
    series: str | None = None
    series_index: float | None = None
    cover_id: int | None = None
    # A picture the reader uploaded as the cover (key of the image kept by Babel).
    custom_cover: str | None = None

    @property
    def sha256(self) -> str | None:
        return self.file.sha256 if self.file else None

    @property
    def format_name(self) -> str:
        """The file's format, "audio" for an audiobook, or "paper" for a paper book."""
        if self.file:
            return self.file.format.value
        return "audio" if self.audio else "paper"

    @property
    def cover_path(self) -> str | None:
        if self.custom_cover:
            return f"/v1/audio-covers/{self.custom_cover}"
        if self.cover_id:
            return f"/v1/catalog/covers/{self.cover_id}/M"
        if self.file and self.file.cover_path:
            return self.file.cover_path
        if self.audio and self.audio.cover:
            return f"/v1/audio-covers/{self.audio.cover}"
        if self.work_cover_id:
            return f"/v1/catalog/covers/{self.work_cover_id}/M"
        if self.work_cover_url and self.work_id:
            return f"/v1/catalog/work-covers/{self.work_id}"
        return None
