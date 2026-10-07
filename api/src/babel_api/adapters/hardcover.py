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
  book_series(order_by: {position: asc}) { position book { title } } } }"""


class HardcoverBusyError(ValueError):
    """Out of requests for now (our own budget, or Hardcover's 429): try later."""


_BOOK = """query($q: String!) { search(query: $q, query_type: "Book", per_page: 5) { results } }"""
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


def pick_series(search: dict[str, Any], name: str, author: str | None) -> int | None:
    """The id of the series called [name], among search hits. With several of that name, the
    one by this author; with a single one, that one (its author may be spelled otherwise)."""
    ids = cast(list[Any], search.get("ids") or [])
    surname = series_key(author).split(" ")[-1] if author and series_key(author) else None
    named: list[tuple[int, dict[str, Any]]] = [
        (i, doc)
        for i, doc in enumerate(_hits(search))
        if series_key(str(doc.get("name", ""))) == series_key(name)
    ]
    chosen = [
        (i, doc)
        for i, doc in named
        if not surname or surname in series_key(str(doc.get("author_name", "")))
    ] or (named if len(named) == 1 else [])
    if not chosen:
        return None
    i, doc = chosen[0]
    return int(ids[i]) if i < len(ids) else int(doc["id"])


class HardcoverClient:
    def __init__(self, api_key: str, client: httpx.AsyncClient | None = None) -> None:
        token = api_key.strip()
        self._headers = {
            "authorization": token if token.lower().startswith("bearer ") else f"Bearer {token}",
            "user-agent": "Babel (babel.jouskaio.me)",
        }
        self._client = client or httpx.AsyncClient(timeout=10)
        self._cache: dict[tuple[str, str], tuple[float, list[tuple[float, str]]]] = {}
        self._described: dict[tuple[str, str], tuple[float, str | None]] = {}
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

    async def series_volumes(self, name: str, author: str | None) -> list[tuple[float, str]]:
        """(position, title) of each numbered volume of a series; empty when unknown."""
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
            volumes: list[tuple[float, str]] = []
            if series_id is not None:
                data = await self._query(_VOLUMES, {"id": series_id})
                for series in cast(list[dict[str, Any]], data.get("series") or []):
                    for link in cast(list[dict[str, Any]], series.get("book_series") or []):
                        position = link.get("position")
                        book = cast(dict[str, Any], link.get("book") or {})
                        title = book.get("title")
                        if isinstance(position, int | float) and title:
                            volumes.append((float(position), str(title)))
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
