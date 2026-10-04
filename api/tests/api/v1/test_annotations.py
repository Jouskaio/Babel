import uuid
from typing import Any

import pytest
from fastapi.testclient import TestClient

from tests.api.v1.test_library import account, upload
from tests.api.v1.test_sync import device, pull, push
from tests.books import epub

NOTE_ID = str(uuid.uuid4())


@pytest.fixture
def ada(client: TestClient) -> dict[str, str]:
    return account(client, "ada@example.com")


@pytest.fixture
def bob(client: TestClient) -> dict[str, str]:
    return account(client, "bob@example.com")


def annotation(
    item_id: str,
    when: str,
    *,
    annotation_id: str = NOTE_ID,
    note: str | None = "Tout le roman tient là-dedans.",
    quote: str = "Nelly, I am Heathcliff!",
    color: str = "gold",
) -> dict[str, Any]:
    return {
        "key": str(uuid.uuid4()),
        "entity": "annotation",
        "entity_id": annotation_id,
        "op": "upsert",
        "data": {
            "item_id": item_id,
            "chapter": 12,
            "quote": quote,
            "color": color,
            "note": note,
            "client_time": when,
        },
    }


def outcome(response: Any) -> str:
    return response.json()["results"][0]["outcome"]


def test_annotations_reach_the_other_devices(client: TestClient, ada: dict[str, str]) -> None:
    item = upload(client, ada, epub(isbn=None)).json()["item"]
    phone = device(client, ada, "Phone")
    since = pull(client, ada)["cursor"]
    assert outcome(push(client, ada, phone, annotation(item["id"], "2026-10-04T10:00:00Z"))) == (
        "applied"
    )
    change = pull(client, ada, since)["changes"][0]
    assert (change["entity"], change["entity_id"], change["op"]) == (
        "annotation",
        NOTE_ID,
        "upsert",
    )
    assert change["data"]["quote"] == "Nelly, I am Heathcliff!"
    assert change["data"]["file_sha256"] == item["sha256"]
    assert change["data"]["visibility"] == "private"


def test_the_latest_edit_wins(client: TestClient, ada: dict[str, str]) -> None:
    item = upload(client, ada, epub(isbn=None)).json()["item"]
    phone = device(client, ada, "Phone")
    push(client, ada, phone, annotation(item["id"], "2026-10-04T10:00:00Z"))
    newer = push(client, ada, phone, annotation(item["id"], "2026-10-04T11:00:00Z", note="v2"))
    older = push(client, ada, phone, annotation(item["id"], "2026-10-04T09:00:00Z", note="v0"))
    assert (outcome(newer), outcome(older)) == ("applied", "stale")


def test_annotations_can_be_deleted(client: TestClient, ada: dict[str, str]) -> None:
    item = upload(client, ada, epub(isbn=None)).json()["item"]
    phone = device(client, ada, "Phone")
    push(client, ada, phone, annotation(item["id"], "2026-10-04T10:00:00Z"))
    since = pull(client, ada)["cursor"]
    delete = {
        "key": str(uuid.uuid4()),
        "entity": "annotation",
        "entity_id": NOTE_ID,
        "op": "delete",
    }
    assert outcome(push(client, ada, phone, delete)) == "applied"
    assert pull(client, ada, since)["changes"][0]["op"] == "delete"
    delete["key"] = str(uuid.uuid4())
    assert outcome(push(client, ada, phone, delete)) == "stale"


def test_annotations_are_private(
    client: TestClient, ada: dict[str, str], bob: dict[str, str]
) -> None:
    ada_item = upload(client, ada, epub(isbn=None)).json()["item"]
    bob_item = upload(client, bob, epub(isbn=None)).json()["item"]
    ada_phone, bob_phone = device(client, ada, "Phone"), device(client, bob, "Phone")
    push(client, ada, ada_phone, annotation(ada_item["id"], "2026-10-04T10:00:00Z"))
    # Bob can neither annotate Ada's item nor take over her annotation's id.
    assert outcome(
        push(client, bob, bob_phone, annotation(ada_item["id"], "2026-10-05T10:00:00Z"))
    ) == ("rejected")
    assert outcome(
        push(client, bob, bob_phone, annotation(bob_item["id"], "2026-10-05T10:00:00Z"))
    ) == ("rejected")
    assert all(c["entity"] != "annotation" for c in pull(client, bob)["changes"])


@pytest.mark.parametrize(
    "change",
    [{"quote": ""}, {"quote": "x" * 2001}, {"note": "y" * 5001}, {"color": "purple"}],
)
def test_invalid_annotations_are_rejected(
    client: TestClient, ada: dict[str, str], change: dict[str, str]
) -> None:
    item = upload(client, ada, epub(isbn=None)).json()["item"]
    phone = device(client, ada, "Phone")
    op = annotation(item["id"], "2026-10-04T10:00:00Z")
    op["data"].update(change)
    assert outcome(push(client, ada, phone, op)) == "rejected"


def test_annotations_survive_removing_the_book(client: TestClient, ada: dict[str, str]) -> None:
    item = upload(client, ada, epub(isbn=None)).json()["item"]
    phone = device(client, ada, "Phone")
    push(client, ada, phone, annotation(item["id"], "2026-10-04T10:00:00Z"))
    client.delete(f"/v1/library/{item['id']}", headers=ada)
    again = upload(client, ada, epub(isbn=None)).json()["item"]
    assert again["sha256"] == item["sha256"]
    changes = pull(client, ada)["changes"]
    assert any(c["entity"] == "annotation" and c["op"] == "upsert" for c in changes)
