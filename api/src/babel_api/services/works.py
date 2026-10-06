"""Works, editions and ISBN lookups, cached from external catalogs (ADR 0007)."""

import logging
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta
from uuid import UUID

from babel_api.domain.catalog import Edition, IdentifierKind, SourceWork, Work
from babel_api.domain.errors import NotFoundError, SourceUnavailableError
from babel_api.domain.isbn import normalize_isbn
from babel_api.domain.ports import BookSource, CatalogRepository

logger = logging.getLogger(__name__)

# Editions of a work are fetched again at most this often.
EDITIONS_TTL = timedelta(days=7)
MAX_EDITIONS = 50
# A description this long is a real blurb; shorter ones are completed from Google Books.
FULL_DESCRIPTION = 400
# Editions (one per language) asked about at most, per refresh of a work.
MAX_BLURBS = 4


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
class IsbnMatch:
    detail: WorkDetail
    edition: Edition


class WorkService:
    def __init__(self, repository: CatalogRepository, source: BookSource) -> None:
        self._repo = repository
        self._source = source

    async def search(self, query: str, limit: int, language: str | None = None) -> list[SearchHit]:
        try:
            found = await self._source.search(query, limit, language)
        except Exception as error:
            raise SourceUnavailableError from error
        hits: list[SearchHit] = []
        for source in found:
            work = await self._repo.upsert_work(source)
            hits.append(
                SearchHit(
                    work,
                    source.localized_title or work.title,
                    source.localized_cover_id or work.cover_id,
                )
            )
        await self._repo.commit()
        return hits

    async def get(self, work_id: UUID) -> WorkDetail:
        work = await self._repo.get_work(work_id)
        if work is None:
            raise NotFoundError
        if self._needs_sync(work):
            work = await self._sync(work)
        return WorkDetail(work, await self._repo.list_editions(work.id))

    async def lookup_isbn(self, raw: str) -> IsbnMatch:
        isbn = normalize_isbn(raw)
        edition = await self._repo.find_edition(IdentifierKind.ISBN13, isbn)
        if edition is None:
            edition = await self._import_isbn(isbn)
        return IsbnMatch(await self.get(edition.work_id), edition)

    # ------------------------------------------------------------ internals
    @staticmethod
    def _needs_sync(work: Work) -> bool:
        if work.open_library_id is None:
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
