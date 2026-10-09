"""Shelfmark's API (key access): find a volume, pick the best release, queue the download.

Used for manga, comics and light novels: Shelfmark searches Prowlarr and direct sources by
title, which finds them where Chaptarr's release search does not. The download lands in the
library folder Kavita reads. Shelfmark's API is driven by its web interface and may change.
"""

import logging
import re
from typing import Any, cast

import httpx

from babel_api.adapters.chaptarr import best_match
from babel_api.domain.errors import DomainError

BOOK_FORMATS = ("epub", "cbz", "cbr", "pdf")
MAX_VOLUME_BYTES = 400 * 1024 * 1024  # a batch of many volumes is far above this
_CJK = re.compile(r"[぀-ヿ㐀-鿿가-힯]")  # raws, not for the reader


log = logging.getLogger(__name__)


class ShelfmarkError(DomainError):
    def __init__(self, reason: str) -> None:
        super().__init__(reason)
        self.reason = reason


def pick_release(releases: list[dict[str, Any]]) -> dict[str, Any] | None:
    """The release that suits best: a book format, not in Japanese, one volume's size; a direct
    download first, then the torrent with the most seeders (none without seeders)."""
    scored: list[tuple[int, int, dict[str, Any]]] = []
    for release in releases:
        fmt = str(release.get("format") or "").lower()
        size = release.get("size_bytes")
        torrent = str(release.get("protocol") or "").lower() == "torrent"
        seeders = release.get("seeders")
        if (
            fmt not in BOOK_FORMATS
            or _CJK.search(str(release.get("title", "")))
            or (isinstance(size, int) and size > MAX_VOLUME_BYTES)
            or (torrent and not (isinstance(seeders, int) and seeders > 0))
        ):
            continue
        scored.append((0 if torrent else 1, int(seeders or 0), release))
    return max(scored, key=lambda s: s[:2])[2] if scored else None


class ShelfmarkClient:
    def __init__(self, base_url: str, api_key: str, client: httpx.AsyncClient | None = None):
        self._base = base_url.strip().rstrip("/")
        self._headers = {"X-Api-Key": api_key}
        self._client = client or httpx.AsyncClient(timeout=120)  # release search is slow

    async def _call(
        self,
        method: str,
        path: str,
        json: object | None = None,
        params: dict[str, str] | None = None,
    ) -> Any:
        try:
            response = await self._client.request(
                method, f"{self._base}/api/{path}", json=json, params=params, headers=self._headers
            )
        except httpx.HTTPError as error:
            raise ShelfmarkError("unreachable") from error
        if response.status_code in (401, 403):
            raise ShelfmarkError("unauthorized")
        if response.status_code >= 400:
            raise ShelfmarkError(f"status {response.status_code}")
        try:
            return response.json()
        except ValueError as error:
            raise ShelfmarkError("not_shelfmark") from error

    async def fetch(self, title: str, authors: tuple[str, ...]) -> bool:
        """Queues the best release of the book; False when Shelfmark knows none."""
        books: list[dict[str, Any]] = []
        # The title alone first: adding the author often finds nothing.
        for query in dict.fromkeys((title, f"{title} {authors[0]}" if authors else title)):
            found = await self._call("GET", "metadata/search", params={"query": query})
            books = cast(list[dict[str, Any]], cast(dict[str, Any], found or {}).get("books") or [])
            if books:
                break
        # Same match rule as Chaptarr's: the title (or the same volume) and a shared author.
        as_books = [
            {
                "title": b.get("title", ""),
                "author": {"authorName": " ".join(b.get("authors") or [])},
            }
            for b in books
        ]
        match = best_match(as_books, title, authors)
        if match is None:
            seen = [(b.get("title"), b.get("authors")) for b in books[:5]]
            log.info("Shelfmark: no match for %r by %s among %s", title, authors, seen)
            return False
        book = books[as_books.index(match)]
        listing = await self._call(
            "GET",
            "releases",
            params={
                "provider": str(book["provider"]),
                "book_id": str(book["provider_id"]),
                "content_type": "ebook",
            },
        )
        releases = cast(
            list[dict[str, Any]], cast(dict[str, Any], listing or {}).get("releases") or []
        )
        chosen = pick_release(releases)
        if chosen is None:
            log.info("Shelfmark: %d releases for %r, none suitable", len(releases), title)
            return False
        log.info("Shelfmark: queueing %r for %r", chosen.get("title"), title)
        await self._call("POST", "releases/download", json=chosen)
        return True

    async def aclose(self) -> None:
        await self._client.aclose()
