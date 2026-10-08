"""Chaptarr's API (a Readarr fork): find a book, ask it to download it, see if it arrived.

Only ebooks are requested. The books it downloads land in the library folder that
Kavita reads, so they show up in the reader's sources after Kavita scans.
"""

import re
import unicodedata
from typing import Any, cast

import httpx

from babel_api.domain.errors import DomainError
from babel_api.domain.series import guess_series, series_key

EBOOK_QUALITY = "ebook"  # profile type names in Chaptarr


class ChaptarrError(DomainError):
    def __init__(self, reason: str) -> None:
        super().__init__(reason)
        self.reason = reason


def _plain(text: str) -> str:
    decomposed = unicodedata.normalize("NFKD", text.lower())
    kept = "".join(c for c in decomposed if not unicodedata.combining(c))
    return re.sub(r"[^a-z0-9]+", " ", kept).strip()


_RANGE = re.compile(r"\d\s*[-–—/&]\s*\d")  # "Vol. 3-4": an omnibus, never one volume


def _same_volume(wanted: str, found: str) -> bool:
    """ "Homunculus 3" and "Homunculus, Band 3" are the same volume of the same series;
    "Homunculus 3-4" (an omnibus) and "Homunculus 2" are not."""
    mine, theirs = guess_series(wanted), guess_series(found)
    return (
        mine is not None
        and theirs is not None
        and series_key(mine.series) == series_key(theirs.series)
        and mine.number == theirs.number
        and not _RANGE.search(found)
    )


def best_match(
    candidates: list[dict[str, Any]], title: str, authors: tuple[str, ...]
) -> dict[str, Any] | None:
    """The candidate with the same title (a subtitle after ":" or "(" is ignored) or the same
    volume of the same series, and an author that shares the work's author surname. Study
    guides and anthologies never match."""
    wanted = _plain(title)
    surnames = {_plain(a).split(" ")[-1] for a in authors if _plain(a)}
    for found in candidates:
        author = cast(dict[str, Any], found.get("author") or {})
        text = str(found.get("title", ""))
        name = _plain(re.split(r"[:(]", text)[0])
        who = _plain(str(author.get("authorName", "")))
        if (name == wanted or _same_volume(title, text)) and (
            not surnames or any(s in who for s in surnames)
        ):
            return found
    return None


class ChaptarrClient:
    def __init__(self, base_url: str, api_key: str, client: httpx.AsyncClient | None = None):
        self._base = base_url.strip().rstrip("/")
        self._headers = {"X-Api-Key": api_key}
        self._client = client or httpx.AsyncClient(timeout=30)

    async def _call(
        self,
        method: str,
        path: str,
        json: object | None = None,
        params: dict[str, str] | None = None,
    ) -> Any:
        try:
            response = await self._client.request(
                method,
                f"{self._base}/api/v1/{path}",
                json=json,
                params=params,
                headers=self._headers,
            )
        except httpx.HTTPError as error:
            raise ChaptarrError("unreachable") from error
        if response.status_code in (401, 403):
            raise ChaptarrError("unauthorized")
        if response.status_code >= 400:
            raise ChaptarrError(f"status {response.status_code}")
        try:
            return response.json()
        except ValueError as error:  # an address that answers, but is not Chaptarr's API
            raise ChaptarrError("not_chaptarr") from error

    async def lookup(self, title: str, authors: tuple[str, ...]) -> dict[str, Any] | None:
        """Searches the title alone first (adding the author buries the novel under books about
        it), then with the author."""
        terms = [title]
        if guess := guess_series(title):  # "Homunculus 3": Chaptarr may say "Homunculus, Band 3"
            terms.append(f"{guess.series} {guess.number:g}")
        if authors:
            terms.append(f"{title} {authors[0]}")
        for term in terms:
            found = cast(
                list[dict[str, Any]], await self._call("GET", "book/lookup", params={"term": term})
            )
            if match := best_match(found, title, authors):
                return match
        return None

    async def _first_id(self, path: str, profile_type: str | int) -> int:
        profiles = cast(list[dict[str, Any]], await self._call("GET", path))
        for profile in profiles:
            if profile.get("profileType") == profile_type:
                return int(profile["id"])
        raise ChaptarrError(f"no {path}")

    async def add(self, book: dict[str, Any]) -> int:
        """Adds the book as an ebook, watches it and starts the search; returns its book id."""
        quality = await self._first_id("qualityprofile", EBOOK_QUALITY)
        metadata = await self._first_id("metadataprofile", 2)  # 2 is the ebook type
        roots = cast(list[dict[str, Any]], await self._call("GET", "rootfolder"))
        root = next((r["path"] for r in roots if "ebook" in str(r.get("path", "")).lower()), None)
        if root is None:
            raise ChaptarrError("no ebook folder")
        book = {**book, "mediaType": "ebook", "monitored": True, "ebookMonitored": True}
        book["audiobookMonitored"] = False
        book["addOptions"] = {"searchForNewBook": True}
        author = dict(book.get("author") or {})
        author.update(
            monitored=True,
            lastSelectedMediaType="ebook",
            ebookQualityProfileId=quality,
            ebookMetadataProfileId=metadata,
            ebookRootFolderPath=root,
            qualityProfileId=quality,
            metadataProfileId=metadata,
            rootFolderPath=root,
        )
        book["author"] = author
        created = cast(dict[str, Any], await self._call("POST", "book", json=book))
        book_id = int(created["id"])
        # The root folder's "monitor" default (none) wins over the flag sent above: watch the
        # book and search for it explicitly.
        await self._call(
            "PUT",
            "book/monitor",
            json={"bookIds": [book_id], "monitored": True, "mediaType": "ebook"},
        )
        await self._call("POST", "command", json={"name": "BookSearch", "bookIds": [book_id]})
        return book_id

    async def check(self) -> None:
        """The address is a Chaptarr and the key is accepted; [ChaptarrError] otherwise."""
        status = cast(dict[str, Any], await self._call("GET", "system/status"))
        if "chaptarr" not in str(status.get("appName", "")).lower():
            raise ChaptarrError("not_chaptarr")

    async def has_files(self, book_id: int) -> bool:
        book = cast(dict[str, Any], await self._call("GET", f"book/{book_id}"))
        return bool(book.get("hasFiles"))

    async def aclose(self) -> None:
        await self._client.aclose()
