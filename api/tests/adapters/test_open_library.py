import asyncio

import httpx

from babel_api.adapters.catalog.open_library import OpenLibrarySource


def source(handler: httpx.MockTransport) -> OpenLibrarySource:
    return OpenLibrarySource(httpx.AsyncClient(transport=handler))


def test_trending_skips_works_without_cover() -> None:
    def handle(request: httpx.Request) -> httpx.Response:
        assert request.url.path == "/trending/weekly.json"
        return httpx.Response(
            200,
            json={
                "works": [
                    {"key": "/works/OL1W", "title": "No cover"},
                    {
                        "key": "/works/OL2W",
                        "title": "Jane Eyre",
                        "author_name": ["Charlotte Brontë"],
                        "cover_i": 42,
                        "first_publish_year": 1847,
                    },
                ]
            },
        )

    works = asyncio.run(source(httpx.MockTransport(handle)).trending(5))

    assert len(works) == 1
    assert works[0].work_id == "OL2W"
    assert works[0].authors == ("Charlotte Brontë",)
    assert works[0].cover_id == 42


def test_cover_returns_none_when_missing() -> None:
    def handle(request: httpx.Request) -> httpx.Response:
        assert request.url.params["default"] == "false"
        if "/b/id/1-" in request.url.path:
            return httpx.Response(200, content=b"jpeg", headers={"content-type": "image/jpeg"})
        return httpx.Response(404)

    ol = source(httpx.MockTransport(handle))

    image = asyncio.run(ol.cover(1, "M"))
    assert image is not None
    assert image.content == b"jpeg"
    assert asyncio.run(ol.cover(2, "M")) is None


def test_blurb_comes_from_google_books_by_isbn_then_by_title() -> None:
    seen: list[dict[str, str]] = []

    def handle(request: httpx.Request) -> httpx.Response:
        assert request.url.host == "www.googleapis.com"
        params = dict(request.url.params)
        seen.append(params)
        if params["q"].startswith("isbn:"):
            return httpx.Response(200, json={"totalItems": 0})
        return httpx.Response(
            200,
            json={
                "items": [
                    {"volumeInfo": {"description": "Court."}},
                    {
                        "volumeInfo": {
                            "description": "<p>Orpheline, <b>Jane</b> devient gouvernante.</p>"
                            "<p>Un secret l&#39;attend &amp; la d&eacute;chire.<br>Fin.</p>"
                        }
                    },
                ]
            },
        )

    text = asyncio.run(
        source(httpx.MockTransport(handle)).blurb(
            "9782070360246", "Jane Eyre", ("Charlotte Brontë",), "fr"
        )
    )

    assert text == (
        "Orpheline, Jane devient gouvernante.\n\nUn secret l'attend & la déchire.\n\nFin."
    )
    assert "key" not in seen[0]
    assert seen[0]["q"] == "isbn:9782070360246"
    assert seen[1]["q"] == 'intitle:"Jane Eyre" inauthor:"Charlotte Brontë"'
    assert seen[1]["langRestrict"] == "fr"


def test_blurb_is_none_when_google_books_has_nothing_or_fails() -> None:
    def down(request: httpx.Request) -> httpx.Response:
        return httpx.Response(503)

    assert asyncio.run(source(httpx.MockTransport(down)).blurb(None, "Nothing", (), None)) is None


def test_a_google_books_key_is_sent_when_there_is_one() -> None:
    seen: list[str] = []

    def handle(request: httpx.Request) -> httpx.Response:
        seen.append(request.url.params.get("key", ""))
        return httpx.Response(200, json={"totalItems": 0})

    keyed = OpenLibrarySource(httpx.AsyncClient(transport=httpx.MockTransport(handle)), "k-123")
    asyncio.run(keyed.blurb("9782070360246", "Jane Eyre", (), None))

    assert seen[0] == "k-123"
