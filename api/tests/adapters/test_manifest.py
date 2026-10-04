import asyncio
import json

import httpx
import pytest

from babel_api.adapters.sources.manifest import ManifestConnector
from babel_api.domain.errors import SourceConnectionError

ROOT = "https://shelf.example.com/babel/manifest.json"
PAGE_1 = {
    "babel_manifest": 1,
    "title": "My shelf",
    "books": [
        {
            "id": "jane",
            "title": "Jane Eyre",
            "authors": ["Charlotte Brontë"],
            "url": "files/jane.epub",
            "size": 1200,
            "updated": "2026-10-01",
        },
        {"id": "comic", "url": "https://cdn.example.net/one.cbz"},
        {"title": "no id"},
        "not a book",
    ],
    "next": "page-2.json",
}
PAGE_2 = {
    "babel_manifest": 1,
    "books": [{"id": "dune", "title": "Dune", "url": "/b/dune", "format": "PDF"}],
}


def connector(seen: list[httpx.Request] | None = None, pages: dict[str, object] | None = None):
    content = pages or {ROOT: PAGE_1, "https://shelf.example.com/babel/page-2.json": PAGE_2}

    def handler(request: httpx.Request) -> httpx.Response:
        if seen is not None:
            seen.append(request)
        url = str(request.url)
        if url in content:
            return httpx.Response(200, text=json.dumps(content[url]))
        if url.endswith((".epub", ".cbz")):
            return httpx.Response(200, content=b"book")
        return httpx.Response(404)

    return ManifestConnector(
        httpx.AsyncClient(transport=httpx.MockTransport(handler)),
        allowed_hosts=("shelf.example.com",),
    )


def test_manifests_are_listed_page_by_page() -> None:
    entries = asyncio.run(connector().list_entries({"url": ROOT}, None))
    assert [(e.path, e.title, e.format) for e in entries] == [
        ("jane", "Jane Eyre", "epub"),
        ("comic", None, "cbz"),
        ("dune", "Dune", "pdf"),
    ]
    jane = entries[0]
    assert jane.locator == "https://shelf.example.com/babel/files/jane.epub"
    assert (jane.size, jane.authors) == (1200, ("Charlotte Brontë",))


def test_a_new_version_gets_a_new_id() -> None:
    first = asyncio.run(connector().list_entries({"url": ROOT}, None))[0]
    changed = json.loads(json.dumps(PAGE_1))
    changed["books"][0]["updated"] = "2026-10-02"
    del changed["next"]
    second = asyncio.run(connector(pages={ROOT: changed}).list_entries({"url": ROOT}, None))[0]
    assert first.remote_id != second.remote_id


def test_pages_that_are_not_manifests_are_refused() -> None:
    with pytest.raises(SourceConnectionError):
        asyncio.run(connector(pages={ROOT: {"books": []}}).check({"url": ROOT}, None))


def test_the_token_only_goes_to_the_manifest_host() -> None:
    seen: list[httpx.Request] = []
    feed = connector(seen)
    config = {"url": ROOT}
    entries = asyncio.run(feed.list_entries(config, "secret"))

    async def download(index: int) -> bytes:
        return b"".join([c async for c in feed.fetch(config, "secret", entries[index])])

    assert asyncio.run(download(0)) == b"book"
    assert asyncio.run(download(1)) == b"book"
    by_host = {r.url.host: r.headers.get("Authorization") for r in seen}
    assert by_host["shelf.example.com"] == "Bearer secret"
    assert by_host["cdn.example.net"] is None
