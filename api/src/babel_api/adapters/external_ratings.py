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


class ExternalRatings:
    def __init__(self, client: httpx.AsyncClient | None = None, goodreads: bool = True) -> None:
        self._client = client or httpx.AsyncClient(
            timeout=15, headers={"User-Agent": USER_AGENT}, follow_redirects=True
        )
        self._goodreads = goodreads
        self._cache: dict[str, tuple[float, ExternalRating | None]] = {}

    def _cached(self, key: str) -> tuple[bool, ExternalRating | None]:
        found = self._cache.get(key)
        if found is not None and time.monotonic() - found[0] < CACHE_SECONDS:
            return True, found[1]
        return False, None

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
