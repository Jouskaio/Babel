from typing import Any

import pytest
from fastapi.testclient import TestClient

from tests.api.v1.test_library import account, upload
from tests.books import PDF, epub


@pytest.fixture
def ada(client: TestClient) -> dict[str, str]:
    return account(client, "ada@example.com")


def device(client: TestClient, auth: dict[str, str], name: str, kind: str = "phone") -> str:
    response = client.post("/v1/devices", json={"name": name, "kind": kind}, headers=auth)
    assert response.status_code == 201
    return response.json()["id"]


def pull(client: TestClient, auth: dict[str, str], since: int = 0, **params: Any) -> dict[str, Any]:
    return client.get("/v1/sync", params={"since": since, **params}, headers=auth).json()


def push(client: TestClient, auth: dict[str, str], device_id: str, *ops: dict[str, Any]) -> Any:
    return client.post(f"/v1/sync/{device_id}", json={"operations": list(ops)}, headers=auth)


def position(key: str, item_id: str, percent: float, when: str) -> dict[str, Any]:
    return {
        "key": key,
        "entity": "reading_position",
        "entity_id": item_id,
        "op": "upsert",
        "data": {
            "item_id": item_id,
            "locator": f"epubcfi(/6/{int(percent)})",
            "percent": percent,
            "client_time": when,
        },
    }


def test_devices_are_registered_and_listed(client: TestClient, ada: dict[str, str]) -> None:
    phone = device(client, ada, "Pixel")
    device(client, ada, "Kobo Libra", "ereader")

    names = {d["name"] for d in client.get("/v1/devices", headers=ada).json()}

    assert names == {"Pixel", "Kobo Libra"}
    assert client.delete(f"/v1/devices/{phone}", headers=ada).status_code == 204
    assert len(client.get("/v1/devices", headers=ada).json()) == 1


def test_library_changes_reach_other_devices(client: TestClient, ada: dict[str, str]) -> None:
    phone = device(client, ada, "Pixel")
    item = upload(client, ada, epub(), name="jane.epub").json()["item"]
    # The import is attributed to the phone when it says who it is.
    client.post(
        "/v1/library/files",
        files={"file": ("essay.pdf", PDF)},
        headers={**ada, "X-Babel-Device": phone},
    )

    changes = pull(client, ada)

    assert [c["op"] for c in changes["changes"]] == ["upsert", "upsert"]
    first, second = changes["changes"]
    assert first["entity"] == "library_item"
    assert first["data"]["title"] == "Jane Eyre"
    assert first["entity_id"] == item["id"]
    assert second["device_id"] == phone
    assert changes["has_more"] is False

    client.delete(f"/v1/library/{item['id']}", headers=ada)
    after = pull(client, ada, since=changes["cursor"])
    assert [(c["entity_id"], c["op"]) for c in after["changes"]] == [(item["id"], "delete")]


def test_the_log_is_paged(client: TestClient, ada: dict[str, str]) -> None:
    upload(client, ada, epub(), name="a.epub")
    upload(client, ada, PDF, name="b.pdf")

    page = pull(client, ada, limit=1)
    rest = pull(client, ada, since=page["cursor"], limit=1)

    assert page["has_more"] is True
    assert rest["has_more"] is False
    assert rest["changes"][0]["seq"] > page["cursor"]


def test_pushed_positions_are_idempotent_and_latest_wins(
    client: TestClient, ada: dict[str, str]
) -> None:
    phone = device(client, ada, "Pixel")
    item = upload(client, ada, epub()).json()["item"]["id"]

    first = push(client, ada, phone, position("op-00001", item, 40, "2026-10-04T10:00:00+00:00"))
    replay = push(client, ada, phone, position("op-00001", item, 40, "2026-10-04T10:00:00+00:00"))
    older = push(client, ada, phone, position("op-00002", item, 20, "2026-10-04T09:00:00+00:00"))

    assert first.json()["results"][0]["outcome"] == "applied"
    assert replay.json()["results"][0]["outcome"] == "duplicate"
    assert older.json()["results"][0]["outcome"] == "stale"
    positions = client.get(f"/v1/library/{item}/positions", headers=ada).json()
    assert [p["percent"] for p in positions] == [40]


def test_each_device_keeps_its_own_position(client: TestClient, ada: dict[str, str]) -> None:
    phone = device(client, ada, "Pixel")
    kobo = device(client, ada, "Kobo", "ereader")
    item = upload(client, ada, epub()).json()["item"]["id"]

    push(client, ada, phone, position("op-phone", item, 30, "2026-10-04T08:00:00+00:00"))
    push(client, ada, kobo, position("op-kobo1", item, 55, "2026-10-04T21:00:00+00:00"))

    positions = client.get(f"/v1/library/{item}/positions", headers=ada).json()
    assert [(p["device_id"], p["percent"]) for p in positions] == [(kobo, 55), (phone, 30)]
    log = [c for c in pull(client, ada)["changes"] if c["entity"] == "reading_position"]
    assert [c["data"]["percent"] for c in log] == [30, 55]


def test_offline_library_operations_are_replayed(client: TestClient, ada: dict[str, str]) -> None:
    bob = account(client, "bob@example.com")
    sha = upload(client, bob, PDF).json()["item"]["sha256"]
    phone = device(client, ada, "Pixel")

    added = push(
        client,
        ada,
        phone,
        {
            "key": "op-add-1",
            "entity": "library_item",
            "entity_id": "new",
            "op": "upsert",
            "data": {"sha256": sha},
        },
    ).json()["results"][0]
    item_id = client.get("/v1/library", headers=ada).json()[0]["id"]
    removed = push(
        client,
        ada,
        phone,
        {"key": "op-del-1", "entity": "library_item", "entity_id": item_id, "op": "delete"},
        {"key": "op-del-2", "entity": "library_item", "entity_id": item_id, "op": "delete"},
    ).json()["results"]

    assert added["outcome"] == "applied"
    assert [r["outcome"] for r in removed] == ["applied", "stale"]
    assert client.get("/v1/library", headers=ada).json() == []


def test_invalid_operations_are_rejected_without_side_effects(
    client: TestClient, ada: dict[str, str]
) -> None:
    phone = device(client, ada, "Pixel")

    results = push(
        client,
        ada,
        phone,
        position("op-bad-01", "00000000-0000-0000-0000-000000000000", 10, "2026-10-04T10:00:00Z"),
        {
            "key": "op-bad-02",
            "entity": "reading_position",
            "entity_id": "x",
            "op": "upsert",
            "data": {},
        },
    ).json()["results"]

    assert [r["outcome"] for r in results] == ["rejected", "rejected"]
    assert pull(client, ada)["changes"] == []


def test_withdrawn_files_disappear_from_every_library_log(
    client: TestClient, ada: dict[str, str]
) -> None:
    admin = account(client, "admin@example.com")
    item = upload(client, ada, PDF).json()["item"]
    cursor = pull(client, ada)["cursor"]

    client.post(
        f"/v1/admin/files/{item['sha256']}/withdraw",
        json={"reason": "Rights holder"},
        headers=admin,
    )

    changes = pull(client, ada, since=cursor)["changes"]
    assert [(c["entity_id"], c["op"]) for c in changes] == [(item["id"], "delete")]


def test_accounts_cannot_see_or_use_each_other(client: TestClient, ada: dict[str, str]) -> None:
    bob = account(client, "bob@example.com")
    phone = device(client, ada, "Pixel")
    upload(client, ada, epub())

    assert pull(client, bob)["changes"] == []
    assert (
        push(client, bob, phone, position("op-x-0001", "x", 1, "2026-10-04T10:00:00Z")).status_code
        == 404
    )
    assert client.delete(f"/v1/devices/{phone}", headers=bob).status_code == 404
