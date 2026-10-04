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
