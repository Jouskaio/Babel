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
class GoodreadsBook:
    """A book as Goodreads' own suggestion box knows it."""

    id: str
    title: str
    average: float
    count: int


@dataclass(frozen=True, slots=True)
class GoodreadsReview:
    author: str
    rating: float | None  # out of 5
    text: str
    spoilers: bool
    likes: int
    url: str


def match_goodreads(
    found: list[dict[str, Any]], title: str, authors: tuple[str, ...]
) -> GoodreadsBook | None:
    """The first suggestion with this title (subtitle and series ignored) by an author sharing
    a surname with ours; Goodreads lists the most rated first."""
    wanted = series_key(re.split(r"[:(]", title)[0])
    surnames = {series_key(a).split(" ")[-1] for a in authors if series_key(a)}
    for entry in found:
        name = series_key(re.split(r"[:(]", str(entry.get("bookTitleBare") or ""))[0])
        author = series_key(str(cast(dict[str, Any], entry.get("author") or {}).get("name", "")))
        try:
            average, count = float(entry["avgRating"]), int(entry["ratingsCount"])
        except (KeyError, TypeError, ValueError):
            continue
        if name != wanted or (surnames and not any(s in author for s in surnames)):
            continue
        return GoodreadsBook(
            str(entry.get("bookId", "")), str(entry.get("title", "")), average, count
        )
    return None


_JS_ESCAPES = {"n": "\n", "t": "\t", "r": "\r"}
_REVIEWS_PAYLOAD = re.compile(r'Element\.update\("reviews",\s*"((?:[^"\\]|\\.)*)"\)')
_REVIEW_TEXT = re.compile(r'<span id="freeText\d+"[^>]*>(.*?)</span>', re.S)
_REVIEW_TEXT_SHORT = re.compile(r'<span id="freeTextContainer\d+"[^>]*>(.*?)</span>', re.S)


def _unescape_js(raw: str) -> str:
    def replace(match: re.Match[str]) -> str:
        code = match.group(1)
        if code.startswith("u") and len(code) == 5:
            return chr(int(code[1:], 16))
        return _JS_ESCAPES.get(code, code)

    return re.sub(r"\\(u[0-9a-fA-F]{4}|.)", replace, raw)


def _plain_text(markup: str) -> str:
    text = re.sub(r"<br\s*/?>", "\n", markup)
    text = html.unescape(re.sub(r"<[^>]+>", "", text))
    return re.sub(r"\n{3,}", "\n\n", text).strip()


def parse_goodreads_reviews(payload: str, limit: int = 5) -> list[GoodreadsReview]:
    """The most liked reviews with some text, from Goodreads' reviews list (an AJAX answer
    holding HTML inside a script call)."""
    found = _REVIEWS_PAYLOAD.match(payload.strip())
    if found is None:
        return []
    reviews: list[GoodreadsReview] = []
    for block in _unescape_js(found.group(1)).split('<div id="review_')[1:]:
        who = re.search(r'class="user"[^>]*>(.*?)</a>', block, re.S)
        body = _REVIEW_TEXT.search(block) or _REVIEW_TEXT_SHORT.search(block)
        link = re.search(r'href="(/review/show/\d+)', block)
        if who is None or body is None or link is None:
            continue
        text = _plain_text(body.group(1))
        if len(text) < 40:
            continue
        stars = block.count('class="staticStar p10"')
        likes = re.search(r'class="likesCount">([\d,]+) like', block)
        reviews.append(
            GoodreadsReview(
                author=_plain_text(who.group(1)),
                rating=float(stars) if stars else None,
                text=text[:1500],
                spoilers="view spoiler" in block.lower(),
                likes=int(likes.group(1).replace(",", "")) if likes else 0,
                url=f"https://www.goodreads.com{link.group(1)}",
            )
        )
    return sorted(reviews, key=lambda r: -r.likes)[:limit]


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
        self._books: dict[str, tuple[float, GoodreadsBook | None]] = {}
        self._reviews: dict[str, tuple[float, list[GoodreadsReview]]] = {}

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

    async def _goodreads_book(self, title: str, authors: tuple[str, ...]) -> GoodreadsBook | None:
        """The Goodreads book of a title, from its suggestion box (the search page is behind a
        bot check now); kept for a day."""
        query = f"{title} {authors[0]}" if authors else title
        key = f"grb:{series_key(query)}"
        cached = self._books.get(key)
        if cached is not None and time.monotonic() - cached[0] < CACHE_SECONDS:
            return cached[1]
        book: GoodreadsBook | None = None
        # The title alone first: with an author added, study guides about the book come first.
        for asked in dict.fromkeys([title, query]):
            try:
                response = await self._client.get(
                    "https://www.goodreads.com/book/auto_complete",
                    params={"format": "json", "q": asked},
                )
                response.raise_for_status()
                data = response.json()
            except (httpx.HTTPError, ValueError) as error:
                log.info("Goodreads suggestions unavailable: %s", error)
                return None
            book = match_goodreads(cast(list[dict[str, Any]], data), title, authors)
            if book is not None:
                break
        self._books[key] = (time.monotonic(), book)
        return book

    async def goodreads(self, title: str, authors: tuple[str, ...]) -> ExternalRating | None:
        if not self._goodreads:
            return None
        book = await self._goodreads_book(title, authors)
        if book is None:
            return None
        return ExternalRating(
            "goodreads", book.average, book.count, f"https://www.goodreads.com/book/show/{book.id}"
        )

    async def goodreads_reviews(
        self, title: str, authors: tuple[str, ...], limit: int = 5
    ) -> list[GoodreadsReview]:
        """The most liked written reviews of the book on Goodreads (empty when it cannot be
        read: the list is an undocumented page and may change)."""
        if not self._goodreads:
            return []
        book = await self._goodreads_book(title, authors)
        if book is None:
            return []
        cached = self._reviews.get(book.id)
        if cached is not None and time.monotonic() - cached[0] < CACHE_SECONDS:
            return cached[1][:limit]
        try:
            response = await self._client.get(f"https://www.goodreads.com/book/reviews/{book.id}")
            response.raise_for_status()
        except httpx.HTTPError as error:
            log.info("Goodreads reviews unavailable: %s", error)
            return []
        reviews = parse_goodreads_reviews(response.text, limit=10)
        if reviews:
            self._reviews[book.id] = (time.monotonic(), reviews)
        return reviews[:limit]

    async def aclose(self) -> None:
        await self._client.aclose()
