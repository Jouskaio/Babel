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
from babel_api.domain.series import guess_series

BOOK_FORMATS = ("epub", "cbz", "cbr", "pdf")
MAX_VOLUME_BYTES = 400 * 1024 * 1024  # a batch of many volumes is far above this
CJK = re.compile(r"[぀-ヿ㐀-鿿가-힯]")  # raws, not for the reader


log = logging.getLogger(__name__)


_NUMBER_LAST = re.compile(r"(\d{1,3})\s*$")


def original_title_match(books: list[dict[str, Any]], title: str) -> dict[str, Any] | None:
    """Among search hits titled in Japanese, Chinese or Korean, the one of the wanted volume
    (the number that ends the title). None for a book that is not a numbered volume."""
    guess = guess_series(title)
    if guess is None:
        return None
    for book in books:
        text = str(book.get("title", ""))
        number = _NUMBER_LAST.search(text.split("[")[0].strip())
        if CJK.search(text) and number is not None and float(number[1]) == guess.number:
            return book
    return None


class ShelfmarkError(DomainError):
    def __init__(self, reason: str) -> None:
        super().__init__(reason)
        self.reason = reason


_RANGE = re.compile(r"\d\s*[-–~]\s*\d")  # "1-17": a batch of volumes


def _mentions(title: str, volume: float) -> bool:
    """Whether a release title names this volume ("v01", "Vol. 1", "Tome 01", "#1")."""
    wanted = f"{volume:g}"
    return any(
        number.lstrip("0") == wanted or (not number.lstrip("0") and wanted == "0")
        for number in re.findall(r"(?<!\d)\d{1,3}(?!\d)", title)
    )


WANTED_LANGUAGES = ("en", "fr")


def _language(release: dict[str, Any]) -> str:
    """The language a release declares (ISO 639-1, "" when it does not say)."""
    extra = cast(Any, release.get("extra"))
    nested = cast(dict[str, Any], extra).get("language") if isinstance(extra, dict) else None
    declared = cast(Any, release.get("language") or nested)
    return str(declared or "").strip().lower()[:2]


_ARTICLES = {"the", "a", "an", "le", "la", "les", "l", "un", "une", "der", "die", "das"}


def core(text: str) -> str:
    """A title reduced to what identifies it: lower case, no punctuation, no leading article,
    no trailing volume number or bracketed note ("The Apothecary Diaries, Vol. 2" is
    "apothecary diaries")."""
    text = re.split(r"[\[(]", text)[0]
    text = re.sub(
        r"[\s,:;\-–—]*\b(?:tome|vol|volume|book|t|v|#)?\.?\s*\d{1,3}\s*$", "", text, flags=re.I
    )
    words = re.sub(r"[^\w]+", " ", text.casefold()).split()
    while words and words[0] in _ARTICLES:
        words = words[1:]
    return " ".join(words)


def title_keys(*names: str) -> tuple[str, ...]:
    """What a release title must contain (one of them) to be about this book: the cores of
    the names the book goes by, and the romanization Shelfmark puts in brackets."""
    found: list[str] = []
    for name in names:
        found.append(core(name))
        for inside in re.findall(r"\[([^\]]+)\]", name):
            found.append(core(inside))
    return tuple(dict.fromkeys(k for k in found if len(k) >= 3))


def pick_release(
    releases: list[dict[str, Any]],
    volume: float | None = None,
    languages: tuple[str, ...] = WANTED_LANGUAGES,
    keys: tuple[str, ...] = (),
    original_ok: bool = False,
) -> dict[str, Any] | None:
    """The release that suits best: one volume (the wanted one), a book format when it says
    which, one volume's size, in a wanted language. The language a release declares is
    trusted (a Japanese title with "en" is a translation); without one, a title in Japanese
    reads as a raw. A direct download first, then the torrent with the most seeders."""
    scored: list[tuple[int, int, dict[str, Any]]] = []
    for release in releases:
        fmt = str(release.get("format") or "").lower()  # torrents often do not say
        title = str(release.get("title", ""))
        size = release.get("size_bytes")
        torrent = str(release.get("protocol") or "").lower() == "torrent"
        seeders = release.get("seeders")
        language = _language(release)
        # The whole title, not its core: a release says "... Vol 02" after the name.
        core_text = re.sub(r"[^\w]+", " ", title.casefold())
        if (
            (fmt and fmt not in BOOK_FORMATS)
            or (language and language not in languages and not original_ok)
            or (not language and CJK.search(title) and not original_ok)
            or _RANGE.search(title)
            or (keys and not any(key in core_text for key in keys))
            or (volume is not None and not _mentions(title, volume))
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

    async def check(self) -> None:
        """Whether the address is a Shelfmark and the key is accepted (/api/status)."""
        status = await self._call("GET", "status")
        if not isinstance(status, dict):
            raise ShelfmarkError("not_shelfmark")

    async def search(self, title: str, authors: tuple[str, ...]) -> list[dict[str, Any]]:
        """Books Shelfmark's metadata finds for a title (alone first: adding the author often
        finds nothing), best first; empty when it knows none."""
        for query in dict.fromkeys((title, f"{title} {authors[0]}" if authors else title)):
            found = await self._call("GET", "metadata/search", params={"query": query})
            books = cast(list[dict[str, Any]], cast(dict[str, Any], found or {}).get("books") or [])
            if books:
                return books
        return []

    @staticmethod
    def _as_books(books: list[dict[str, Any]]) -> list[dict[str, Any]]:
        """Search hits in the shape the Chaptarr matching rules read."""
        return [
            {
                "title": b.get("title", ""),
                "author": {"authorName": " ".join(b.get("authors") or [])},
            }
            for b in books
        ]

    async def find(self, title: str, authors: tuple[str, ...]) -> dict[str, Any] | None:
        """The book Shelfmark's metadata has for this title or volume, or None."""
        books = await self.search(title, authors)
        as_books = self._as_books(books)
        # Same match rule as Chaptarr's: the title (or the same volume) and a shared author.
        match = best_match(as_books, title, authors)
        if match is None:
            # A book Shelfmark knows only by its original title (薬屋のひとりごと 1): its search
            # found it from ours, so the same volume number is enough.
            match = original_title_match(as_books, title)
        if match is not None:
            return books[as_books.index(match)]
        guess = guess_series(title)
        if guess is not None:
            return await self._by_original_name(guess.series, guess.number)
        seen = [(b.get("title"), b.get("authors")) for b in books[:5]]
        log.info("Shelfmark: no match for %r by %s among %s", title, authors, seen)
        return None

    async def _by_original_name(self, series: str, number: float) -> dict[str, Any] | None:
        """Shelfmark often knows only one volume of a series: learn the series' original name
        from it ("薬屋のひとりごと 1" gives "薬屋のひとりごと"), then ask for the wanted volume."""
        tried: set[str] = set()
        for hit in (await self.search(series, ()))[:4]:
            text = re.sub(r"\s*[\[(].*", "", str(hit.get("title", ""))).strip()
            name = re.sub(r"\s*\d{1,3}$", "", text).strip()
            if not CJK.search(name) or not name or name in tried:
                continue
            tried.add(name)
            wanted = f"{name} {number:g}"
            books = await self.search(wanted, ())
            match = original_title_match(self._as_books(books), wanted)
            if match is not None:
                log.info("Shelfmark: %r found as %r", series, wanted)
                return books[self._as_books(books).index(match)]
        log.info("Shelfmark: no match for %r %g, not even by its original name", series, number)
        return None

    async def fetch(self, title: str, authors: tuple[str, ...]) -> bool:
        """Queues the best release of the book; False when Shelfmark knows none."""
        book = await self.find(title, authors)
        if book is None:
            return False
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
        guess = guess_series(title)
        keys = title_keys(title, str(book.get("title", "")))
        volume = guess.number if guess else None
        chosen = pick_release(releases, volume, keys=keys)
        if chosen is None:
            # Nothing in English or French: a release in the original language beats none.
            chosen = pick_release(releases, volume, keys=keys, original_ok=True)
        if chosen is None:
            sample = [(r.get("title"), r.get("format"), r.get("seeders")) for r in releases[:6]]
            log.info(
                "Shelfmark: %d releases for %r, none suitable: %s", len(releases), title, sample
            )
            return False
        log.info("Shelfmark: queueing %r for %r", chosen.get("title"), title)
        await self._call("POST", "releases/download", json=chosen)
        return True

    async def aclose(self) -> None:
        await self._client.aclose()
