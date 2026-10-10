"""Works, editions and ISBN lookups, cached from external catalogs (ADR 0007)."""

import asyncio
import logging
import re
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta
from urllib.parse import quote
from uuid import UUID

from babel_api.adapters.external_ratings import ExternalRating, ExternalRatings
from babel_api.adapters.hardcover import (
    HardcoverBook,
    HardcoverClient,
    HardcoverReview,
)
from babel_api.adapters.wikidata import Adaptation, WikidataClient
from babel_api.domain.catalog import Edition, IdentifierKind, SourceWork, Work
from babel_api.domain.errors import NotFoundError, SourceUnavailableError
from babel_api.domain.isbn import normalize_isbn
from babel_api.domain.ports import BookSource, CatalogRepository
from babel_api.domain.series import guess_series, series_key, volume_number

logger = logging.getLogger(__name__)

# Editions of a work are fetched again at most this often.
EDITIONS_TTL = timedelta(days=7)
MAX_EDITIONS = 50
# Works asked of the catalog when rebuilding a saga.
MAX_SAGA = 100
# Open Library can take 20 seconds to answer a search; Hardcover answers in about one. The
# search does not wait longer than this for Open Library when Hardcover has answered.
OPEN_LIBRARY_PATIENCE = 6.0
# Works only Hardcover knows are keyed "hc:<id>" in the Open Library id column.
HARDCOVER_PREFIX = "hc:"
# A description this long is a real blurb; shorter ones are completed from Google Books.
FULL_DESCRIPTION = 400
# Editions (one per language) asked about at most, per refresh of a work.
MAX_BLURBS = 4


def _hit_key(title: str, authors: tuple[str, ...]) -> tuple[str, str]:
    """What makes two records the same book: its title without the subtitle, and the surname
    of its first author."""
    name = series_key(re.split(r"[:(]", title)[0])
    surname = series_key(authors[0]).split(" ")[-1] if authors and series_key(authors[0]) else ""
    return name, surname


@dataclass(frozen=True, slots=True)
class SearchHit:
    """A work with its title and cover in the reader's language when one exists."""

    work: Work
    title: str
    cover_id: int | None


@dataclass(frozen=True, slots=True)
class WorkDetail:
    work: Work
    editions: list[Edition]

    def described(self, language: str | None) -> str | None:
        """The fullest description: an edition's in the reader's language when it has one
        (a translated blurb), else the longest of the work's and its editions'."""
        if language:
            local = [
                e.description for e in self.editions if e.language == language and e.description
            ]
            if local:
                best = max(local, key=len)
                # A translated blurb is only worth it if it is not just a line.
                if len(best) >= 120:
                    return best
        candidates = [self.work.description, *(e.description for e in self.editions)]
        return max((c for c in candidates if c), key=len, default=None)

    def localized(self, language: str | None) -> tuple[str, int | None]:
        """Title and cover of the first edition in ``language``, else the work's own."""
        for edition in self.editions:
            if language and edition.language == language and edition.title:
                return edition.title, edition.cover_id or self.work.cover_id
        return self.work.title, self.work.cover_id


@dataclass(frozen=True, slots=True)
class SagaVolume:
    """One volume of a saga, as the catalog knows it."""

    number: float
    work: Work


@dataclass(frozen=True, slots=True)
class IsbnMatch:
    detail: WorkDetail
    edition: Edition


async def _nothing() -> None:
    return None


class WorkService:
    def __init__(
        self,
        repository: CatalogRepository,
        source: BookSource,
        hardcover: HardcoverClient | None = None,
        wikidata: WikidataClient | None = None,
        external: ExternalRatings | None = None,
    ) -> None:
        self._wikidata = wikidata
        self._external = external
        self._repo = repository
        self._source = source
        self._hardcover = hardcover

    async def search(self, query: str, limit: int, language: str | None = None) -> list[SearchHit]:
        """Open Library's matches, completed with Hardcover's. The two are asked together, and
        one being down is no reason to answer nothing: the search fails only when both fail."""
        asked = asyncio.gather(
            self._open_library(query, limit, language),
            self._hardcover_books(query, limit),
            return_exceptions=True,
        )
        found, books = await asked
        error = found if isinstance(found, BaseException) else None
        if error is not None:
            logger.warning("The catalog search failed: %r", error)
        hits: list[SearchHit] = []
        for source in [] if isinstance(found, BaseException) else found:
            work = await self._repo.upsert_work(source)
            hits.append(
                SearchHit(
                    work,
                    source.localized_title or work.title,
                    source.localized_cover_id or work.cover_id,
                )
            )
        hardcover = [] if isinstance(books, BaseException) else books
        hits += await self._add_hardcover(hardcover, limit, hits)
        hits = await self._fill_gaps(hits, hardcover)
        if error is not None and not hits:
            raise SourceUnavailableError from error
        await self._repo.commit()
        return hits

    async def _open_library(self, query: str, limit: int, language: str | None) -> list[SourceWork]:
        # Open Library refuses a query of fewer than 3 characters (422): do not even ask.
        if len(query.strip()) < 3:
            return []
        return await asyncio.wait_for(
            self._source.search(query, limit, language), OPEN_LIBRARY_PATIENCE
        )

    async def other_titles(self, title: str, authors: tuple[str, ...]) -> list[str]:
        """The same book under the titles Hardcover gives it ("Les carnets de l'apothicaire 2"
        is "The Apothecary Diaries 2" there): indexers know books by their English title.
        Only hits by one of the authors; empty when Hardcover is off or does not answer."""
        hits = await self._hardcover_books(f"{title} {authors[0]}" if authors else title, 5)
        surnames = {a.split(" ")[-1].casefold() for a in authors if a.strip()}
        found: list[str] = []
        for hit in hits:
            who = " ".join(hit.authors).casefold()
            if surnames and not any(s in who for s in surnames):
                continue
            guess = guess_series(hit.title)
            if guess is not None:
                base = re.split(r"\s[-–:]\s|\(", guess.series)[0].strip()
                found.append(f"{base} {guess.number:g}")
        return list(dict.fromkeys(found))

    async def _hardcover_books(self, query: str, limit: int) -> list[HardcoverBook]:
        if self._hardcover is None or len(query.strip()) < 2:
            return []
        return await self._hardcover.search_books(query, limit)

    async def _fill_gaps(
        self, hits: list[SearchHit], books: list[HardcoverBook]
    ) -> list[SearchHit]:
        """A result without a cover, genres or rating takes them from Hardcover's match (same
        title and authors), kept on the work so it is asked once."""
        by_key = {_hit_key(b.title, b.authors): b for b in books if b.image or b.genres or b.rating}
        filled: list[SearchHit] = []
        changed = False
        for hit in hits:
            work = hit.work
            book = by_key.get(_hit_key(work.title, work.authors))
            lacks = (
                not (work.cover_id or work.cover_url) or not work.subjects or work.rating is None
            )
            if book is not None and lacks:
                await self._repo.set_work_extras(
                    work.id, book.genres or None, book.image, book.rating
                )
                if book.description and not work.description:
                    await self._repo.set_work_description(work.id, book.description)
                work = await self._repo.get_work(work.id) or work
                changed = True
            filled.append(SearchHit(work, hit.title, hit.cover_id))
        if changed:
            await self._repo.commit()
        return filled

    async def _add_hardcover(
        self, books: list[HardcoverBook], limit: int, hits: list[SearchHit]
    ) -> list[SearchHit]:
        """Open Library lacks many volumes and translations: Hardcover's matches that the
        catalog's do not already hold are added, after them (each becomes a work "hc:<id>")."""
        known = {_hit_key(h.work.title, h.work.authors) for h in hits}
        extra: list[SearchHit] = []
        for book in books:
            if len(hits) + len(extra) >= limit or _hit_key(book.title, book.authors) in known:
                continue
            known.add(_hit_key(book.title, book.authors))
            work = await self._repo.upsert_work(
                SourceWork(
                    open_library_id=f"{HARDCOVER_PREFIX}{book.id}",
                    title=book.title,
                    authors=book.authors,
                    first_publish_year=book.year,
                    description=book.description,
                )
            )
            extra.append(SearchHit(work, work.title, work.cover_id))
        return extra

    async def saga(self, series: str, author: str | None) -> list[SagaVolume]:
        """Every volume of a series the catalog lists, in order.

        Catalogs rarely know series; but each volume of a manga or a numbered saga is a work
        of its own named "Series N". So: search the series name (and author), keep the
        works whose title names the same series and a volume number, one per number.
        """
        key = series_key(series)
        if not key:
            return []
        query = f'title:"{series}"' + (f' author:"{author}"' if author else "")
        try:
            found = await self._source.search(query, MAX_SAGA, None)
        except Exception as error:
            raise SourceUnavailableError from error
        by_number: dict[float, SourceWork] = {}
        for source in found:
            number = volume_number(source.title, series)
            if number is None:
                continue
            kept = by_number.get(number)
            # Several records for one volume (reprints): the one with a cover wins.
            if kept is None or (kept.cover_id is None and source.cover_id is not None):
                by_number[number] = source
        volumes = [
            SagaVolume(number, await self._repo.upsert_work(source))
            for number, source in sorted(by_number.items())
        ]
        await self._repo.commit()
        return volumes

    async def known_volumes(
        self, series: str, author: str | None
    ) -> list[tuple[float, str, int | None]]:
        """Titles of the volumes Hardcover knows for a series (none without its key)."""
        if self._hardcover is None:
            return []
        return await self._hardcover.series_volumes(series, author)

    async def work_from_hardcover(self, hardcover_id: int, title: str, author: str | None) -> Work:
        """A volume only Hardcover knows (the catalog lacks it) as a work of its own, so it can
        be opened, searched in the reader's sources and requested. Its key is "hc:<id>"."""
        work = await self._repo.upsert_work(
            SourceWork(
                open_library_id=f"{HARDCOVER_PREFIX}{hardcover_id}",
                title=title,
                authors=(author,) if author else (),
            )
        )
        await self._repo.commit()
        return work

    async def get(self, work_id: UUID) -> WorkDetail:
        work = await self._repo.get_work(work_id)
        if work is None:
            raise NotFoundError
        if self._needs_sync(work):
            work = await self._sync(work)
        work = await self._enrich(work)
        return WorkDetail(work, await self._repo.list_editions(work.id))

    async def external_reviews(
        self, work_id: UUID
    ) -> tuple[list[ExternalRating], list[HardcoverReview]]:
        """What others think of a book: ratings (Hardcover, Open Library, Goodreads) and the
        most liked Hardcover reviews. Every source is best effort."""
        work = (await self.get(work_id)).work
        ratings: list[ExternalRating] = []
        if work.rating is not None:
            query = quote(f"{work.title} {work.authors[0] if work.authors else ''}".strip())
            ratings.append(
                ExternalRating(
                    "hardcover", work.rating, 0, f"https://hardcover.app/search?q={query}"
                )
            )
        olid = work.open_library_id
        asked = await asyncio.gather(
            self._external.openlibrary(olid)
            if self._external is not None and olid and not olid.startswith(HARDCOVER_PREFIX)
            else _nothing(),
            self._external.goodreads(work.title, work.authors)
            if self._external is not None
            else _nothing(),
            self._hardcover_reviews(work),
            return_exceptions=True,
        )
        for found in asked[:2]:
            if isinstance(found, ExternalRating):
                ratings.append(found)
        reviews = asked[2] if isinstance(asked[2], list) else []
        return ratings, reviews

    async def _hardcover_reviews(self, work: Work) -> list[HardcoverReview]:
        if self._hardcover is None:
            return []
        book_id: int | None = None
        if work.open_library_id and work.open_library_id.startswith(HARDCOVER_PREFIX):
            tail = work.open_library_id[len(HARDCOVER_PREFIX) :]
            book_id = int(tail) if tail.isdigit() else None
        else:
            query = f"{work.title} {work.authors[0]}" if work.authors else work.title
            surnames = {a.split(" ")[-1].casefold() for a in work.authors if a.strip()}
            for hit in await self._hardcover_books(query, 5):
                who = " ".join(hit.authors).casefold()
                if hit.title.casefold() == work.title.casefold() and (
                    not surnames or any(s in who for s in surnames)
                ):
                    book_id = hit.id
                    break
        return await self._hardcover.reviews(book_id) if book_id is not None else []

    async def related(self, work_id: UUID) -> list[Adaptation]:
        """What a book was adapted into (films, series, games, comics): Wikidata finds the work
        by its title (the series name for a volume) and author, TMDB adds posters."""
        detail = await self.get(work_id)
        work = detail.work
        if self._wikidata is None or not work.authors:
            return []
        guess = guess_series(work.title)
        base = re.split(r"\s[-–:]\s|\(", guess.series if guess else work.title)[0].strip()
        titles = [base, *await self.other_titles(work.title, work.authors)]
        titles = [re.sub(r"\s*\d{1,3}$", "", t).strip() for t in titles]
        surname = work.authors[0].split(" ")[-1]
        return await self._wikidata.adaptations(
            list(dict.fromkeys(t for t in titles if t)), surname
        )

    async def titles(self, work_ids: list[UUID]) -> dict[UUID, tuple[str, tuple[str, ...]]]:
        """Title and authors of works, for lists that show them (no refresh, no request out)."""
        found: dict[UUID, tuple[str, tuple[str, ...]]] = {}
        for work_id in dict.fromkeys(work_ids):
            work = await self._repo.get_work(work_id)
            if work is not None:
                found[work_id] = (work.title, work.authors)
        return found

    async def cover_url(self, work_id: UUID) -> str | None:
        work = await self._repo.get_work(work_id)
        return work.cover_url if work else None

    async def _enrich(self, work: Work) -> Work:
        """What the catalog lacks about a book (a blurb, genres, a cover, a rating) is looked
        for at Hardcover, once: it knows manga and recent books well. Best effort."""
        if self._hardcover is None:
            return work
        complete = (
            work.description
            and work.subjects
            and (work.cover_id or work.cover_url)
            and work.rating is not None
        )
        if complete:
            return work
        query = f"{work.title} {work.authors[0]}" if work.authors else work.title
        hits = await self._hardcover_books(query, 5)
        surnames = {a.split(" ")[-1].casefold() for a in work.authors if a.strip()}
        wanted = guess_series(work.title)
        for hit in hits:
            who = " ".join(hit.authors).casefold()
            theirs = guess_series(hit.title)
            same = hit.title.casefold() == work.title.casefold() or (
                wanted is not None
                and theirs is not None
                and series_key(wanted.series.split(" - ")[0]) == series_key(theirs.series)
                and wanted.number == theirs.number
            )
            if not same or (surnames and not any(s in who for s in surnames)):
                continue
            if hit.description and not work.description:
                await self._repo.set_work_description(work.id, hit.description)
            await self._repo.set_work_extras(work.id, hit.genres or None, hit.image, hit.rating)
            await self._repo.commit()
            return await self._repo.get_work(work.id) or work
        return work

    async def lookup_isbn(self, raw: str) -> IsbnMatch:
        isbn = normalize_isbn(raw)
        edition = await self._repo.find_edition(IdentifierKind.ISBN13, isbn)
        if edition is None:
            edition = await self._import_isbn(isbn)
        return IsbnMatch(await self.get(edition.work_id), edition)

    # ------------------------------------------------------------ internals
    @staticmethod
    def _needs_sync(work: Work) -> bool:
        if work.open_library_id is None or work.open_library_id.startswith(HARDCOVER_PREFIX):
            return False
        synced = work.editions_synced_at
        return synced is None or datetime.now(UTC) - synced > EDITIONS_TTL

    async def _sync(self, work: Work) -> Work:
        """Refresh description, authors and editions; on failure, keep serving the cache."""
        assert work.open_library_id is not None  # noqa: S101 - guaranteed by _needs_sync
        try:
            details = await self._source.work(work.open_library_id)
            editions = await self._source.editions(work.open_library_id, MAX_EDITIONS)
        except Exception:
            logger.warning("Could not refresh work %s", work.open_library_id, exc_info=True)
            return work
        if details is not None:
            work = await self._repo.upsert_work(details)
        await self._repo.upsert_editions(work.id, editions)
        await self._complete_descriptions(work)
        await self._repo.mark_editions_synced(work.id, datetime.now(UTC))
        await self._repo.commit()
        return await self._repo.get_work(work.id) or work

    async def _complete_descriptions(self, work: Work) -> None:
        """Open Library often gives one line, or none: Google Books fills the gap, per
        language (a few editions at most, one per language), and for the work itself."""
        editions = await self._repo.list_editions(work.id)
        have = [e.description for e in editions if e.description]
        if work.description:
            have.append(work.description)
        if max(map(len, have), default=0) >= FULL_DESCRIPTION:
            return
        seen: set[str | None] = set()
        for edition in sorted(editions, key=lambda e: not e.identifier(IdentifierKind.ISBN13)):
            if len(seen) >= MAX_BLURBS or edition.language in seen:
                continue
            if edition.description and len(edition.description) >= FULL_DESCRIPTION:
                seen.add(edition.language)
                continue
            seen.add(edition.language)
            isbns = edition.identifier(IdentifierKind.ISBN13)
            text = await self._blurb(
                isbns[0] if isbns else None, edition.title or work.title, work, edition.language
            )
            if text:
                await self._repo.set_edition_description(edition.id, text)
        if not work.description or len(work.description) < FULL_DESCRIPTION:
            text = await self._blurb(None, work.title, work, None)
            if (not text or len(text) < FULL_DESCRIPTION) and self._hardcover is not None:
                # Still short: Hardcover often has a full blurb (English, one request).
                text = await self._hardcover.description(work.title, work.authors) or text
            if text and len(text) > len(work.description or ""):
                await self._repo.set_work_description(work.id, text)

    async def _blurb(
        self, isbn13: str | None, title: str, work: Work, language: str | None
    ) -> str | None:
        try:
            return await self._source.blurb(isbn13, title, work.authors, language)
        except Exception:
            logger.warning("Could not get a description for %s", title, exc_info=True)
            return None

    async def _import_isbn(self, isbn: str) -> Edition:
        try:
            found = await self._source.edition_by_isbn(isbn)
        except Exception as error:
            raise SourceUnavailableError from error
        if found is None:
            raise NotFoundError
        work = await self._repo.get_work_by_open_library_id(found.work_open_library_id)
        if work is None:
            try:
                details = await self._source.work(found.work_open_library_id)
            except Exception as error:
                raise SourceUnavailableError from error
            work = await self._repo.upsert_work(
                details or SourceWork(open_library_id=found.work_open_library_id, title=found.title)
            )
        await self._repo.upsert_editions(work.id, [found])
        await self._repo.commit()
        edition = await self._repo.find_edition(IdentifierKind.ISBN13, isbn)
        if edition is None:
            # The ISBN was already claimed by another edition record.
            raise NotFoundError
        return edition
