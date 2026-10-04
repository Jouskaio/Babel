from dataclasses import replace

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from babel_api.domain.catalog import CoverImage, TrendingWork
from babel_api.domain.ports import CoverSize
from babel_api.services.catalog import CatalogService


class FakeSource:
    async def trending(self, limit: int) -> list[TrendingWork]:
        return [
            TrendingWork("OL1W", "Jane Eyre", ("Charlotte Brontë",), 42, 1847),
            TrendingWork("OL2W", "Rebecca", ("Daphne du Maurier",), 43),
        ][:limit]

    async def cover(self, cover_id: int, size: CoverSize) -> CoverImage | None:
        return CoverImage(b"jpeg", "image/jpeg") if cover_id == 42 else None


@pytest.fixture(autouse=True)
def fake_catalog(app: FastAPI) -> None:
    app.state.container = replace(app.state.container, catalog=CatalogService(FakeSource()))


def test_trending_works_link_to_proxied_covers(client: TestClient) -> None:
    response = client.get("/v1/catalog/trending", params={"limit": 1})

    assert response.status_code == 200
    assert response.json() == [
        {
            "work_id": "OL1W",
            "title": "Jane Eyre",
            "authors": ["Charlotte Brontë"],
            "cover_path": "/v1/catalog/covers/42/M",
            "first_publish_year": 1847,
        }
    ]


def test_trending_limit_is_bounded(client: TestClient) -> None:
    assert client.get("/v1/catalog/trending", params={"limit": 500}).status_code == 422


def test_covers_are_served_with_long_cache(client: TestClient) -> None:
    response = client.get("/v1/catalog/covers/42/M")

    assert response.status_code == 200
    assert response.content == b"jpeg"
    assert response.headers["content-type"] == "image/jpeg"
    assert "immutable" in response.headers["cache-control"]


def test_unknown_covers_are_404(client: TestClient) -> None:
    assert client.get("/v1/catalog/covers/7/M").status_code == 404
    assert client.get("/v1/catalog/covers/42/XL").status_code == 422
