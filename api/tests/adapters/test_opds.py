import asyncio
import json

import httpx
import pytest

from babel_api.adapters.sources.opds import OpdsConnector
from babel_api.domain.errors import SourceAddressBlockedError, SourceConnectionError
from babel_api.domain.sources import RemoteEntry

ROOT = "https://books.example.com/opds"
ACQ = "http://opds-spec.org/acquisition"


def atom(entries: str, links: str = "") -> str:
    return (
        '<?xml version="1.0"?><feed xmlns="http://www.w3.org/2005/Atom">'
        f"<title>Catalog</title>{links}{entries}</feed>"
    )


NAVIGATION = atom(
    "<entry><title>By author</title><id>nav1</id>"
    '<link type="application/atom+xml;profile=opds-catalog;kind=acquisition" href="/opds/new"/>'
    "</entry>"
)
NEW_PAGE_1 = atom(
    "<entry><title>Jane Eyre</title><author><name>Charlotte Brontë</name></author>"
    "<updated>2026-10-01T10:00:00Z</updated>"
    f'<link rel="{ACQ}" type="application/pdf" href="/get/1.pdf" length="5000"/>'
    f'<link rel="{ACQ}" type="application/epub+zip" href="/get/1.epub" length="1200"/>'
    "</entry>",
    '<link rel="next" href="/opds/new?page=2"/>',
)
NEW_PAGE_2 = atom(
    "<entry><title>Persepolis</title><author><name>Marjane Satrapi</name></author>"
    f'<link rel="{ACQ}/open-access" type="application/vnd.comicbook+zip" href="/get/2.cbz"/>'
    "</entry>"
    # The same book reached again: listed once.
    f'<entry><title>Jane Eyre</title><link rel="{ACQ}" type="application/epub+zip" '
    'href="/get/1.epub"/></entry>'
    # Not a book file.
    f'<entry><title>Audio</title><link rel="{ACQ}" type="audio/mpeg" href="/get/3.mp3"/>'
    "</entry>"
)


def catalog(
    pages: dict[str, tuple[int, str, str]], seen: list[httpx.Request] | None = None
) -> OpdsConnector:
    def handler(request: httpx.Request) -> httpx.Response:
        if seen is not None:
            seen.append(request)
        status, content_type, body = pages.get(str(request.url), (404, "text/plain", "missing"))
        return httpx.Response(status, headers={"content-type": content_type}, text=body)

    return OpdsConnector(
        httpx.AsyncClient(transport=httpx.MockTransport(handler)),
        allowed_hosts=("books.example.com",),
    )


ATOM = "application/atom+xml"
PAGES = {
    ROOT: (200, ATOM, NAVIGATION),
    "https://books.example.com/opds/new": (200, ATOM, NEW_PAGE_1),
    "https://books.example.com/opds/new?page=2": (200, ATOM, NEW_PAGE_2),
}


def test_check_accepts_catalogs_and_normalizes() -> None:
    config = asyncio.run(catalog(PAGES).check({"url": f" {ROOT} ", "username": ""}, None))
    assert config == {"url": ROOT, "username": None}


def test_check_refuses_pages_that_are_not_catalogs() -> None:
    pages = {ROOT: (200, "text/html", "<html><body>Hello</body></html>")}
    with pytest.raises(SourceConnectionError):
        asyncio.run(catalog(pages).check({"url": ROOT}, None))


def test_check_refuses_private_addresses() -> None:
    with pytest.raises(SourceAddressBlockedError):
        asyncio.run(OpdsConnector().check({"url": "http://192.168.1.10/opds"}, None))


def test_navigation_and_pages_are_followed() -> None:
    entries = asyncio.run(catalog(PAGES).list_entries({"url": ROOT}, None))
    by_title = {e.title: e for e in entries}
    assert set(by_title) == {"Jane Eyre", "Persepolis"}
    jane = by_title["Jane Eyre"]
    # EPUB is preferred over PDF.
    assert jane.locator == "https://books.example.com/get/1.epub"
    assert jane.format == "epub"
    assert jane.size == 1200
    assert jane.authors == ("Charlotte Brontë",)
    assert by_title["Persepolis"].format == "cbz"


def test_a_new_version_gets_a_new_id() -> None:
    first = asyncio.run(catalog(PAGES).list_entries({"url": ROOT}, None))
    updated = dict(PAGES)
    updated["https://books.example.com/opds/new"] = (
        200,
        ATOM,
        NEW_PAGE_1.replace("2026-10-01", "2026-10-02"),
    )
    second = asyncio.run(catalog(updated).list_entries({"url": ROOT}, None))

    def jane(entries: list[RemoteEntry]) -> str:
        return next(e.remote_id for e in entries if e.title == "Jane Eyre")

    assert jane(first) != jane(second)


def test_credentials_only_go_to_the_catalog_host() -> None:
    seen: list[httpx.Request] = []
    pages = {
        ROOT: (
            200,
            ATOM,
            atom(
                f'<entry><title>Elsewhere</title><link rel="{ACQ}" type="application/epub+zip" '
                'href="https://cdn.other.net/book.epub"/></entry>'
            ),
        ),
        "https://cdn.other.net/book.epub": (200, "application/epub+zip", "epub"),
    }
    connector = catalog(pages, seen)
    config = {"url": ROOT, "username": "ada"}
    entries = asyncio.run(connector.list_entries(config, "secret"))

    async def download() -> bytes:
        return b"".join([c async for c in connector.fetch(config, "secret", entries[0])])

    assert asyncio.run(download()) == b"epub"
    assert "Authorization" in seen[0].headers
    assert "Authorization" not in seen[1].headers


def test_wrong_credentials_are_reported() -> None:
    with pytest.raises(SourceConnectionError, match="401"):
        asyncio.run(catalog({ROOT: (401, "text/plain", "no")}).check({"url": ROOT}, "x"))


def test_opds2_json_catalogs() -> None:
    feed = {
        "metadata": {"title": "Kavita"},
        "navigation": [{"href": "/opds2/more", "type": "application/opds+json"}],
        "publications": [
            {
                "metadata": {"title": "Emma", "author": [{"name": "Jane Austen"}]},
                "links": [{"rel": ACQ, "href": "/b/emma.epub", "type": "application/epub+zip"}],
            }
        ],
    }
    more = {
        "publications": [
            {
                "metadata": {"title": "Dune", "author": "Frank Herbert"},
                "links": [{"rel": ACQ, "href": "/b/dune.pdf", "type": "application/pdf"}],
            }
        ]
    }
    pages = {
        ROOT: (200, "application/opds+json", json.dumps(feed)),
        "https://books.example.com/opds2/more": (200, "application/opds+json", json.dumps(more)),
    }
    entries = asyncio.run(catalog(pages).list_entries({"url": ROOT}, None))
    assert sorted((e.title, e.authors, e.format) for e in entries) == [
        ("Dune", ("Frank Herbert",), "pdf"),
        ("Emma", ("Jane Austen",), "epub"),
    ]


def test_formats_listed_as_separate_entries_count_once() -> None:
    pages = {
        ROOT: (
            200,
            ATOM,
            atom(
                "<entry><title>Emma</title><author><name>Jane Austen</name></author>"
                f'<link rel="{ACQ}" type="application/pdf" href="/emma.pdf"/></entry>'
                "<entry><title>Emma</title><author><name>Jane Austen</name></author>"
                f'<link rel="{ACQ}" type="application/epub+zip" href="/emma.epub"/></entry>'
            ),
        )
    }
    entries = asyncio.run(catalog(pages).list_entries({"url": ROOT}, None))
    assert [(e.title, e.format) for e in entries] == [("Emma", "epub")]
