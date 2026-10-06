"""Reviews and notes are gathered per work, whatever the edition or file read."""

import uuid
from dataclasses import replace
from typing import Any

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from tests.api.v1.test_library import account, upload
from tests.api.v1.test_social import befriend, handle
from tests.api.v1.test_sync import device, push
from tests.api.v1.test_works import FakeBooks
from tests.books import epub


@pytest.fixture
def books(app: FastAPI) -> FakeBooks:
    fake = FakeBooks()
    app.state.container = replace(app.state.container, books=fake)
    return fake


def add(client: TestClient, auth: dict[str, str], **book: Any) -> dict[str, Any]:
    response = upload(client, auth, epub(**book))
    assert response.status_code == 201, response.text
    return response.json()["item"]


def review(client: TestClient, auth: dict[str, str], item: str, rating: int, audience: str):
    body = {"rating": rating, "text": f"{rating} stars", "audience": audience}
    assert client.put(f"/v1/library/{item}/review", json=body, headers=auth).status_code == 200


def test_every_edition_of_a_work_shares_its_reviews_and_notes(
    client: TestClient, books: FakeBooks
) -> None:
    ada, bob, cleo, dan = (
        account(client, f"{n}@example.com") for n in ("ada", "bob", "cleo", "dan")
    )
    for name, auth in (("ada", ada), ("bob", bob), ("cleo", cleo), ("dan", dan)):
        handle(client, auth, name)
    befriend(client, ada, bob, "ada", "bob")
    (hit,) = client.get("/v1/catalog/search", params={"q": "jane"}, headers=ada).json()
    work = hit["id"]
    client.get("/v1/catalog/isbn/9782070360246", headers=ada)  # the French edition

    # Ada's file has no ISBN: found by title and author.
    ada_book = add(client, ada, title="Jane Eyre", author="Charlotte Brontë", isbn=None)
    # Bob's file is the French edition (ISBN).
    bob_book = add(client, bob, title="Jane Eyre (poche)", author="C. Brontë")
    # Cleo's copy names another author: not guessed, she links it herself.
    cleo_book = add(client, cleo, title="Jane Eyre", author="Currer Bell", isbn=None)
    assert ada_book["work_id"] == work
    assert bob_book["work_id"] == work
    assert cleo_book["work_id"] is None
    linked = client.put(f"/v1/library/{cleo_book['id']}/work", json={"work_id": work}, headers=cleo)
    assert linked.json()["work_id"] == work
    missing = client.put(
        f"/v1/library/{cleo_book['id']}/work", json={"work_id": str(uuid.uuid4())}, headers=cleo
    )
    assert missing.status_code == 404

    review(client, ada, ada_book["id"], 4, "private")
    review(client, bob, bob_book["id"], 5, "friends")
    review(client, cleo, cleo_book["id"], 2, "public")
    push(
        client,
        bob,
        device(client, bob, "Pixel"),
        {
            "key": "op-wn0001",
            "entity": "annotation",
            "entity_id": str(uuid.uuid4()),
            "op": "upsert",
            "data": {
                "item_id": bob_book["id"],
                "chapter": 3,
                "quote": "I am no bird",
                "note": "!",
                "visibility": "friends",
                "client_time": "2026-10-05T10:00:00+00:00",
            },
        },
    )

    # Removing a book keeps its review on the work.
    client.delete(f"/v1/library/{cleo_book['id']}", headers=cleo)

    seen_by_ada = client.get(f"/v1/catalog/works/{work}/readers", headers=ada).json()
    assert sorted(
        (r["reader"]["handle"], r["rating"], r["mine"]) for r in seen_by_ada["reviews"]
    ) == [
        ("ada", 4, True),
        ("bob", 5, False),
        ("cleo", 2, False),
    ]
    assert (seen_by_ada["ratings"], seen_by_ada["rating"]) == (3, 3.67)
    assert [(n["reader"]["handle"], n["quote"]) for n in seen_by_ada["notes"]] == [
        ("bob", "I am no bird")
    ]

    # A stranger sees public content only; a blocked reader nothing of the blocker.
    seen_by_dan = client.get(f"/v1/catalog/works/{work}/readers", headers=dan).json()
    assert [r["reader"]["handle"] for r in seen_by_dan["reviews"]] == ["cleo"]
    assert seen_by_dan["notes"] == []
    client.put("/v1/social/blocks/dan", headers=cleo)
    assert client.get(f"/v1/catalog/works/{work}/readers", headers=dan).json()["reviews"] == []
