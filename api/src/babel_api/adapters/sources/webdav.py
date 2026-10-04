"""WebDAV folders (Nextcloud, ownCloud, NAS): book files listed folder by folder."""

import hashlib
from collections.abc import AsyncIterator
from typing import Any
from urllib.parse import unquote, urljoin, urlsplit

import httpx
from defusedxml import ElementTree

from babel_api.adapters.sources.http import book_format, check_url, guarded_client
from babel_api.domain.errors import SourceConnectionError
from babel_api.domain.sources import RemoteEntry

_DAV = "{DAV:}"
_PROPFIND = (
    b'<?xml version="1.0"?><d:propfind xmlns:d="DAV:"><d:prop><d:resourcetype/>'
    b"<d:getcontentlength/><d:getetag/><d:getlastmodified/><d:getcontenttype/></d:prop>"
    b"</d:propfind>"
)
MAX_FOLDERS = 300
MAX_ENTRIES = 5000
MAX_LISTING_BYTES = 20 * 1024 * 1024


def _folder_url(url: str) -> str:
    return url if url.endswith("/") else f"{url}/"


class WebDavConnector:
    def __init__(
        self, client: httpx.AsyncClient | None = None, allowed_hosts: tuple[str, ...] = ()
    ) -> None:
        self._allowed = allowed_hosts
        self._client = client or guarded_client(allowed_hosts)

    def _auth(self, config: dict[str, Any], token: str | None, url: str) -> httpx.Auth | None:
        username = config.get("username")
        same_host = urlsplit(url).hostname == urlsplit(str(config["url"])).hostname
        return httpx.BasicAuth(username, token or "") if username and same_host else None

    async def _propfind(
        self, config: dict[str, Any], token: str | None, url: str, depth: str
    ) -> list[tuple[str, dict[str, str], bool]]:
        """(absolute URL, properties, is a folder) for the folder and its children."""
        try:
            response = await self._client.request(
                "PROPFIND",
                url,
                content=_PROPFIND,
                headers={"Depth": depth, "Content-Type": "application/xml"},
                auth=self._auth(config, token, url),
            )
        except httpx.HTTPError as error:
            raise SourceConnectionError("unreachable") from error
        if response.status_code in (401, 403, 404, 405):
            raise SourceConnectionError(str(response.status_code))
        if response.status_code != 207 or len(response.content) > MAX_LISTING_BYTES:
            raise SourceConnectionError("not_webdav")
        try:
            root = ElementTree.fromstring(response.content)
        except (ElementTree.ParseError, ValueError) as error:
            raise SourceConnectionError("not_webdav") from error
        found: list[tuple[str, dict[str, str], bool]] = []
        for item in root.iterfind(f"{_DAV}response"):
            href = item.findtext(f"{_DAV}href")
            if not href:
                continue
            props: dict[str, str] = {}
            folder = False
            for prop in item.iterfind(f"{_DAV}propstat/{_DAV}prop"):
                for child in prop:
                    name = str(child.tag).removeprefix(_DAV)
                    if name == "resourcetype":
                        folder = folder or child.find(f"{_DAV}collection") is not None
                    elif child.text:
                        props[name] = child.text.strip()
            found.append((urljoin(str(response.url), href), props, folder))
        return found

    async def check(self, config: dict[str, Any], token: str | None) -> dict[str, Any]:
        url = _folder_url(str(config.get("url", "")).strip())
        await check_url(url, self._allowed)
        username = str(config.get("username") or "").strip() or None
        checked = {"url": url, "username": username}
        listing = await self._propfind(checked, token, url, "0")
        if not listing or not listing[0][2]:
            raise SourceConnectionError("not_a_folder")
        return checked

    async def list_entries(self, config: dict[str, Any], token: str | None) -> list[RemoteEntry]:
        root = _folder_url(str(config["url"]))
        root_path = unquote(urlsplit(root).path)
        queue, seen = [root], set[str]()
        entries: list[RemoteEntry] = []
        while queue and len(seen) < MAX_FOLDERS and len(entries) < MAX_ENTRIES:
            folder = queue.pop(0)
            if folder in seen:
                continue
            seen.add(folder)
            try:
                listing = await self._propfind(config, token, folder, "1")
            except SourceConnectionError:
                if folder == root:
                    raise
                continue
            for url, props, is_folder in listing:
                if url.rstrip("/") == folder.rstrip("/"):
                    continue  # the folder itself
                if is_folder:
                    queue.append(_folder_url(url))
                    continue
                path = unquote(urlsplit(url).path)
                fmt = book_format(path, props.get("getcontenttype"))
                if fmt is None or not path.startswith(root_path) or len(path) > 1000:
                    continue
                version = props.get("getetag") or props.get("getlastmodified") or ""
                entries.append(
                    RemoteEntry(
                        path=path.removeprefix(root_path),
                        size=int(props.get("getcontentlength") or 0),
                        remote_id=hashlib.sha256(f"{url}|{version}".encode()).hexdigest(),
                        locator=url,
                        format=fmt,
                    )
                )
        return entries[:MAX_ENTRIES]

    async def fetch(
        self, config: dict[str, Any], token: str | None, entry: RemoteEntry
    ) -> AsyncIterator[bytes]:
        url = entry.locator or urljoin(_folder_url(str(config["url"])), entry.path)
        try:
            async with self._client.stream(
                "GET", url, auth=self._auth(config, token, url)
            ) as response:
                if response.status_code >= 400:
                    raise SourceConnectionError(str(response.status_code))
                async for chunk in response.aiter_bytes(1024 * 1024):
                    yield chunk
        except httpx.HTTPError as error:
            raise SourceConnectionError("unreachable") from error

    async def aclose(self) -> None:
        await self._client.aclose()
