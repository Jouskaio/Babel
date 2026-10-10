"""Importing a reading history from a CSV export (Goodreads, StoryGraph, Babelio).

Columns are found by name, in English or French; every book becomes a paper book (no file)
with its status, dates and rating, or is skipped when the library already has that title.
"""

import csv
import io
import unicodedata
from dataclasses import dataclass
from datetime import UTC, datetime
from uuid import UUID

from babel_api.domain.errors import UnsupportedFileError
from babel_api.domain.files import ReadingState, ReadingStatus
from babel_api.domain.social import Audience
from babel_api.services.files import FileService
from babel_api.services.social import SocialService

MAX_ROWS = 5000

_COLUMNS = {
    "title": {"title", "titre"},
    "authors": {"author", "authors", "auteur", "auteurs"},
    "status": {"exclusive shelf", "read status", "statut", "status", "etagere", "shelf"},
    "rating": {"my rating", "star rating", "ma note", "note", "rating"},
    "read": {"date read", "last date read", "date de lecture", "date lu", "date de fin"},
    "review": {"my review", "review", "critique", "avis", "mon avis"},
}
_STATUS = {
    ReadingStatus.FINISHED: {"read", "lu", "finished", "termine"},
    ReadingStatus.READING: {"currently-reading", "currently reading", "reading", "en cours"},
    ReadingStatus.TO_READ: {"to-read", "to read", "want to read", "a lire", "wishlist"},
    ReadingStatus.ABANDONED: {"did-not-finish", "dnf", "abandonne", "paused"},
}
_DATES = ("%Y/%m/%d", "%Y-%m-%d", "%d/%m/%Y", "%d-%m-%Y", "%m/%d/%Y")


@dataclass(frozen=True, slots=True)
class ImportResult:
    imported: int
    skipped: int  # already in the library
    failed: int  # no title


def _plain(text: str) -> str:
    decomposed = unicodedata.normalize("NFKD", text.strip().lower())
    return "".join(c for c in decomposed if not unicodedata.combining(c))


def _date(value: str) -> datetime | None:
    for fmt in _DATES:
        try:
            return datetime.strptime(value.strip()[:10], fmt).replace(tzinfo=UTC)
        except ValueError:
            continue
    return None


def _rating(value: str) -> int | None:
    try:
        stars = round(float(value.replace(",", ".")))
    except ValueError:
        return None
    return stars if 1 <= stars <= 5 else None  # 0 means "not rated"


@dataclass(frozen=True, slots=True)
class ImportRow:
    """A book of a reading history, from any source."""

    title: str
    authors: tuple[str, ...]
    status: ReadingStatus | None
    finished: datetime | None
    rating: int | None  # 1 to 5
    review: str | None


class ImportService:
    def __init__(self, files: FileService, social: SocialService) -> None:
        self._files = files
        self._social = social

    async def import_csv(
        self, user_id: UUID, content: bytes, device_id: UUID | None = None
    ) -> ImportResult:
        try:
            text = content.decode("utf-8-sig")
        except UnicodeDecodeError:
            text = content.decode("latin-1")
        head = text.splitlines()[0] if text.strip() else ""
        delimiter = max(",;\t", key=head.count)
        reader = csv.reader(io.StringIO(text), delimiter=delimiter)
        header = [_plain(h) for h in next(reader, list[str]())]
        index = {
            key: next((i for i, h in enumerate(header) if h in names), None)
            for key, names in _COLUMNS.items()
        }
        if index["title"] is None:
            raise UnsupportedFileError  # not a reading list we know

        def cell(row: list[str], key: str) -> str:
            i = index[key]
            return row[i].strip() if i is not None and i < len(row) else ""

        rows: list[ImportRow] = []
        failed = 0
        for row in list(reader)[:MAX_ROWS]:
            title = cell(row, "title")
            if not title:
                failed += 1
                continue
            status = next(
                (s for s, names in _STATUS.items() if _plain(cell(row, "status")) in names),
                ReadingStatus.FINISHED if cell(row, "read") else None,
            )
            authors = tuple(
                a.strip() for a in cell(row, "authors").replace(";", ",").split(",") if a.strip()
            )
            rows.append(
                ImportRow(
                    title,
                    authors,
                    status,
                    _date(cell(row, "read")) if status is ReadingStatus.FINISHED else None,
                    _rating(cell(row, "rating")),
                    cell(row, "review") or None,
                )
            )
        result = await self.import_rows(user_id, rows, device_id)
        return ImportResult(result.imported, result.skipped, failed)

    async def import_rows(
        self, user_id: UUID, rows: list[ImportRow], device_id: UUID | None = None
    ) -> ImportResult:
        """Adds each book as a paper book with its status, dates and (private) rating and review;
        books whose title the library already has are skipped."""
        known = {_plain(i.title) for i in await self._files.library(user_id)}
        imported = skipped = 0
        for row in rows:
            if _plain(row.title) in known:
                skipped += 1
                continue
            known.add(_plain(row.title))
            item = await self._files.add_imported(
                user_id,
                row.title,
                row.authors,
                ReadingState(
                    status=row.status,
                    client_time=datetime.now(UTC),
                    started_at=row.finished,
                    finished_at=row.finished,
                ),
                device_id,
            )
            if row.rating or row.review:
                await self._social.save_review(
                    user_id, item.id, rating=row.rating, text=row.review, audience=Audience.PRIVATE
                )
            imported += 1
        return ImportResult(imported, skipped, 0)
