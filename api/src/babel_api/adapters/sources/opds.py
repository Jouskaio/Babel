"""OPDS catalogs (Calibre-Web, Kavita, Komga, COPS…): OPDS 1.2 (Atom) and OPDS 2 (JSON).

The catalog is crawled breadth-first from the address given by the reader: navigation
links and next pages are followed, within limits, and every acquisition link to a book
file becomes an entry (the same file reached from several feeds counts once).
"""

import hashlib
import json
import re
from collections.abc import AsyncIterator, Iterator
from typing import Any, cast
from urllib.parse import urljoin, urlsplit

import httpx
from defusedxml import ElementTree

from babel_api.adapters.sources.http import book_format, check_url, guarded_client
from babel_api.domain.errors import SourceConnectionError
from babel_api.domain.sources import RemoteEntry

_ATOM = "{http://www.w3.org/2005/Atom}"
_ACQUISITION = "http://opds-spec.org/acquisition"
# Preferred format when an entry offers several.
_PREFERENCE = {"epub": 0, "cbz": 1, "pdf": 2, "cbr": 3}
# Kavita and Komga give each series its own feed: room for a few hundred series.
MAX_FEEDS = 300
MAX_ENTRIES = 5000
MAX_FEED_BYTES = 10 * 1024 * 1024
# Kavita puts the reader's key in every OPDS address (/api/opds/<key>/...). The key is kept
# encrypted as the source token, and addresses are stored with this placeholder instead.
KEY = "{key}"
_PATH_KEY = re.compile(r"/api/opds/([A-Za-z0-9-]{16,})")


def extract_secret(config: dict[str, Any]) -> tuple[dict[str, Any], str | None]:
    """Takes a key out of the catalog address (Kavita): (config to store, the key)."""
    url = str(config.get("url", "")).strip()
    match = _PATH_KEY.search(url)
    if match is None:
        return config, None
    return {**config, "url": url.replace(match.group(1), KEY)}, match.group(1)


def _remote_id(url: str, version: str | None) -> str:
    return hashlib.sha256(f"{url}|{version or ''}".encode()).hexdigest()


class _Feed:
    """What one feed page holds: books, and more feeds to visit."""

    def __init__(self) -> None:
        self.entries: list[RemoteEntry] = []
        self.feeds: list[str] = []


def _best(links: Iterator[tuple[str, str | None, int]]) -> tuple[str, str, int] | None:
    """The preferred acquisition link: (absolute URL, format, size)."""
    found = [
        (url, fmt, size)
        for url, media_type, size in links
        if (fmt := book_format(urlsplit(url).path, media_type)) is not None
    ]
    return min(found, key=lambda link: _PREFERENCE[link[1]]) if found else None


def _entry(
    best: tuple[str, str, int] | None, title: str | None, authors: list[str], version: str | None
) -> RemoteEntry | None:
    if best is None or len(best[0]) > 1000:
        return None
    url, fmt, size = best
    return RemoteEntry(
        path=url,
        size=size,
        remote_id=_remote_id(url, version),
        title=title,
        authors=tuple(authors[:5]),
        locator=url,
        format=fmt,
    )


def _parse_atom(content: bytes, base: str) -> _Feed:
    try:
        root = ElementTree.fromstring(content)
    except (ElementTree.ParseError, ValueError) as error:
        raise SourceConnectionError("not_opds") from error
    if root.tag != f"{_ATOM}feed":
        raise SourceConnectionError("not_opds")
    feed = _Feed()
    for link in root.iterfind(f"{_ATOM}link"):
        if link.get("rel") == "next" and link.get("href"):
            feed.feeds.append(urljoin(base, link.get("href")))
    for item in root.iterfind(f"{_ATOM}entry"):
        links = item.findall(f"{_ATOM}link")
        acquisitions = (
            (urljoin(base, link.get("href")), link.get("type"), int(link.get("length") or 0))
            for link in links
            if (link.get("rel") or "").startswith(_ACQUISITION) and link.get("href")
        )
        title = item.findtext(f"{_ATOM}title")
        authors = [
            name.strip()
            for author in item.iterfind(f"{_ATOM}author")
            if (name := author.findtext(f"{_ATOM}name"))
        ]
        found = _entry(_best(acquisitions), title, authors, item.findtext(f"{_ATOM}updated"))
        if found is not None:
            feed.entries.append(found)
            continue
        # A navigation entry: follow its catalog links.
        for link in links:
            media_type = link.get("type") or ""
            if link.get("href") and "opds-catalog" in media_type:
                feed.feeds.append(urljoin(base, link.get("href")))
    return feed


def _dicts(value: object) -> list[dict[str, Any]]:
    """The JSON objects of a list (anything else is ignored)."""
    if not isinstance(value, list):
        return []
    return [cast(dict[str, Any], v) for v in cast(list[object], value) if isinstance(v, dict)]


def _text(value: object) -> str | None:
    return str(value) if isinstance(value, (str, int, float)) and str(value).strip() else None


def _names(value: object) -> list[str]:
    """OPDS 2 contributors: a name, an object with a name, or a list of those."""
    items: list[object] = cast(list[object], value) if isinstance(value, list) else [value]
    names: list[str] = []
    for item in items:
        name = (
            _text(cast(dict[str, Any], item).get("name")) if isinstance(item, dict) else _text(item)
        )
        if name:
            names.append(name)
    return names


def _parse_json(content: bytes, base: str) -> _Feed:
    try:
        data: object = json.loads(content)
    except ValueError as error:
        raise SourceConnectionError("not_opds") from error
    if not isinstance(data, dict):
        raise SourceConnectionError("not_opds")
    root = cast(dict[str, Any], data)
    if not ({"publications", "navigation", "groups"} & root.keys()):
        raise SourceConnectionError("not_opds")
    feed = _Feed()
    for link in _dicts(root.get("links")):
        href = _text(link.get("href"))
        if link.get("rel") == "next" and href:
            feed.feeds.append(urljoin(base, href))
    for group in [root, *_dicts(root.get("groups"))]:
        for nav in _dicts(group.get("navigation")):
            if href := _text(nav.get("href")):
                feed.feeds.append(urljoin(base, href))
        for publication in _dicts(group.get("publications")):
            metadata_value: object = publication.get("metadata")
            metadata = (
                cast(dict[str, Any], metadata_value) if isinstance(metadata_value, dict) else {}
            )
            acquisitions = [
                (urljoin(base, href), _text(link.get("type")), 0)
                for link in _dicts(publication.get("links"))
                if (_text(link.get("rel")) or "").startswith(_ACQUISITION)
                and (href := _text(link.get("href")))
            ]
            found = _entry(
                _best(iter(acquisitions)),
                _text(metadata.get("title")),
                _names(metadata.get("author")),
                _text(metadata.get("modified")),
            )
            if found is not None:
                feed.entries.append(found)
    return feed


def _one_per_book(entries: list[RemoteEntry]) -> list[RemoteEntry]:
    """Some catalogs list each format as its own entry: keep the preferred one per book."""
    best: dict[tuple[str, tuple[str, ...]] | str, RemoteEntry] = {}
    for entry in entries:
        key = (entry.title.casefold(), entry.authors) if entry.title else entry.path
        current = best.get(key)
        if (
            current is None
            or _PREFERENCE[entry.format or "cbr"] < _PREFERENCE[current.format or "cbr"]
        ):
            best[key] = entry
    return list(best.values())


class OpdsConnector:
    def __init__(
        self, client: httpx.AsyncClient | None = None, allowed_hosts: tuple[str, ...] = ()
    ) -> None:
        self._allowed = allowed_hosts
        self._client = client or guarded_client(allowed_hosts)

    @staticmethod
    def extract_secret(config: dict[str, Any]) -> tuple[dict[str, Any], str | None]:
        return extract_secret(config)

    @staticmethod
    def _real(url: str, token: str | None) -> str:
        """The address to request: the key put back in place of its placeholder."""
        return url.replace(KEY, token) if token and KEY in url else url

    def _auth(self, config: dict[str, Any], token: str | None, url: str) -> httpx.Auth | None:
        # Credentials only go to the catalog's own host, never to a linked site.
        username = config.get("username")
        if KEY in str(config["url"]):
            return None  # the key travels in the address
        same_host = urlsplit(url).hostname == urlsplit(str(config["url"])).hostname
        return httpx.BasicAuth(username, token) if username and token and same_host else None

    async def _feed(self, config: dict[str, Any], token: str | None, url: str) -> _Feed:
        keyed = KEY in str(config["url"]) and token is not None
        try:
            response = await self._client.get(
                self._real(url, token if keyed else None),
                auth=self._auth(config, token, url),
                headers={"Accept": "application/atom+xml, application/opds+json;q=0.9, */*;q=0.5"},
            )
        except httpx.HTTPError as error:
            raise SourceConnectionError("unreachable") from error
        if response.status_code in (401, 403, 404):
            raise SourceConnectionError(str(response.status_code))
        if response.status_code >= 400 or len(response.content) > MAX_FEED_BYTES:
            raise SourceConnectionError("unreachable")
        content_type = response.headers.get("content-type", "")
        content, base = response.content, str(response.url)
        if keyed and token:
            # Every link of the feed carries the key: store them with the placeholder.
            content = content.replace(token.encode(), KEY.encode())
            base = base.replace(token, KEY)
        is_json = "json" in content_type or content.lstrip().startswith(b"{")
        return _parse_json(content, base) if is_json else _parse_atom(content, base)

    async def check(self, config: dict[str, Any], token: str | None) -> dict[str, Any]:
        url = str(config.get("url", "")).strip()
        await check_url(url, self._allowed)
        username = str(config.get("username") or "").strip() or None
        checked = {"url": url, "username": username}
        await self._feed(checked, token, url)
        return checked

    async def list_entries(self, config: dict[str, Any], token: str | None) -> list[RemoteEntry]:
        queue, seen_feeds = [str(config["url"])], set[str]()
        entries: dict[str, RemoteEntry] = {}
        while queue and len(seen_feeds) < MAX_FEEDS and len(entries) < MAX_ENTRIES:
            url = queue.pop(0)
            if url in seen_feeds:
                continue
            seen_feeds.add(url)
            try:
                feed = await self._feed(config, token, url)
            except SourceConnectionError:
                if len(seen_feeds) == 1:
                    raise  # the catalog itself is unreachable
                continue  # one broken sub-feed does not spoil the scan
            for entry in feed.entries:
                entries.setdefault(entry.path, entry)
            queue.extend(f for f in feed.feeds if f not in seen_feeds)
        return _one_per_book(list(entries.values()))[:MAX_ENTRIES]

    async def fetch(
        self, config: dict[str, Any], token: str | None, entry: RemoteEntry
    ) -> AsyncIterator[bytes]:
        url = entry.locator or entry.path
        try:
            async with self._client.stream(
                "GET", self._real(url, token), auth=self._auth(config, token, url)
            ) as response:
                if response.status_code >= 400:
                    raise SourceConnectionError(str(response.status_code))
                async for chunk in response.aiter_bytes(1024 * 1024):
                    yield chunk
        except httpx.HTTPError as error:
            raise SourceConnectionError("unreachable") from error

    async def aclose(self) -> None:
        await self._client.aclose()
