"""Hardcover's GraphQL API (beta, free key): the volumes of a series, in order.

Public book data only, never a member's library or reviews. Each answer is kept for a day,
which keeps a saga page far below the free daily quota (5000 requests). Any failure reads as
"nothing known": the saga page works without it.
"""

import asyncio
import html
import json
import logging
import re
import time
from dataclasses import dataclass
from datetime import UTC, datetime
from typing import Any, cast

import httpx

from babel_api.domain.series import series_key

log = logging.getLogger(__name__)

URL = "https://api.hardcover.app/v1/graphql"
CACHE_SECONDS = 24 * 3600
# The free key allows 5000 requests a day (60 a minute, bursts of 10): stop at 4500 so a busy
# day never uses the last ones up, and rest for as long as Hardcover says after a 429.
DAILY_BUDGET = 4500
MAX_PAUSE = 6 * 3600
MIN_DESCRIPTION = 80  # a shorter text is no better than what the catalog already has
_SEARCH = """query($q: String!) { search(query: $q, query_type: "Series", per_page: 5) {
  ids results } }"""
_VOLUMES = """query($id: Int!) { series(where: {id: {_eq: $id}}) {
  book_series(order_by: {position: asc}) { position book { id title } } } }"""


@dataclass(frozen=True, slots=True)
class HardcoverBook:
    """A book as Hardcover's search describes it."""

    id: int
    title: str
    authors: tuple[str, ...]
    year: int | None
    description: str | None
    image: str | None = None
    genres: tuple[str, ...] = ()
    rating: float | None = None
    pages: int | None = None


@dataclass(frozen=True, slots=True)
class HardcoverReview:
    """A public review of a book on Hardcover."""

    author: str
    rating: float | None
    text: str
    spoilers: bool
    likes: int


class HardcoverBusyError(ValueError):
    """Out of requests for now (our own budget, or Hardcover's 429): try later."""


_REVIEWS = """query($id: Int!, $n: Int!) { user_books(
  where: {book_id: {_eq: $id}, has_review: {_eq: true}, privacy_setting_id: {_eq: 1}},
  order_by: {likes_count: desc}, limit: $n) {
  rating review_raw review_has_spoilers likes_count user { username } } }"""
_BOOK = """query($q: String!) { search(query: $q, query_type: "Book", per_page: 5) { results } }"""
_BOOKS = """query($q: String!, $n: Int!) { search(query: $q, query_type: "Book", per_page: $n) {
  ids results } }"""
_TAGS = re.compile(r"<[^>]+>")


def _hits(search: dict[str, Any]) -> list[dict[str, Any]]:
    raw = cast(Any, search.get("results"))
    results = cast(dict[str, Any], json.loads(raw) if isinstance(raw, str) else raw or {})
    found = cast(list[dict[str, Any]], results.get("hits") or [])
    return [cast(dict[str, Any], hit.get("document") or {}) for hit in found]


def pick_description(search: dict[str, Any], title: str, authors: tuple[str, ...]) -> str | None:
    """The description of the book with this title (a subtitle is ignored) by this author."""
    wanted = series_key(re.split(r"[:(]", title)[0])
    surnames = {series_key(a).split(" ")[-1] for a in authors if series_key(a)}
    for doc in _hits(search):
        name = series_key(re.split(r"[:(]", str(doc.get("title", "")))[0])
        who = series_key(" ".join(str(a) for a in cast(list[Any], doc.get("author_names") or [])))
        if name != wanted or (surnames and not any(s in who for s in surnames)):
            continue
        text = html.unescape(_TAGS.sub("", str(doc.get("description") or ""))).strip()
        return text if len(text) >= MIN_DESCRIPTION else None
    return None


_BRACKETS = re.compile(r"\[([^\]]+)\]")
_ARTICLES = {"the", "a", "an", "le", "la", "les", "l", "un", "une", "der", "die", "das"}
_SERIES_WORDS = {"series", "serie", "saga", "trilogy", "cycle", "collection", "novels"}


def _norm(name: str) -> str:
    """A series name without the words that vary: "The Hunger Games (Trilogy)" and
    "Hunger Games Series" are both "hunger games"."""
    words = series_key(re.sub(r"\([^)]*\)", " ", name)).split()
    while words and words[0] in _ARTICLES:
        words = words[1:]
    while words and words[-1] in _SERIES_WORDS:
        words = words[:-1]
    return " ".join(words)


def _spellings(name: str) -> set[str]:
    """The ways a series is spelled: "ホムンクルス [Homunculus]" is also "Homunculus"."""
    spellings = {_norm(name), _norm(_BRACKETS.sub(" ", name))}
    spellings.update(_norm(inside) for inside in _BRACKETS.findall(name))
    return spellings - {""}


def pick_series(search: dict[str, Any], name: str, author: str | None) -> int | None:
    """The id of the series called [name] among search hits: the same name however spelled
    (translated title in brackets, "Series" or "Trilogy" added, a leading "The"), or a longer
    name that contains it when the author agrees ("Homunculus" in "Homunculus Bunkoban").

    With an author, the series by that author wins; with several of the name and none by that
    author, nothing is guessed; with a single one, it is taken (the author may be spelled in
    another script). Among several, the one with the most readers."""
    ids = cast(list[Any], search.get("ids") or [])
    wanted = _norm(name)
    wanted_words = set(wanted.split())
    surname = series_key(author).split(" ")[-1] if author and series_key(author) else None
    scored: list[tuple[bool, bool, int, int]] = []  # author agrees, exact, readers, hit index
    for i, doc in enumerate(_hits(search)):
        spellings = _spellings(str(doc.get("name", "")))
        exact = wanted in spellings
        contains = any(wanted_words and wanted_words <= set(sp.split()) for sp in spellings)
        agrees = not surname or surname in series_key(str(doc.get("author_name", "")))
        if exact or (contains and agrees):
            readers = doc.get("readers_count")
            scored.append((agrees, exact, int(readers) if isinstance(readers, int) else 0, i))
    pool = [c for c in scored if c[0]] or (scored if len(scored) == 1 or not surname else [])
    if not pool:
        return None
    i = max(pool)[3]
    doc = _hits(search)[i]
    return int(ids[i]) if i < len(ids) else int(doc["id"])


class HardcoverClient:
    def __init__(self, api_key: str, client: httpx.AsyncClient | None = None) -> None:
        token = api_key.strip()
        self._headers = {
            "authorization": token if token.lower().startswith("bearer ") else f"Bearer {token}",
            "user-agent": "Babel (babel.jouskaio.me)",
        }
        self._client = client or httpx.AsyncClient(timeout=10)
        self._cache: dict[tuple[str, str], tuple[float, list[tuple[float, str, int | None]]]] = {}
        self._described: dict[tuple[str, str], tuple[float, str | None]] = {}
        self._found: dict[tuple[str, str], tuple[float, list[HardcoverBook]]] = {}
        self._reviewed: dict[tuple[str, str], tuple[float, list[HardcoverReview]]] = {}
        self._paused_until = 0.0
        self._day = datetime.now(UTC).date()
        self._used = 0
        self._gate = asyncio.Semaphore(4)  # gentle with the per-minute limit

    def _spend(self) -> None:
        """One request of today's budget, or [HardcoverBusyError]."""
        today = datetime.now(UTC).date()
        if today != self._day:
            self._day, self._used = today, 0
        if time.monotonic() < self._paused_until or self._used >= DAILY_BUDGET:
            raise HardcoverBusyError("budget")
        self._used += 1

    async def _query(self, query: str, variables: dict[str, object]) -> dict[str, Any]:
        self._spend()
        async with self._gate:
            response = await self._client.post(
                URL, json={"query": query, "variables": variables}, headers=self._headers
            )
        if response.status_code == 429:
            wait = response.headers.get("retry-after", "")
            pause = min(int(wait) if wait.isdigit() else 3600, MAX_PAUSE)
            self._paused_until = time.monotonic() + pause
            raise HardcoverBusyError(f"429, rest {pause}s")
        response.raise_for_status()
        body = cast(dict[str, Any], response.json())
        if body.get("errors"):
            raise ValueError(str(body["errors"])[:200])
        return cast(dict[str, Any], body.get("data") or {})

    async def series_volumes(
        self, name: str, author: str | None
    ) -> list[tuple[float, str, int | None]]:
        """(position, title, Hardcover id) of a series' numbered volumes; none when unknown."""
        key = (series_key(name), series_key(author or ""))
        cached = self._cache.get(key)
        if cached is not None and time.monotonic() - cached[0] < CACHE_SECONDS:
            return cached[1]
        try:
            found = await self._query(_SEARCH, {"q": f"{name} {author or ''}".strip()})
            search = cast(dict[str, Any], found.get("search") or {})
            series_id = pick_series(search, name, author)
            if series_id is None:
                seen = [(str(d.get("name")), str(d.get("author_name"))) for d in _hits(search)]
                log.info("Hardcover has no series %r by %r; it found %s", name, author, seen)
            volumes: list[tuple[float, str, int | None]] = []
            if series_id is not None:
                data = await self._query(_VOLUMES, {"id": series_id})
                for series in cast(list[dict[str, Any]], data.get("series") or []):
                    for link in cast(list[dict[str, Any]], series.get("book_series") or []):
                        position = link.get("position")
                        book = cast(dict[str, Any], link.get("book") or {})
                        title, book_id = book.get("title"), book.get("id")
                        if isinstance(position, int | float) and title:
                            hc_id = book_id if isinstance(book_id, int) else None
                            volumes.append((float(position), str(title), hc_id))
        except (httpx.HTTPError, ValueError, KeyError, TypeError) as error:
            log.warning("Hardcover did not answer: %s", error)
            return []
        self._cache[key] = (time.monotonic(), volumes)
        return volumes

    async def description(self, title: str, authors: tuple[str, ...]) -> str | None:
        """The description Hardcover has for a book, or None. One request, kept for a day
        (a miss too, so the same book is not asked again and again)."""
        key = (series_key(title), series_key(authors[0]) if authors else "")
        cached = self._described.get(key)
        if cached is not None and time.monotonic() - cached[0] < CACHE_SECONDS:
            return cached[1]
        try:
            query = f"{title} {authors[0]}" if authors else title
            found = await self._query(_BOOK, {"q": query})
            text = pick_description(cast(dict[str, Any], found.get("search") or {}), title, authors)
        except (httpx.HTTPError, ValueError, KeyError, TypeError) as error:
            log.warning("Hardcover did not answer: %s", error)
            return None  # not cached: it may work later
        self._described[key] = (time.monotonic(), text)
        return text

    async def reviews(self, book_id: int, limit: int = 5) -> list[HardcoverReview]:
        """The most liked public reviews of a book; empty when there are none or Hardcover
        does not answer. One request, kept for a day."""
        key = ("reviews", str(book_id))
        cached = self._reviewed.get(key)
        if cached is not None and time.monotonic() - cached[0] < CACHE_SECONDS:
            return cached[1][:limit]
        try:
            data = await self._query(_REVIEWS, {"id": book_id, "n": limit})
        except (httpx.HTTPError, ValueError, KeyError, TypeError) as error:
            log.warning("Hardcover did not answer: %s", error)
            return []
        found: list[HardcoverReview] = []
        for row in cast(list[dict[str, Any]], data.get("user_books") or []):
            text = html.unescape(_TAGS.sub("", str(row.get("review_raw") or ""))).strip()
            if len(text) < 30:
                continue
            user = cast(dict[str, Any], row.get("user") or {})
            rating = row.get("rating")
            likes = row.get("likes_count")
            found.append(
                HardcoverReview(
                    author=str(user.get("username") or "?"),
                    rating=float(rating) if isinstance(rating, int | float) else None,
                    text=text[:1200],
                    spoilers=bool(row.get("review_has_spoilers")),
                    likes=likes if isinstance(likes, int) else 0,
                )
            )
        self._reviewed[key] = (time.monotonic(), found)
        return found[:limit]

    async def search_books(self, query: str, limit: int = 10) -> list[HardcoverBook]:
        """Books matching a search, best first; empty when Hardcover does not answer. One
        request, kept for a day."""
        key = ("search", series_key(query))
        cached = self._found.get(key)
        if cached is not None and time.monotonic() - cached[0] < CACHE_SECONDS:
            return cached[1][:limit]
        try:
            found = await self._query(_BOOKS, {"q": query, "n": limit})
            search = cast(dict[str, Any], found.get("search") or {})
            ids = cast(list[Any], search.get("ids") or [])
            books: list[HardcoverBook] = []
            for i, doc in enumerate(_hits(search)):
                title = str(doc.get("title") or "").strip()
                raw_id = ids[i] if i < len(ids) else doc.get("id")
                if not title or not str(raw_id).isdigit():
                    continue
                year = doc.get("release_year")
                text = html.unescape(_TAGS.sub("", str(doc.get("description") or ""))).strip()
                image = cast(Any, doc.get("image"))
                url = cast(
                    Any,
                    cast(dict[str, Any], image).get("url") if isinstance(image, dict) else image,
                )
                genres = cast(list[Any], doc.get("genres") or [])
                rating = doc.get("rating")
                pages = doc.get("pages")
                books.append(
                    HardcoverBook(
                        id=int(str(raw_id)),
                        title=title,
                        authors=tuple(
                            str(a) for a in cast(list[Any], doc.get("author_names") or [])
                        )[:3],
                        year=year if isinstance(year, int) else None,
                        description=text if len(text) >= MIN_DESCRIPTION else None,
                        image=str(url) if isinstance(url, str) and url.startswith("http") else None,
                        genres=tuple(str(g) for g in genres if isinstance(g, str))[:12],
                        rating=round(float(rating), 2) if isinstance(rating, int | float) else None,
                        pages=pages if isinstance(pages, int) else None,
                    )
                )
        except (httpx.HTTPError, ValueError, KeyError, TypeError) as error:
            log.warning("Hardcover did not answer: %s", error)
            return []
        self._found[key] = (time.monotonic(), books)
        return books[:limit]
