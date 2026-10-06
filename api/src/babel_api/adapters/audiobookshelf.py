"""Audiobookshelf's own API (2.26+): signing in, listing audiobooks, streaming, progress.

Babel signs in with an API key the reader made in Audiobookshelf, or once with the
reader's password: it then keeps only the refresh token Audiobookshelf hands to apps,
and rotates it. The password is never stored.
"""

from collections.abc import AsyncIterator
from dataclasses import dataclass
from typing import Any, cast

import httpx

from babel_api.adapters.sources.http import check_url, guarded_client
from babel_api.domain.errors import DomainError


class AbsError(DomainError):
    """Audiobookshelf refused or could not be reached; ``reason`` says why."""

    def __init__(self, reason: str) -> None:
        super().__init__(reason)
        self.reason = reason


class AbsUnauthorizedError(AbsError):
    def __init__(self) -> None:
        super().__init__("unauthorized")


@dataclass(frozen=True, slots=True)
class AbsTokens:
    access: str
    refresh: str | None  # None for an API key (it does not expire)
    username: str | None = None


@dataclass(frozen=True, slots=True)
class AbsLibrary:
    id: str
    name: str


@dataclass(frozen=True, slots=True)
class AbsBook:
    id: str
    title: str
    authors: tuple[str, ...]
    narrators: tuple[str, ...]
    series: str | None
    duration: float


@dataclass(frozen=True, slots=True)
class AbsTrack:
    index: int
    file_id: str  # the audio file's "ino"
    duration: float
    mime_type: str


@dataclass(frozen=True, slots=True)
class AbsChapter:
    title: str
    start: float
    end: float


@dataclass(frozen=True, slots=True)
class AbsBookDetail:
    book: AbsBook
    tracks: tuple[AbsTrack, ...]
    chapters: tuple[AbsChapter, ...]
    subjects: tuple[str, ...]


@dataclass(frozen=True, slots=True)
class AbsProgress:
    current_time: float
    duration: float
    finished: bool
    updated_ms: int


def _dict(value: object) -> dict[str, Any]:
    return cast(dict[str, Any], value) if isinstance(value, dict) else {}


def _list(value: object) -> list[Any]:
    return cast(list[Any], value) if isinstance(value, list) else []


def _names(value: object) -> tuple[str, ...]:
    if isinstance(value, str):
        return tuple(n.strip() for n in value.split(",") if n.strip())
    return tuple(str(_dict(v).get("name") or v).strip() for v in _list(value) if v)


def _book(item: dict[str, Any]) -> AbsBook:
    media = _dict(item.get("media"))
    meta = _dict(media.get("metadata"))
    series = meta.get("seriesName") or next(
        (str(_dict(s).get("name")) for s in _list(meta.get("series")) if _dict(s).get("name")),
        None,
    )
    return AbsBook(
        id=str(item.get("id", "")),
        title=str(meta.get("title") or "?"),
        authors=_names(meta.get("authorName") or meta.get("authors")),
        narrators=_names(meta.get("narratorName") or meta.get("narrators")),
        series=str(series) if series else None,
        duration=float(media.get("duration") or 0),
    )


class AbsClient:
    def __init__(
        self,
        base_url: str,
        client: httpx.AsyncClient | None = None,
        allowed_hosts: tuple[str, ...] = (),
    ) -> None:
        self.base_url = base_url.strip().rstrip("/")
        self._allowed = allowed_hosts
        self._client = client or guarded_client(allowed_hosts)

    async def aclose(self) -> None:
        await self._client.aclose()

    async def _call(
        self,
        method: str,
        path: str,
        token: str | None = None,
        *,
        json: object | None = None,
        params: dict[str, Any] | None = None,
        headers: dict[str, str] | None = None,
    ) -> httpx.Response:
        sent = dict(headers or {})
        if token:
            sent["Authorization"] = f"Bearer {token}"
        try:
            response = await self._client.request(
                method, f"{self.base_url}{path}", json=json, params=params, headers=sent
            )
        except httpx.HTTPError as error:
            raise AbsError("unreachable") from error
        if response.status_code == 401:
            raise AbsUnauthorizedError
        if response.status_code >= 400:
            raise AbsError(f"http {response.status_code}")
        return response

    async def check(self) -> str:
        """The server's version, after checking the address is allowed and answers."""
        await check_url(self.base_url, self._allowed)
        data = _dict((await self._call("GET", "/status")).json())
        if data.get("app") != "audiobookshelf":
            raise AbsError("not audiobookshelf")
        return str(data.get("serverVersion") or "")

    async def login(self, username: str, password: str) -> AbsTokens:
        response = await self._call(
            "POST",
            "/login",
            json={"username": username, "password": password},
            headers={"x-return-tokens": "true"},
        )
        user = _dict(_dict(response.json()).get("user"))
        access = user.get("accessToken") or user.get("token")
        if not access:
            raise AbsError("no token")
        return AbsTokens(str(access), user.get("refreshToken"), user.get("username"))

    async def refresh(self, refresh_token: str) -> AbsTokens:
        response = await self._call(
            "POST",
            "/auth/refresh",
            headers={"x-refresh-token": refresh_token, "x-return-tokens": "true"},
        )
        user = _dict(_dict(response.json()).get("user"))
        access = user.get("accessToken")
        if not access:
            raise AbsUnauthorizedError
        return AbsTokens(str(access), user.get("refreshToken") or refresh_token)

    async def me(self, token: str) -> str:
        return str(_dict((await self._call("GET", "/api/me", token)).json()).get("username", ""))

    async def libraries(self, token: str) -> list[AbsLibrary]:
        data = _dict((await self._call("GET", "/api/libraries", token)).json())
        return [
            AbsLibrary(str(lib["id"]), str(lib.get("name", "")))
            for lib in map(_dict, _list(data.get("libraries")))
            if lib.get("id") and lib.get("mediaType", "book") == "book"
        ]

    async def books(
        self, token: str, library_id: str, query: str | None, page: int, limit: int
    ) -> list[AbsBook]:
        if query:
            data = _dict(
                (
                    await self._call(
                        "GET",
                        f"/api/libraries/{library_id}/search",
                        token,
                        params={"q": query, "limit": limit},
                    )
                ).json()
            )
            found = [_dict(_dict(b).get("libraryItem")) for b in _list(data.get("book"))]
        else:
            data = _dict(
                (
                    await self._call(
                        "GET",
                        f"/api/libraries/{library_id}/items",
                        token,
                        params={
                            "limit": limit,
                            "page": page,
                            "sort": "media.metadata.title",
                            "minified": 1,
                        },
                    )
                ).json()
            )
            found = [_dict(r) for r in _list(data.get("results"))]
        return [_book(item) for item in found if item.get("id")]

    async def book(self, token: str, item_id: str) -> AbsBookDetail:
        item = _dict(
            (await self._call("GET", f"/api/items/{item_id}", token, params={"expanded": 1})).json()
        )
        media = _dict(item.get("media"))
        files = sorted(map(_dict, _list(media.get("audioFiles"))), key=lambda f: f.get("index", 0))
        tracks = tuple(
            AbsTrack(
                index=i,
                file_id=str(f.get("ino")),
                duration=float(f.get("duration") or 0),
                mime_type=str(f.get("mimeType") or "audio/mpeg"),
            )
            for i, f in enumerate(files)
            if f.get("ino") and not f.get("exclude")
        )
        chapters = tuple(
            AbsChapter(
                title=str(c.get("title") or ""),
                start=float(c.get("start") or 0),
                end=float(c.get("end") or 0),
            )
            for c in map(_dict, _list(media.get("chapters")))
        )
        meta = _dict(media.get("metadata"))
        subjects = tuple(str(g) for g in _list(meta.get("genres")) + _list(media.get("tags")))
        return AbsBookDetail(_book(item), tracks, chapters, subjects)

    async def progress(self, token: str, item_id: str) -> AbsProgress | None:
        try:
            data = _dict((await self._call("GET", f"/api/me/progress/{item_id}", token)).json())
        except AbsError as error:
            if error.reason == "http 404":
                return None
            raise
        return AbsProgress(
            current_time=float(data.get("currentTime") or 0),
            duration=float(data.get("duration") or 0),
            finished=bool(data.get("isFinished")),
            updated_ms=int(data.get("lastUpdate") or 0),
        )

    async def save_progress(
        self, token: str, item_id: str, current_time: float, duration: float, finished: bool
    ) -> None:
        await self._call(
            "PATCH",
            f"/api/me/progress/{item_id}",
            token,
            json={
                "currentTime": current_time,
                "duration": duration,
                "progress": min(1.0, current_time / duration) if duration else 0,
                "isFinished": finished,
            },
        )

    async def cover(self, token: str, item_id: str) -> tuple[bytes, str] | None:
        try:
            response = await self._call(
                "GET", f"/api/items/{item_id}/cover", token, params={"width": 600}
            )
        except AbsError:
            return None
        return response.content, response.headers.get("content-type", "image/jpeg")

    async def stream(
        self, token: str, item_id: str, file_id: str, range_header: str | None
    ) -> tuple[int, dict[str, str], AsyncIterator[bytes]]:
        """An audio file, as Audiobookshelf serves it (byte ranges included)."""
        request = self._client.build_request(
            "GET",
            f"{self.base_url}/api/items/{item_id}/file/{file_id}",
            headers={
                "Authorization": f"Bearer {token}",
                **({"Range": range_header} if range_header else {}),
            },
        )
        try:
            response = await self._client.send(request, stream=True)
        except httpx.HTTPError as error:
            raise AbsError("unreachable") from error
        if response.status_code == 401:
            await response.aclose()
            raise AbsUnauthorizedError
        if response.status_code >= 400:
            await response.aclose()
            raise AbsError(f"http {response.status_code}")
        kept = {
            k: v
            for k, v in response.headers.items()
            if k.lower()
            in ("content-type", "content-length", "content-range", "accept-ranges", "etag")
        }

        async def body() -> AsyncIterator[bytes]:
            try:
                async for chunk in response.aiter_bytes(64 * 1024):
                    yield chunk
            finally:
                await response.aclose()

        return response.status_code, kept, body()
