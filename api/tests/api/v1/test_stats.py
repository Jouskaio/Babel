"""A reader's year in books."""

import uuid
from datetime import date

import pytest
from fastapi.testclient import TestClient

from babel_api.services.stats import streaks
from tests.api.v1.test_library import account, upload
from tests.api.v1.test_shelves import state
from tests.api.v1.test_social import book
from tests.api.v1.test_sync import device, position, push
from tests.books import epub


@pytest.fixture
def ada(client: TestClient) -> dict[str, str]:
    return account(client, "ada@example.com")


def test_streaks_count_consecutive_days() -> None:
    days = {date(2026, 3, d) for d in (1, 2, 3, 5, 6)} | {date(2026, 10, 5), date(2026, 10, 6)}
    assert streaks(days, date(2026, 10, 6)) == (3, 2)
    assert streaks(days, date(2026, 10, 7)) == (3, 2)  # yesterday still counts
    assert streaks(days, date(2026, 10, 9)) == (3, 0)
    assert streaks(set(), date(2026, 10, 9)) == (0, 0)


def test_a_year_of_reading(client: TestClient, ada: dict[str, str]) -> None:
    phone = device(client, ada, "Pixel")
    jane, emma, dune = (
        book(client, ada, "Jane Eyre"),
        book(client, ada, "Emma"),
        book(client, ada, "Dune"),
    )
    push(
        client,
        ada,
        phone,
        position("op-y00001", jane, 10, "2026-03-01T20:00:00+00:00"),
        position("op-y00002", jane, 50, "2026-03-02T20:00:00+00:00"),
        position("op-y00003", jane, 100, "2026-03-03T20:00:00+00:00"),
        state("op-y00004", emma, "2026-03-20T10:00:00+00:00", "finished"),
        state("op-y00005", dune, "2026-05-02T10:00:00+00:00", "abandoned"),
        # Last year's book does not count.
        state("op-y00006", dune, "2025-12-31T10:00:00+00:00", "finished"),
        {
            "key": "op-y00007",
            "entity": "annotation",
            "entity_id": str(uuid.uuid4()),
            "op": "upsert",
            "data": {
                "item_id": jane,
                "chapter": 1,
                "quote": "Reader, I married him.",
                "client_time": "2026-03-02T21:00:00+00:00",
            },
        },
    )
    client.put(f"/v1/library/{emma}/review", json={"rating": 4}, headers=ada)

    stats = client.get("/v1/me/stats", params={"year": 2026}, headers=ada).json()

    assert [b["title"] for b in stats["finished"]] == ["Jane Eyre", "Emma"]
    assert stats["by_month"][2] == 2
    assert stats["best_month"] == 3
    assert (stats["reading_days"], stats["longest_streak"]) == (3, 3)
    assert stats["busiest_day"] in ("2026-03-01", "2026-03-02", "2026-03-03")
    assert (stats["started"], stats["abandoned"]) == (2, 1)
    assert stats["notes"] == 1
    assert stats["average_rating"] == 4
    assert stats["top_authors"] == [{"name": "Emily Brontë", "books": 2}]
    assert stats["formats"] == {"epub": 2}
    assert 2026 in stats["years"]

    # 20:00 UTC on March 3rd is already March 4th in Tokyo.
    tokyo = client.get("/v1/me/stats", params={"year": 2026, "tz_offset": 540}, headers=ada).json()
    assert tokyo["finished"][0]["finished_at"].startswith("2026-03-04T05:00")


def test_an_empty_year(client: TestClient, ada: dict[str, str]) -> None:
    stats = client.get("/v1/me/stats", params={"year": 2020}, headers=ada).json()
    assert (stats["finished"], stats["reading_days"], stats["best_month"]) == ([], 0, None)


def test_genres_of_the_year_and_the_year_before(client: TestClient, ada: dict[str, str]) -> None:
    def add(title: str, *subjects: str) -> str:
        response = upload(client, ada, epub(title=title, isbn=None, subjects=subjects))
        return response.json()["item"]["id"]

    dune = add("Dune", "Science fiction", "Desert -- Fiction")
    hyperion = add("Hyperion", "Science-fiction")
    emma = add("Emma", "Love stories", "England -- Fiction")
    poems = add("Poèmes", "Poésie")
    push(
        client,
        ada,
        device(client, ada, "Pixel"),
        state("op-g00001", dune, "2026-02-01T10:00:00+00:00", "finished"),
        state("op-g00002", hyperion, "2026-03-01T10:00:00+00:00", "finished"),
        state("op-g00003", emma, "2026-04-01T10:00:00+00:00", "finished"),
        state("op-g00004", poems, "2025-06-01T10:00:00+00:00", "finished"),
    )

    stats = client.get("/v1/me/stats", params={"year": 2026}, headers=ada).json()

    assert stats["genres"] == [
        {"genre": "science_fiction", "books": 2},
        {"genre": "romance", "books": 1},
    ]
    assert stats["previous_genres"] == [{"genre": "poetry", "books": 1}]
    assert stats["finished"][0]["genres"] == ["science_fiction"]


def test_progression_starts_at_level_one_and_rewards_a_first_book(
    client: TestClient, ada: dict[str, str]
) -> None:
    first = client.get("/v1/me/progression", headers=ada).json()
    assert (first["level"], first["xp"], first["title"]) == (1, 0, "novice")
    assert [s["done"] for s in first["steps"]] == [False] * 6

    upload(client, ada, epub(title="Jane Eyre", isbn=None))
    after = client.get("/v1/me/progression", headers=ada).json()
    assert after["xp"] == 10  # one book added
    steps = {s["key"]: s["done"] for s in after["steps"]}
    assert steps["add_book"] is True
    assert steps["finish"] is False
