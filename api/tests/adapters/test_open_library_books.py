import asyncio
from typing import Any

import httpx

from babel_api.adapters.catalog.open_library import OpenLibrarySource

WORK = {
    "title": "Jane Eyre",
    "covers": [8235363, 6519400],
    "first_publish_date": "1847",
    "description": {"type": "/type/text", "value": "A governess at Thornfield Hall."},
    "authors": [{"author": {"key": "/authors/OL1A"}}],
}
EDITION = {
    "key": "/books/OL10M",
    "works": [{"key": "/works/OL1W"}],
    "title": "Jane Eyre",
    "languages": [{"key": "/languages/fre"}],
    "publishers": ["Gallimard"],
    "publish_date": "2008",
    "number_of_pages": 640,
    "physical_format": "Paperback",
    "covers": [123],
    "isbn_10": ["2070360245"],
    "isbn_13": ["9782070360246"],
}


def handler(request: httpx.Request) -> httpx.Response:
    routes: dict[str, Any] = {
        "/search.json": {
            "docs": [
                {
                    "key": "/works/OL1W",
                    "title": "Jane Eyre",
                    "author_name": ["Charlotte Brontë"],
                    "first_publish_year": 1847,
                    "cover_i": 8235363,
                    "edition_count": 1170,
                },
                {"key": "/books/OL9M", "title": "Not a work"},
            ]
        },
        "/works/OL1W.json": WORK,
        "/authors/OL1A.json": {"name": "Charlotte Brontë"},
        "/works/OL1W/editions.json": {"entries": [EDITION]},
        "/isbn/9782070360246.json": EDITION,
    }
    body = routes.get(request.url.path)
    return httpx.Response(200, json=body) if body is not None else httpx.Response(404)


def source() -> OpenLibrarySource:
    return OpenLibrarySource(httpx.AsyncClient(transport=httpx.MockTransport(handler)))


def test_search_keeps_only_works() -> None:
    (work,) = asyncio.run(source().search("jane eyre", 5))

    assert work.open_library_id == "OL1W"
    assert work.authors == ("Charlotte Brontë",)
    assert work.edition_count == 1170


def test_work_details_resolve_author_names() -> None:
    work = asyncio.run(source().work("OL1W"))

    assert work is not None
    assert work.authors == ("Charlotte Brontë",)
    assert work.description == "A governess at Thornfield Hall."
    assert work.first_publish_year == 1847
    assert work.cover_id == 8235363


def test_editions_are_normalized() -> None:
    (edition,) = asyncio.run(source().editions("OL1W", 10))

    assert edition.language == "fr"
    assert edition.publisher == "Gallimard"
    assert edition.page_count == 640
    assert edition.isbn13 == ("9782070360246",)


def test_unknown_isbns_and_works_are_none() -> None:
    assert asyncio.run(source().edition_by_isbn("9780306406157")) is None
    assert asyncio.run(source().work("OL404W")) is None
    edition = asyncio.run(source().edition_by_isbn("9782070360246"))
    assert edition is not None
    assert edition.work_open_library_id == "OL1W"
