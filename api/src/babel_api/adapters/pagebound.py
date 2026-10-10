"""Pagebound (a social reading site): ratings, reviews and a reader's public reviews.

Pagebound has no documented API. Its website talks to a JSON API without signing in for what
is public (book pages, their reviews, a reader's public profile and reviews); this reads only
that, the way a browser does, and nothing a reader keeps private. It may change at any time:
any surprise reads as "nothing known".
"""

import html
import logging
import re
import time
from dataclasses import dataclass
from typing import Any, cast

import httpx

from babel_api.adapters.chaptarr import best_match

log = logging.getLogger(__name__)

BASE = "https://prod-pagebound-api.onrender.com/api/v1"
SITE = "https://pagebound.co"
CACHE_SECONDS = 24 * 3600
USER_AGENT = "Mozilla/5.0 (compatible; Babel/1.0; +https://babel.jouskaio.me)"
MAX_REVIEW_PAGES = 20
_BREAKS = re.compile(r"<br\s*/?>", re.I)
_TAGS = re.compile(r"<[^>]+>")


@dataclass(frozen=True, slots=True)
class PageboundRating:
    uuid: str
    average: float  # out of 5
    count: int
    url: str


@dataclass(frozen=True, slots=True)
class PageboundReview:
    author: str
    rating: float | None
    text: str
    spoiler: bool
    likes: int


@dataclass(frozen=True, slots=True)
class PageboundUserReview:
    """A review a reader wrote on Pagebound, with the book it is about."""

    title: str
    authors: tuple[str, ...]
    rating: float | None
    text: str | None
    date: str | None


def clean(text: object) -> str:
    """A review's text without its HTML."""
    return html.unescape(_TAGS.sub("", _BREAKS.sub("\n", str(text or "")))).strip()


def _number(value: object) -> float | None:
    try:
        number = float(str(value))
    except (TypeError, ValueError):
        return None
    return number if number > 0 else None


class PageboundClient:
    def __init__(self, client: httpx.AsyncClient | None = None) -> None:
        self._client = client or httpx.AsyncClient(
            timeout=45,  # the free server sleeps: the first request can be slow
            headers={"User-Agent": USER_AGENT},
        )
        self._cache: dict[str, tuple[float, Any]] = {}

    async def _get(self, path: str, params: dict[str, str] | None = None) -> Any:
        key = path + repr(sorted((params or {}).items()))
        cached = self._cache.get(key)
        if cached is not None and time.monotonic() - cached[0] < CACHE_SECONDS:
            return cached[1]
        response = await self._client.get(f"{BASE}{path}", params=params)
        response.raise_for_status()
        data = response.json()
        self._cache[key] = (time.monotonic(), data)
        return data

    async def find(self, title: str, authors: tuple[str, ...]) -> str | None:
        """The uuid of the book on Pagebound with this title and author, or None."""
        query = f"{title} {authors[0]}" if authors else title
        try:
            found = cast(list[dict[str, Any]], await self._get("/books/search", {"q": query}) or [])
        except (httpx.HTTPError, ValueError) as error:
            log.info("Pagebound search failed: %s", error)
            return None
        as_books = [
            {"title": b.get("title", ""), "author": {"authorName": b.get("author_name", "")}}
            for b in found
        ]
        match = best_match(as_books, title, authors)
        return str(found[as_books.index(match)]["uuid"]) if match is not None else None

    async def rating(self, uuid: str) -> PageboundRating | None:
        try:
            data = cast(dict[str, Any], await self._get(f"/books/{uuid}"))
        except (httpx.HTTPError, ValueError) as error:
            log.info("Pagebound book failed: %s", error)
            return None
        ratings = cast(
            dict[str, Any],
            cast(dict[str, Any], data.get("book") or {}).get("aggregate_ratings") or {},
        )
        average, count = _number(ratings.get("overall")), ratings.get("ratings_count")
        if average is None or not isinstance(count, int) or count <= 0:
            return None
        return PageboundRating(uuid, average, count, f"{SITE}/books/{uuid}")

    async def reviews(self, uuid: str, limit: int = 5) -> list[PageboundReview]:
        """The reviews of a book with some text, the most liked first."""
        try:
            data = cast(dict[str, Any], await self._get(f"/books/{uuid}/reviews"))
        except (httpx.HTTPError, ValueError) as error:
            log.info("Pagebound reviews failed: %s", error)
            return []
        found: list[PageboundReview] = []
        for row in cast(list[dict[str, Any]], data.get("reviews") or []):
            text = clean(row.get("review"))
            if len(text) < 30 or row.get("is_flagged") or row.get("is_blocked"):
                continue
            likes = row.get("upvotes")
            found.append(
                PageboundReview(
                    author=str(row.get("username") or "?"),
                    rating=_number(row.get("overall_rating")),
                    text=text[:1200],
                    spoiler=bool(row.get("is_spoiler")),
                    likes=likes if isinstance(likes, int) else 0,
                )
            )
        return sorted(found, key=lambda r: -r.likes)[:limit]

    async def user_id(self, username: str) -> int | None:
        """The numeric id of a public profile (None when there is no such reader)."""
        try:
            data = cast(dict[str, Any], await self._get(f"/users/{username}"))
        except (httpx.HTTPError, ValueError):
            return None
        found = data.get("id")
        return found if isinstance(found, int) else None

    async def user_reviews(self, user_id: int) -> list[PageboundUserReview]:
        """Every public review of a reader (up to 20 pages)."""
        out: list[PageboundUserReview] = []
        page, total = 1, 1
        while page <= min(total, MAX_REVIEW_PAGES):
            data = cast(
                dict[str, Any], await self._get(f"/users/{user_id}/reviews", {"page": str(page)})
            )
            total = int(data.get("total_pages") or 1)
            for row in cast(list[dict[str, Any]], data.get("reviews") or []):
                book = cast(dict[str, Any], row.get("book") or {})
                title = str(book.get("title") or "").strip()
                if not title:
                    continue
                author = str(book.get("author_name") or "").strip()
                text = clean(row.get("review"))
                out.append(
                    PageboundUserReview(
                        title=title,
                        authors=(author,) if author else (),
                        rating=_number(row.get("overall_rating")),
                        text=text or None,
                        date=str(row.get("created_at") or "") or None,
                    )
                )
            page += 1
        return out

    async def aclose(self) -> None:
        await self._client.aclose()
