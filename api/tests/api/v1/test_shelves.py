"""Reading status, declared progress and shelves (synchronized like the rest)."""

import uuid
from typing import Any

import pytest
from fastapi.testclient import TestClient

from tests.api.v1.test_library import account
from tests.api.v1.test_social import befriend, book, handle, reader
from tests.api.v1.test_sync import device, position, pull, push


@pytest.fixture
def ada(client: TestClient) -> dict[str, str]:
    return account(client, "ada@example.com")


@pytest.fixture
def admin(client: TestClient) -> dict[str, str]:
    return account(client, "admin@example.com")


def state(
    key: str, item: str, when: str, status: str | None, progress: float | None = None
) -> dict[str, Any]:
    return {
        "key": key,
        "entity": "reading_state",
        "entity_id": item,
        "op": "upsert",
        "data": {"status": status, "progress": progress, "client_time": when},
    }


def shelf(key: str, shelf_id: str, name: str, items: list[str], when: str, **extra: Any):
    return {
        "key": key,
        "entity": "shelf",
        "entity_id": shelf_id,
        "op": "upsert",
        "data": {"name": name, "item_ids": items, "client_time": when, **extra},
    }


def outcome(response: Any) -> str:
    return response.json()["results"][0]["outcome"]


def item_of(client: TestClient, auth: dict[str, str], item: str) -> dict[str, Any]:
    return next(i for i in client.get("/v1/library", headers=auth).json() if i["id"] == item)


def test_status_and_progress_are_set_and_synced(client: TestClient, ada: dict[str, str]) -> None:
    phone = device(client, ada, "Pixel")
    item = book(client, ada, "Jane Eyre")

    assert (
        outcome(
            push(
                client,
                ada,
                phone,
                state("op-s0001", item, "2026-10-05T10:00:00+00:00", "reading", 42),
            )
        )
        == "applied"
    )
    older = push(
        client, ada, phone, state("op-s0002", item, "2026-10-05T09:00:00+00:00", "to_read")
    )

    assert outcome(older) == "stale"
    stored = item_of(client, ada, item)
    assert (stored["status"], stored["progress"]) == ("reading", 42)
    assert stored["started_at"].startswith("2026-10-05T10:00")
    log = [c for c in pull(client, ada)["changes"] if c["entity"] == "library_item"]
    assert log[-1]["data"]["status"] == "reading"
    assert log[-1]["data"]["progress"] == 42

    push(client, ada, phone, state("op-s0003", item, "2026-10-06T10:00:00+00:00", "finished"))
    done = item_of(client, ada, item)
    assert done["finished_at"].startswith("2026-10-06T10:00")
    assert done["started_at"].startswith("2026-10-05T10:00")

    push(client, ada, phone, state("op-s0004", item, "2026-10-06T11:00:00+00:00", None))
    cleared = item_of(client, ada, item)
    assert (cleared["status"], cleared["finished_at"]) == (None, None)


def test_invalid_states_are_rejected(client: TestClient, ada: dict[str, str]) -> None:
    phone = device(client, ada, "Pixel")
    item = book(client, ada, "Jane Eyre")
    when = "2026-10-05T10:00:00+00:00"

    for key, op in (
        ("op-bad001", state("op-bad001", item, when, "skimmed")),
        ("op-bad002", state("op-bad002", item, when, "reading", 140)),
        ("op-bad003", state("op-bad003", str(uuid.uuid4()), when, "reading")),
    ):
        assert outcome(push(client, ada, phone, op)) == "rejected", key


def test_reading_positions_move_the_status(client: TestClient, ada: dict[str, str]) -> None:
    phone = device(client, ada, "Pixel")
    item = book(client, ada, "Jane Eyre")

    push(client, ada, phone, position("op-p00001", item, 12, "2026-10-05T10:00:00+00:00"))
    assert item_of(client, ada, item)["status"] == "reading"

    push(client, ada, phone, position("op-p00002", item, 100, "2026-10-05T20:00:00+00:00"))
    done = item_of(client, ada, item)
    assert done["status"] == "finished"
    assert done["finished_at"].startswith("2026-10-05T20:00")

    # Re-reading a finished book leaves it finished.
    push(client, ada, phone, position("op-p00003", item, 3, "2026-10-07T10:00:00+00:00"))
    assert item_of(client, ada, item)["status"] == "finished"


def test_a_later_status_set_by_hand_wins_over_older_positions(
    client: TestClient, ada: dict[str, str]
) -> None:
    phone = device(client, ada, "Pixel")
    item = book(client, ada, "Jane Eyre")

    push(client, ada, phone, state("op-h00001", item, "2026-10-05T12:00:00+00:00", "to_read"))
    # Read offline earlier on another device, pushed later.
    push(client, ada, phone, position("op-h00002", item, 30, "2026-10-05T08:00:00+00:00"))

    assert item_of(client, ada, item)["status"] == "to_read"


def test_shelves_are_synced_edited_and_deleted(client: TestClient, ada: dict[str, str]) -> None:
    phone = device(client, ada, "Pixel")
    jane, emma = book(client, ada, "Jane Eyre"), book(client, ada, "Emma")
    shelf_id = str(uuid.uuid4())

    created = push(
        client,
        ada,
        phone,
        shelf(
            "op-sh0001", shelf_id, "  Classiques  ", [emma, jane, emma], "2026-10-05T10:00:00+00:00"
        ),
    )
    assert outcome(created) == "applied"
    stale = push(
        client, ada, phone, shelf("op-sh0002", shelf_id, "Old", [], "2026-10-05T09:00:00+00:00")
    )
    assert outcome(stale) == "stale"

    log = [c for c in pull(client, ada)["changes"] if c["entity"] == "shelf"]
    assert log[-1]["data"]["name"] == "Classiques"
    assert log[-1]["data"]["item_ids"] == [emma, jane]
    assert log[-1]["data"]["visibility"] == "private"

    # Removing a book takes it off its shelves.
    client.delete(f"/v1/library/{emma}", headers=ada)
    push(
        client,
        ada,
        phone,
        shelf("op-sh0003", shelf_id, "Classiques", [emma, jane], "2026-10-05T11:00:00+00:00"),
    )
    log = [c for c in pull(client, ada)["changes"] if c["entity"] == "shelf"]
    assert log[-1]["data"]["item_ids"] == [jane]

    deleted = push(
        client,
        ada,
        phone,
        {"key": "op-sh0004", "entity": "shelf", "entity_id": shelf_id, "op": "delete"},
    )
    assert outcome(deleted) == "applied"
    log = [c for c in pull(client, ada)["changes"] if c["entity"] == "shelf"]
    assert (log[-1]["op"], log[-1]["entity_id"]) == ("delete", shelf_id)


def test_shelves_need_a_name_and_stay_their_owners(client: TestClient, ada: dict[str, str]) -> None:
    bob = account(client, "bob@example.com")
    phone, bobs = device(client, ada, "Pixel"), device(client, bob, "Bob's")
    shelf_id = str(uuid.uuid4())
    when = "2026-10-05T10:00:00+00:00"

    assert (
        outcome(push(client, ada, phone, shelf("op-sn0001", str(uuid.uuid4()), "   ", [], when)))
        == "rejected"
    )
    assert (
        outcome(push(client, ada, phone, shelf("op-sn0002", shelf_id, "À lire", [], when)))
        == "applied"
    )
    later = "2026-10-06T10:00:00+00:00"
    assert (
        outcome(push(client, bob, bobs, shelf("op-sn0003", shelf_id, "Mine", [], later)))
        == "rejected"
    )
    # Another reader's books are never put on a shelf.
    bobs_book = book(client, bob, "Emma")
    push(client, ada, phone, shelf("op-sn0004", shelf_id, "À lire", [bobs_book], later))
    log = [c for c in pull(client, ada)["changes"] if c["entity"] == "shelf"]
    assert log[-1]["data"]["item_ids"] == []
    assert not [c for c in pull(client, bob)["changes"] if c["entity"] == "shelf"]


def test_friends_see_shared_shelves_finished_books_and_declared_progress(
    client: TestClient,
) -> None:
    ada, bob = account(client, "ada@example.com"), account(client, "bob@example.com")
    handle(client, ada, "ada")
    handle(client, bob, "bob")
    befriend(client, ada, bob, "ada", "bob")
    phone = device(client, ada, "Pixel")
    jane, emma, dune = (book(client, ada, t) for t in ("Jane Eyre", "Emma", "Dune"))
    push(
        client,
        ada,
        phone,
        shelf(
            "op-f00001",
            str(uuid.uuid4()),
            "Favoris",
            [jane, emma],
            "2026-10-05T10:00:00+00:00",
            visibility="friends",
        ),
        shelf("op-f00002", str(uuid.uuid4()), "Secret", [dune], "2026-10-05T10:00:00+00:00"),
        state("op-f00003", jane, "2026-10-05T10:00:00+00:00", "finished"),
        state("op-f00004", emma, "2026-10-05T11:00:00+00:00", "reading", 35),
    )

    page = reader(client, bob, "ada")

    assert [(s["name"], [b["title"] for b in s["books"]]) for s in page["shelves"]] == [
        ("Favoris", ["Jane Eyre", "Emma"])
    ]
    assert [r["title"] for r in page["finished"]] == ["Jane Eyre"]
    assert [(r["title"], r["percent"]) for r in page["reading"]] == [("Emma", 35)]
    feed = client.get("/v1/social/feed", headers=bob).json()
    assert {(e["kind"], e["title"]) for e in feed} >= {
        ("finished", "Jane Eyre"),
        ("reading", "Emma"),
    }


def test_hidden_books_stay_in_the_library_but_out_of_sight(client: TestClient) -> None:
    ada, bob = account(client, "ada@example.com"), account(client, "bob@example.com")
    handle(client, ada, "ada", share_library="public")
    handle(client, bob, "bob")
    befriend(client, ada, bob, "ada", "bob")
    phone = device(client, ada, "Pixel")
    jane, emma = book(client, ada, "Jane Eyre"), book(client, ada, "Emma")
    hide = state("op-hid001", jane, "2026-10-05T10:00:00+00:00", "finished")
    hide["data"]["hidden"] = True
    push(
        client, ada, phone, hide, state("op-hid002", emma, "2026-10-05T10:00:00+00:00", "finished")
    )

    mine = item_of(client, ada, jane)
    assert (mine["hidden"], mine["status"]) == (True, "finished")
    page = reader(client, bob, "ada")
    assert [b["title"] for b in page["library"]] == ["Emma"]
    assert page["books"] == 1
    assert [r["title"] for r in page["finished"]] == ["Emma"]

    # A later change without "hidden" keeps the book hidden; showing it again is explicit.
    push(client, ada, phone, state("op-hid003", jane, "2026-10-05T11:00:00+00:00", "reading"))
    assert item_of(client, ada, jane)["hidden"] is True
    show = state("op-hid004", jane, "2026-10-05T12:00:00+00:00", "reading")
    show["data"]["hidden"] = False
    push(client, ada, phone, show)
    assert item_of(client, ada, jane)["hidden"] is False


def test_removing_a_book_keeps_its_data_and_adding_it_back_restores_it(
    client: TestClient, ada: dict[str, str]
) -> None:
    phone = device(client, ada, "Pixel")
    item = book(client, ada, "Jane Eyre")
    sha = item_of(client, ada, item)["sha256"]
    push(
        client,
        ada,
        phone,
        position("op-r00001", item, 100, "2026-10-05T10:00:00+00:00"),
        {
            "key": "op-r00002",
            "entity": "annotation",
            "entity_id": str(uuid.uuid4()),
            "op": "upsert",
            "data": {
                "item_id": item,
                "chapter": 1,
                "quote": "Reader, I married him.",
                "color": "gold",
                "client_time": "2026-10-05T10:00:00+00:00",
            },
        },
    )
    review = {"rating": 5, "text": "Superbe", "audience": "private"}
    assert client.put(f"/v1/library/{item}/review", json=review, headers=ada).status_code == 200

    assert client.delete(f"/v1/library/{item}", headers=ada).status_code == 204
    assert client.get("/v1/library", headers=ada).json() == []

    history = client.get("/v1/library/history", headers=ada).json()
    assert len(history) == 1
    trace = history[0]
    assert trace["removed_at"] is not None
    assert trace["item"]["status"] == "finished"
    assert (trace["review"]["rating"], trace["notes"], trace["available"]) == (5, 1, True)

    # Adding the same file again brings the book back with everything it had.
    again = client.post(f"/v1/library/files/{sha}", headers=ada)
    assert again.status_code in (200, 201), again.text
    assert again.json()["id"] == item
    assert again.json()["status"] == "finished"
    assert client.get(f"/v1/library/{item}/review", headers=ada).json()["rating"] == 5
    assert client.get(f"/v1/library/{item}/positions", headers=ada).json()[0]["percent"] == 100
    assert client.get("/v1/library/history", headers=ada).json()[0]["removed_at"] is None


def test_the_data_outlives_a_withdrawn_file(
    client: TestClient, ada: dict[str, str], admin: dict[str, str]
) -> None:
    item = book(client, ada, "Jane Eyre")
    sha = item_of(client, ada, item)["sha256"]
    client.put(f"/v1/library/{item}/review", json={"rating": 2}, headers=ada)

    client.post(f"/v1/admin/files/{sha}/withdraw", json={"reason": "test"}, headers=admin)

    assert client.get("/v1/library", headers=ada).json() == []
    [trace] = client.get("/v1/library/history", headers=ada).json()
    assert (trace["available"], trace["review"]["rating"]) == (False, 2)
