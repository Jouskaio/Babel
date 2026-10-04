"""Generic sources: any address serving a Babel source manifest (docs/source-manifest.md).

A manifest lists books with a file address each; pages are chained with ``next``.
"""

import hashlib
import json
from collections.abc import AsyncIterator
from typing import Any, cast
from urllib.parse import urljoin, urlsplit

import httpx

from babel_api.adapters.sources.http import book_format, check_url, guarded_client
from babel_api.domain.errors import SourceConnectionError
from babel_api.domain.sources import RemoteEntry

VERSION = 1
MAX_PAGES = 20
MAX_ENTRIES = 5000
MAX_PAGE_BYTES = 10 * 1024 * 1024


def _text(value: object) -> str | None:
    return value.strip() if isinstance(value, str) and value.strip() else None


class ManifestConnector:
    def __init__(
        self, client: httpx.AsyncClient | None = None, allowed_hosts: tuple[str, ...] = ()
    ) -> None:
        self._allowed = allowed_hosts
        self._client = client or guarded_client(allowed_hosts)

    def _headers(self, config: dict[str, Any], token: str | None, url: str) -> dict[str, str]:
        # The token only goes to the manifest's own host, never to a linked file host.
        same_host = urlsplit(url).hostname == urlsplit(str(config["url"])).hostname
        return {"Authorization": f"Bearer {token}"} if token and same_host else {}

    async def _page(
        self, config: dict[str, Any], token: str | None, url: str
    ) -> tuple[list[RemoteEntry], str | None]:
        try:
            response = await self._client.get(
                url,
                headers={"Accept": "application/json", **self._headers(config, token, url)},
            )
        except httpx.HTTPError as error:
            raise SourceConnectionError("unreachable") from error
        if response.status_code in (401, 403, 404):
            raise SourceConnectionError(str(response.status_code))
        if response.status_code >= 400 or len(response.content) > MAX_PAGE_BYTES:
            raise SourceConnectionError("unreachable")
        try:
            data: object = json.loads(response.content)
        except ValueError as error:
            raise SourceConnectionError("not_manifest") from error
        if not isinstance(data, dict):
            raise SourceConnectionError("not_manifest")
        manifest = cast(dict[str, Any], data)
        if manifest.get("babel_manifest") != VERSION:
            raise SourceConnectionError("not_manifest")
        base = str(response.url)
        books: object = manifest.get("books", [])
        entries: list[RemoteEntry] = []
        for raw in cast(list[object], books) if isinstance(books, list) else []:
            if not isinstance(raw, dict):
                continue
            book = cast(dict[str, Any], raw)
            book_id, link = _text(book.get("id")), _text(book.get("url"))
            if book_id is None or link is None or len(book_id) > 500:
                continue
            file_url = urljoin(base, link)
            fmt = _text(book.get("format"))
            fmt = fmt.lower() if fmt and fmt.lower() in ("epub", "pdf", "cbz", "cbr") else None
            authors_value: object = book.get("authors", [])
            authors = (
                tuple(a for a in (_text(x) for x in cast(list[object], authors_value)) if a)
                if isinstance(authors_value, list)
                else ()
            )
            size = book.get("size")
            version = f"{book_id}|{_text(book.get('updated')) or ''}|{file_url}"
            entries.append(
                RemoteEntry(
                    path=book_id,
                    size=size if isinstance(size, int) and size > 0 else 0,
                    remote_id=hashlib.sha256(version.encode()).hexdigest(),
                    title=_text(book.get("title")),
                    authors=authors[:5],
                    locator=file_url,
                    format=fmt or book_format(urlsplit(file_url).path),
                )
            )
        next_page = _text(manifest.get("next"))
        return entries, urljoin(base, next_page) if next_page else None

    async def check(self, config: dict[str, Any], token: str | None) -> dict[str, Any]:
        url = str(config.get("url", "")).strip()
        await check_url(url, self._allowed)
        checked = {"url": url}
        await self._page(checked, token, url)
        return checked

    async def list_entries(self, config: dict[str, Any], token: str | None) -> list[RemoteEntry]:
        url: str | None = str(config["url"])
        seen: set[str] = set()
        entries: dict[str, RemoteEntry] = {}
        while url and url not in seen and len(seen) < MAX_PAGES and len(entries) < MAX_ENTRIES:
            seen.add(url)
            page, url = await self._page(config, token, url)
            for entry in page:
                entries.setdefault(entry.path, entry)
        return list(entries.values())[:MAX_ENTRIES]

    async def fetch(
        self, config: dict[str, Any], token: str | None, entry: RemoteEntry
    ) -> AsyncIterator[bytes]:
        url = entry.locator or entry.path
        try:
            async with self._client.stream(
                "GET", url, headers=self._headers(config, token, url)
            ) as response:
                if response.status_code >= 400:
                    raise SourceConnectionError(str(response.status_code))
                async for chunk in response.aiter_bytes(1024 * 1024):
                    yield chunk
        except httpx.HTTPError as error:
            raise SourceConnectionError("unreachable") from error

    async def aclose(self) -> None:
        await self._client.aclose()
