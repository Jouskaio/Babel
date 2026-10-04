import asyncio

import httpx
import pytest

from babel_api.adapters.sources.webdav import WebDavConnector
from babel_api.domain.errors import SourceConnectionError

ROOT = "https://cloud.example.com/remote.php/dav/files/ada/Livres/"


def response(href: str, *, folder: bool = False, size: int = 0, etag: str = "") -> str:
    kind = "<d:collection/>" if folder else ""
    props = "" if folder else f"<d:getcontentlength>{size}</d:getcontentlength>"
    props += f"<d:getetag>{etag}</d:getetag>" if etag else ""
    return (
        f"<d:response><d:href>{href}</d:href><d:propstat><d:prop>"
        f"<d:resourcetype>{kind}</d:resourcetype>{props}</d:prop>"
        "<d:status>HTTP/1.1 200 OK</d:status></d:propstat></d:response>"
    )


def multistatus(*responses: str) -> str:
    return (
        f'<?xml version="1.0"?><d:multistatus xmlns:d="DAV:">{"".join(responses)}</d:multistatus>'
    )


BASE = "/remote.php/dav/files/ada/Livres/"
LISTINGS = {
    (ROOT, "0"): multistatus(response(BASE, folder=True)),
    (ROOT, "1"): multistatus(
        response(BASE, folder=True),
        response(f"{BASE}Jane%20Eyre.epub", size=1200, etag='"e1"'),
        response(f"{BASE}notes.txt", size=10),
        response(f"{BASE}BD/", folder=True),
    ),
    (f"{ROOT}BD/", "1"): multistatus(
        response(f"{BASE}BD/", folder=True),
        response(f"{BASE}BD/Persepolis.cbz", size=3400, etag='"e2"'),
    ),
}


def dav(seen: list[httpx.Request] | None = None) -> WebDavConnector:
    def handler(request: httpx.Request) -> httpx.Response:
        if seen is not None:
            seen.append(request)
        if request.method == "GET":
            return httpx.Response(200, content=b"book bytes")
        body = LISTINGS.get((str(request.url), request.headers.get("Depth", "")))
        if body is None:
            return httpx.Response(404)
        if request.headers.get("Authorization") is None:
            return httpx.Response(401)
        return httpx.Response(207, text=body, headers={"content-type": "application/xml"})

    return WebDavConnector(
        httpx.AsyncClient(transport=httpx.MockTransport(handler)),
        allowed_hosts=("cloud.example.com",),
    )


CONFIG = {"url": ROOT, "username": "ada"}


def test_check_needs_a_folder_and_credentials() -> None:
    assert asyncio.run(dav().check({"url": ROOT.rstrip("/"), "username": "ada"}, "pw")) == CONFIG
    with pytest.raises(SourceConnectionError, match="401"):
        asyncio.run(dav().check({"url": ROOT}, None))


def test_books_are_listed_in_every_folder() -> None:
    entries = asyncio.run(dav().list_entries(CONFIG, "pw"))
    assert sorted((e.path, e.size, e.format) for e in entries) == [
        ("BD/Persepolis.cbz", 3400, "cbz"),
        ("Jane Eyre.epub", 1200, "epub"),
    ]
    assert {e.name for e in entries} == {"Persepolis.cbz", "Jane Eyre.epub"}


def test_files_are_downloaded_with_the_credentials() -> None:
    seen: list[httpx.Request] = []
    connector = dav(seen)
    entry = next(e for e in asyncio.run(connector.list_entries(CONFIG, "pw")) if e.format == "epub")

    async def download() -> bytes:
        return b"".join([c async for c in connector.fetch(CONFIG, "pw", entry)])

    assert asyncio.run(download()) == b"book bytes"
    assert str(seen[-1].url) == f"{ROOT}Jane%20Eyre.epub"
    assert seen[-1].headers["Authorization"].startswith("Basic ")
