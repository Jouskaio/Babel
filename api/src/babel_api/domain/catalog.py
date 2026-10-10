"""Catalog entities exposed to clients."""

from dataclasses import dataclass
from datetime import datetime
from enum import StrEnum
from uuid import UUID


@dataclass(frozen=True, slots=True)
class TrendingWork:
    """A popular work, as shown on the landing page and in discovery."""

    work_id: str
    title: str
    authors: tuple[str, ...]
    cover_id: int
    first_publish_year: int | None = None


@dataclass(frozen=True, slots=True)
class CoverImage:
    """A cover image, ready to be served."""

    content: bytes
    media_type: str


class IdentifierKind(StrEnum):
    """Identifier schemes of an edition."""

    ISBN13 = "isbn13"
    ISBN10 = "isbn10"
    OPEN_LIBRARY = "open_library"
    GOOGLE_BOOKS = "google_books"
    ASIN = "asin"


@dataclass(frozen=True, slots=True)
class Identifier:
    kind: IdentifierKind
    value: str


@dataclass(frozen=True, slots=True)
class Edition:
    """A published form of a work: translation, paperback, ebook, audiobook…"""

    id: UUID
    work_id: UUID
    title: str
    language: str | None = None
    publisher: str | None = None
    published: str | None = None
    page_count: int | None = None
    format: str | None = None
    cover_id: int | None = None
    identifiers: tuple[Identifier, ...] = ()
    # Every cover the catalog has for this edition (the first is ``cover_id``).
    cover_ids: tuple[int, ...] = ()
    description: str | None = None

    def identifier(self, kind: IdentifierKind) -> list[str]:
        return [i.value for i in self.identifiers if i.kind is kind]


@dataclass(frozen=True, slots=True)
class Work:
    """A book independently of its editions (see ADR 0007)."""

    id: UUID
    title: str
    authors: tuple[str, ...] = ()
    first_publish_year: int | None = None
    cover_id: int | None = None
    description: str | None = None
    open_library_id: str | None = None
    edition_count: int | None = None
    editions_synced_at: datetime | None = None
    # Free subjects from the catalog ("Science fiction", "Governesses -- Fiction"…).
    subjects: tuple[str, ...] = ()
    # Where a cover found outside Open Library lives (Hardcover), and the readers' rating.
    cover_url: str | None = None
    rating: float | None = None


# ------------------------------------------------------------------ external records
@dataclass(frozen=True, slots=True)
class SourceWork:
    """A work as described by an external catalog."""

    open_library_id: str
    title: str
    authors: tuple[str, ...] = ()
    first_publish_year: int | None = None
    cover_id: int | None = None
    description: str | None = None
    edition_count: int | None = None
    # Best edition in the requested language, when the search asked for one.
    localized_title: str | None = None
    localized_cover_id: int | None = None
    subjects: tuple[str, ...] = ()


@dataclass(frozen=True, slots=True)
class SourceEdition:
    """An edition as described by an external catalog."""

    open_library_id: str
    work_open_library_id: str
    title: str
    language: str | None = None
    publisher: str | None = None
    published: str | None = None
    page_count: int | None = None
    format: str | None = None
    cover_id: int | None = None
    isbn13: tuple[str, ...] = ()
    isbn10: tuple[str, ...] = ()
    cover_ids: tuple[int, ...] = ()
    description: str | None = None
