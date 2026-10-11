"""Ratings found outside Babel: Open Library (API) and Goodreads (its public search page).

Goodreads has no public API any more: its search page is read, which can break whenever the
site changes, so any surprise reads as "no rating". Booknode refuses automated requests
(Cloudflare), so it is left out. Each answer is kept for a day.
"""

import html
import logging
import re
import time
from dataclasses import dataclass
from typing import Any, cast

import httpx

from babel_api.domain.series import series_key

log = logging.getLogger(__name__)

CACHE_SECONDS = 24 * 3600
SHELF_SECONDS = 30 * 3600
USER_AGENT = "Mozilla/5.0 (compatible; Babel/1.0; +https://babel.jouskaio.me)"
_ROW = re.compile(r'itemtype="http://schema.org/Book"(.*?)</tr>', re.S)
_TITLE = re.compile(
    r'class="bookTitle"[^>]*href="([^"]+)"[^>]*>\s*<span itemprop=\'name\'[^>]*>(.*?)</span>', re.S
)
_AUTHOR = re.compile(r'class="authorName"[^>]*>\s*<span itemprop="name">(.*?)</span>', re.S)
_RATING = re.compile(r"([0-9.]+)\s*avg rating\s*(?:&mdash;|—)\s*([\d,]+)\s*rating")


@dataclass(frozen=True, slots=True)
class ExternalRating:
    source: str  # "openlibrary" or "goodreads"
    average: float  # out of 5
    count: int
    url: str


def parse_goodreads(page: str, title: str, authors: tuple[str, ...]) -> ExternalRating | None:
    """The rating of the first search result with this title (a subtitle after ":" or "(" is
    ignored) and an author sharing a surname with ours."""
    wanted = series_key(re.split(r"[:(]", title)[0])
    surnames = {series_key(a).split(" ")[-1] for a in authors if series_key(a)}
    for row in _ROW.findall(page):
        title_match = _TITLE.search(row)
        who = _AUTHOR.search(row)
        rating = _RATING.search(row)
        if title_match is None or rating is None:
            continue
        link, name = title_match.group(1), title_match.group(2)
        found = series_key(re.split(r"[:(]", html.unescape(name))[0])
        author = series_key(html.unescape(who.group(1))) if who else ""
        if found != wanted or (surnames and not any(s in author for s in surnames)):
            continue
        return ExternalRating(
            "goodreads",
            float(rating.group(1)),
            int(rating.group(2).replace(",", "")),
            f"https://www.goodreads.com{html.unescape(link).split('?')[0]}",
        )
    return None


@dataclass(frozen=True, slots=True)
class ShelfBook:
    """A book of a Goodreads shelf, most shelved first."""

    title: str
    author: str


_SHELF_TITLE = re.compile(r'class="bookTitle"[^>]*>(.*?)</a>', re.S)
_SHELF_AUTHOR = re.compile(r'class="authorName"[^>]*>\s*<span itemprop="name">(.*?)</span>', re.S)


def parse_shelf(page: str) -> list[ShelfBook]:
    """The books of a shelf page, titles cleaned of the edition and series in parentheses."""
    books: list[ShelfBook] = []
    for chunk in page.split('class="elementList"')[1:]:
        title = _SHELF_TITLE.search(chunk)
        who = _SHELF_AUTHOR.search(chunk)
        if title is None or who is None:
            continue
        name = re.sub(r"\s*\(.*?\)", "", html.unescape(title.group(1))).strip()
        if name:
            books.append(ShelfBook(name, html.unescape(who.group(1)).strip()))
    return books


class ExternalRatings:
    def __init__(self, client: httpx.AsyncClient | None = None, goodreads: bool = True) -> None:
        self._client = client or httpx.AsyncClient(
            timeout=15, headers={"User-Agent": USER_AGENT}, follow_redirects=True
        )
        self._goodreads = goodreads
        self._cache: dict[str, tuple[float, ExternalRating | None]] = {}
        self._shelves: dict[str, tuple[float, list[ShelfBook]]] = {}

    def _cached(self, key: str) -> tuple[bool, ExternalRating | None]:
        found = self._cache.get(key)
        if found is not None and time.monotonic() - found[0] < CACHE_SECONDS:
            return True, found[1]
        return False, None

    async def shelf(self, slug: str) -> list[ShelfBook]:
        """The books readers shelve most under [slug] on Goodreads (empty when scraping is off or
        the page cannot be read). Kept for 30 hours: the refresh runs once a day."""
        if not self._goodreads:
            return []
        found = self._shelves.get(slug)
        if found is not None and time.monotonic() - found[0] < SHELF_SECONDS:
            return found[1]
        try:
            response = await self._client.get(f"https://www.goodreads.com/shelf/show/{slug}")
            response.raise_for_status()
        except httpx.HTTPError as error:
            log.info("Goodreads shelf %s unavailable: %s", slug, error)
            return []
        books = parse_shelf(response.text)
        if books:
            self._shelves[slug] = (time.monotonic(), books)
        return books

    async def openlibrary(self, work_id: str) -> ExternalRating | None:
        key = f"ol:{work_id}"
        hit, value = self._cached(key)
        if hit:
            return value
        rating: ExternalRating | None = None
        try:
            response = await self._client.get(
                f"https://openlibrary.org/works/{work_id}/ratings.json"
            )
            response.raise_for_status()
            summary = cast(
                dict[str, Any], cast(dict[str, Any], response.json()).get("summary") or {}
            )
            count, average = summary.get("count"), summary.get("average")
            if isinstance(count, int) and count > 0 and isinstance(average, int | float):
                rating = ExternalRating(
                    "openlibrary",
                    round(float(average), 2),
                    count,
                    f"https://openlibrary.org/works/{work_id}",
                )
        except (httpx.HTTPError, ValueError) as error:
            log.info("Open Library ratings unavailable: %s", error)
            return None
        self._cache[key] = (time.monotonic(), rating)
        return rating

    async def goodreads(self, title: str, authors: tuple[str, ...]) -> ExternalRating | None:
        if not self._goodreads:
            return None
        query = f"{title} {authors[0]}" if authors else title
        key = f"gr:{series_key(query)}"
        hit, value = self._cached(key)
        if hit:
            return value
        rating: ExternalRating | None = None
        try:
            response = await self._client.get(
                "https://www.goodreads.com/search", params={"q": query}
            )
            response.raise_for_status()
            rating = parse_goodreads(response.text, title, authors)
        except httpx.HTTPError as error:
            log.info("Goodreads search unavailable: %s", error)
            return None
        self._cache[key] = (time.monotonic(), rating)
        return rating

    async def aclose(self) -> None:
        await self._client.aclose()
