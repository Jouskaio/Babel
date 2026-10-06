import uuid
from dataclasses import replace
from typing import Any

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from tests.api.v1.test_follows import Pushes
from tests.api.v1.test_library import account, upload
from tests.api.v1.test_sync import device, push
from tests.books import epub


def handle(client: TestClient, auth: dict[str, str], value: str, **share: str) -> Any:
    return client.patch("/v1/me/profile", json={"handle": value, **share}, headers=auth)


def reader(client: TestClient, auth: dict[str, str], name: str) -> dict[str, Any]:
    response = client.get(f"/v1/social/readers/{name}", headers=auth)
    assert response.status_code == 200, response.text
    return response.json()


def befriend(client: TestClient, a: dict[str, str], b: dict[str, str], a_name: str, b_name: str):
    assert client.put(f"/v1/social/friends/{b_name}", headers=a).status_code == 200
    accepted = client.put(f"/v1/social/friends/{a_name}", headers=b).json()
    assert accepted["relation"]["friend"] == "friends"


def book(client: TestClient, auth: dict[str, str], title: str) -> str:
    response = upload(client, auth, epub(title=title, author="Emily Brontë", isbn=None))
    assert response.status_code == 201, response.text
    return response.json()["item"]["id"]


@pytest.fixture
def people(client: TestClient) -> dict[str, dict[str, str]]:
    """Ada, her friend Bob, Cleo who follows Ada, and Dan, a stranger."""
    found = {name: account(client, f"{name}@example.com") for name in ("ada", "bob", "cleo", "dan")}
    for name, auth in found.items():
        assert handle(client, auth, name).status_code == 200
    befriend(client, found["ada"], found["bob"], "ada", "bob")
    assert client.put("/v1/social/following/ada", headers=found["cleo"]).status_code == 200
    return found


def test_handles_are_unique_and_normalized(client: TestClient) -> None:
    ada, bob = account(client, "ada@example.com"), account(client, "bob@example.com")

    response = handle(client, ada, "@Ada.Reads")
    assert response.status_code == 200
    assert response.json()["handle"] == "ada.reads"
    assert response.json()["share_reading"] == "friends"
    assert handle(client, bob, "ADA.reads").status_code == 409
    for invalid in ("a", "no spaces", "x" * 31, "_edge", "dots..twice"):
        assert handle(client, bob, invalid).status_code == 400, invalid


def test_readers_are_found_by_handle_prefix(client: TestClient) -> None:
    ada, bob = account(client, "ada@example.com"), account(client, "bob@example.com")
    account(client, "nohandle@example.com")
    handle(client, ada, "ada")
    handle(client, bob, "adamant")

    found = client.get("/v1/social/readers", params={"q": "@ad"}, headers=ada).json()

    assert [r["handle"] for r in found] == ["adamant"]  # never yourself
    assert found[0]["relation"] == {"friend": "none", "following": False, "follows_you": False}
    assert client.get("/v1/social/readers", params={"q": "zz"}, headers=ada).json() == []


def test_friend_requests_go_both_ways(client: TestClient) -> None:
    ada, bob = account(client, "ada@example.com"), account(client, "bob@example.com")
    handle(client, ada, "ada")
    handle(client, bob, "bob")

    sent = client.put("/v1/social/friends/bob", headers=ada).json()
    assert sent["relation"]["friend"] == "requested"
    friends = client.get("/v1/social/friends", headers=bob).json()
    assert [r["handle"] for r in friends["incoming"]] == ["ada"]
    assert friends["incoming"][0]["relation"]["friend"] == "incoming"

    assert client.put("/v1/social/friends/ada", headers=bob).json()["relation"]["friend"] == (
        "friends"
    )
    assert [
        r["handle"] for r in client.get("/v1/social/friends", headers=ada).json()["friends"]
    ] == ["bob"]

    ended = client.delete("/v1/social/friends/bob", headers=ada).json()
    assert ended["relation"]["friend"] == "none"
    assert client.get("/v1/social/friends", headers=bob).json()["friends"] == []


def test_following_is_one_way(client: TestClient, people: dict[str, dict[str, str]]) -> None:
    page = reader(client, people["cleo"], "ada")
    assert page["reader"]["relation"] == {"friend": "none", "following": True, "follows_you": False}
    assert page["followers"] == 1
    assert reader(client, people["ada"], "cleo")["reader"]["relation"]["follows_you"] is True
    client.delete("/v1/social/following/ada", headers=people["cleo"])
    assert reader(client, people["ada"], "cleo")["reader"]["relation"]["follows_you"] is False


def test_library_and_reading_follow_the_chosen_audience(
    client: TestClient, people: dict[str, dict[str, str]]
) -> None:
    ada = people["ada"]
    item = book(client, ada, "Wuthering Heights")
    phone = device(client, ada, "Phone")
    push(
        client,
        ada,
        phone,
        {
            "key": str(uuid.uuid4()),
            "entity": "reading_position",
            "entity_id": item,
            "op": "upsert",
            "data": {
                "item_id": item,
                "locator": "epub:3:0.5",
                "percent": 42.0,
                "client_time": "2099-01-01T10:00:00Z",
            },
        },
    )

    # Default: friends only.
    friend = reader(client, people["bob"], "ada")
    assert friend["books"] == 1
    assert [b["title"] for b in friend["library"]] == ["Wuthering Heights"]
    assert [(r["title"], r["percent"]) for r in friend["reading"]] == [("Wuthering Heights", 42.0)]
    stranger = reader(client, people["dan"], "ada")
    assert (stranger["books"], stranger["library"], stranger["reading"]) == (None, None, [])

    handle(client, ada, "ada", share_library="public", share_reading="private")
    stranger = reader(client, people["dan"], "ada")
    assert stranger["books"] == 1
    assert reader(client, people["bob"], "ada")["reading"] == []


def test_reviews_reach_who_they_are_meant_for(
    client: TestClient, people: dict[str, dict[str, str]]
) -> None:
    ada = people["ada"]
    item = book(client, ada, "Jane Eyre")

    saved = client.put(
        f"/v1/library/{item}/review",
        json={"rating": 5, "text": "Reader, I loved it.", "audience": "friends"},
        headers=ada,
    )
    assert saved.status_code == 200, saved.text
    assert client.get(f"/v1/library/{item}/review", headers=ada).json()["rating"] == 5

    assert [r["text"] for r in reader(client, people["bob"], "ada")["reviews"]] == [
        "Reader, I loved it."
    ]
    assert reader(client, people["cleo"], "ada")["reviews"] == []
    assert client.get("/v1/social/feed", headers=people["cleo"]).json() == []
    bob_feed = client.get("/v1/social/feed", headers=people["bob"]).json()
    assert [(e["kind"], e["reader"]["handle"], e["rating"]) for e in bob_feed] == [
        ("review", "ada", 5)
    ]

    client.put(
        f"/v1/library/{item}/review",
        json={"rating": 4, "text": "Reader, I loved it.", "audience": "public"},
        headers=ada,
    )
    cleo_feed = client.get("/v1/social/feed", headers=people["cleo"]).json()
    assert [(e["kind"], e["title"], e["rating"]) for e in cleo_feed] == [("review", "Jane Eyre", 4)]

    # Only your own books, and ratings from 1 to 5.
    assert (
        client.put(f"/v1/library/{item}/review", json={}, headers=people["bob"]).status_code == 404
    )
    assert (
        client.put(f"/v1/library/{item}/review", json={"rating": 6}, headers=ada).status_code == 422
    )
    assert client.delete(f"/v1/library/{item}/review", headers=ada).status_code == 204
    assert client.get(f"/v1/library/{item}/review", headers=ada).status_code == 204


def test_notes_are_shared_only_when_chosen(
    client: TestClient, people: dict[str, dict[str, str]]
) -> None:
    ada = people["ada"]
    item = book(client, ada, "Wuthering Heights")
    phone = device(client, ada, "Phone")

    def note(quote: str, visibility: str, page_note: str | None = None) -> dict[str, Any]:
        return {
            "key": str(uuid.uuid4()),
            "entity": "annotation",
            "entity_id": str(uuid.uuid4()),
            "op": "upsert",
            "data": {
                "item_id": item,
                "chapter": 1,
                "quote": quote,
                "color": "gold",
                "note": page_note,
                "visibility": visibility,
                "client_time": "2026-10-04T10:00:00Z",
            },
        }

    results = push(
        client,
        ada,
        phone,
        note("I am Heathcliff", "friends", "Here it is."),
        note("A secret", "private"),
        note("For everyone", "public"),
    )
    assert [r["outcome"] for r in results.json()["results"]] == ["applied"] * 3

    friend = {n["quote"] for n in reader(client, people["bob"], "ada")["notes"]}
    assert friend == {"I am Heathcliff", "For everyone"}
    follower = {n["quote"] for n in reader(client, people["cleo"], "ada")["notes"]}
    assert follower == {"For everyone"}


def test_recommendations_go_to_friends_only(
    app: FastAPI, client: TestClient, people: dict[str, dict[str, str]]
) -> None:
    pushes = Pushes()
    app.state.container = replace(app.state.container, pusher=pushes)
    bob_phone = device(client, people["bob"], "Phone")
    client.put(f"/v1/devices/{bob_phone}/push-token", json={"token": "bob"}, headers=people["bob"])
    item = book(client, people["ada"], "Jane Eyre")

    sent = client.post(
        "/v1/social/recommendations",
        json={"to": "bob", "item_id": item, "message": "Tu vas adorer."},
        headers=people["ada"],
    )
    assert sent.status_code == 201, sent.text
    refused = client.post(
        "/v1/social/recommendations",
        json={"to": "cleo", "title": "Dune"},
        headers=people["ada"],
    )
    assert refused.status_code == 403
    link = client.post(
        "/v1/social/recommendations",
        json={"to": "bob", "title": "Arcane", "url": "https://archiveofourown.org/works/1"},
        headers=people["ada"],
    )
    assert link.status_code == 201

    inbox = client.get("/v1/social/recommendations", headers=people["bob"]).json()
    assert [(r["title"], r["sender"]["handle"], r["read"]) for r in inbox] == [
        ("Arcane", "ada", False),
        ("Jane Eyre", "ada", False),
    ]
    assert inbox[1]["message"] == "Tu vas adorer."
    assert (
        client.post(
            f"/v1/social/recommendations/{inbox[1]['id']}/read", headers=people["bob"]
        ).status_code
        == 204
    )
    assert client.get("/v1/social/recommendations", headers=people["bob"]).json()[1]["read"]
    assert (
        client.post(
            f"/v1/social/recommendations/{inbox[1]['id']}/read", headers=people["ada"]
        ).status_code
        == 404
    )
    assert [(t, d["kind"]) for _, t, _, d in pushes.sent] == [
        ("Recommandation", "recommendation"),
        ("Recommandation", "recommendation"),
    ]


def test_friend_requests_are_pushed(app: FastAPI, client: TestClient) -> None:
    pushes = Pushes()
    app.state.container = replace(app.state.container, pusher=pushes)
    ada, bob = account(client, "ada@example.com"), account(client, "bob@example.com")
    handle(client, ada, "ada")
    handle(client, bob, "bob")
    phone = device(client, bob, "Phone")
    client.put(f"/v1/devices/{phone}/push-token", json={"token": "bob"}, headers=bob)

    client.put("/v1/social/friends/bob", headers=ada)

    [(_, title, body, data)] = pushes.sent
    assert (title, body, data) == (
        "Demande d'ami",
        "ada veut devenir votre ami sur Babel",
        {"kind": "friend_request", "handle": "ada"},
    )


def test_unknown_handles_and_yourself_are_not_found(
    client: TestClient, people: dict[str, dict[str, str]]
) -> None:
    for path in ("/v1/social/readers/nobody", "/v1/social/readers/ada"):
        assert client.get(path, headers=people["ada"]).status_code == 404
    assert client.put("/v1/social/friends/ada", headers=people["ada"]).status_code == 404


def test_deleting_an_account_removes_its_social_traces(
    client: TestClient, people: dict[str, dict[str, str]]
) -> None:
    assert client.delete("/v1/me", headers=people["ada"]).status_code == 204
    assert client.get("/v1/social/friends", headers=people["bob"]).json()["friends"] == []
    assert client.get("/v1/social/readers", params={"q": "ad"}, headers=people["bob"]).json() == []


def test_comic_pages_take_notes_on_an_area(
    client: TestClient, people: dict[str, dict[str, str]]
) -> None:
    ada = people["ada"]
    item = book(client, ada, "Akira")
    phone = device(client, ada, "Phone")

    def page_note(region: str | None, quote: str = "") -> dict[str, Any]:
        return {
            "key": str(uuid.uuid4()),
            "entity": "annotation",
            "entity_id": str(uuid.uuid4()),
            "op": "upsert",
            "data": {
                "item_id": item,
                "chapter": 12,
                "quote": quote,
                "region": region,
                "color": "rose",
                "note": "Cette case !",
                "visibility": "friends",
                "client_time": "2026-10-04T10:00:00Z",
            },
        }

    results = push(
        client,
        ada,
        phone,
        page_note("0.1,0.2,0.5,0.3"),
        page_note(None),  # neither a quote nor an area
        page_note("0.8,0.2,0.5,0.3"),  # off the page
    ).json()["results"]
    assert [r["outcome"] for r in results] == ["applied", "rejected", "rejected"]

    [shared] = reader(client, people["bob"], "ada")["notes"]
    assert (shared["quote"], shared["page"], shared["region"], shared["note"]) == (
        "",
        12,
        "0.1000,0.2000,0.5000,0.3000",
        "Cette case !",
    )


def test_blocked_readers_disappear_for_each_other(
    client: TestClient, people: dict[str, dict[str, str]]
) -> None:
    ada, bob, cleo = people["ada"], people["bob"], people["cleo"]
    client.put("/v1/social/following/ada", headers=bob)

    assert client.put("/v1/social/blocks/bob", headers=ada).status_code == 204

    # Friendship and follows are gone, both ways.
    assert client.get("/v1/social/friends", headers=ada).json()["friends"] == []
    assert client.get("/v1/social/friends", headers=bob).json()["following"] == []
    # Neither finds nor sees the other.
    for viewer, other in ((ada, "bob"), (bob, "ada")):
        assert client.get(f"/v1/social/readers/{other}", headers=viewer).status_code == 404
        found = client.get("/v1/social/readers", params={"q": other}, headers=viewer).json()
        assert found == []
    assert client.put("/v1/social/friends/ada", headers=bob).status_code == 404
    assert (
        client.post(
            "/v1/social/recommendations", json={"to": "ada", "title": "Dune"}, headers=bob
        ).status_code
        == 404
    )
    # Others are not affected.
    assert client.get("/v1/social/readers/ada", headers=cleo).status_code == 200

    assert [r["handle"] for r in client.get("/v1/social/blocks", headers=ada).json()] == ["bob"]
    assert client.delete("/v1/social/blocks/bob", headers=ada).status_code == 204
    assert client.get("/v1/social/readers/ada", headers=bob).status_code == 200
    assert client.get("/v1/social/blocks", headers=ada).json() == []


def test_reports_reach_the_administrators(
    app: FastAPI, client: TestClient, people: dict[str, dict[str, str]]
) -> None:
    pushes = Pushes()
    app.state.container = replace(app.state.container, pusher=pushes)
    admin = account(client, "admin@example.com")
    phone = device(client, admin, "Phone")
    client.put(f"/v1/devices/{phone}/push-token", json={"token": "admin"}, headers=admin)

    reported = client.post(
        "/v1/social/reports",
        json={"handle": "dan", "reason": "harassment", "note": "Messages insistants."},
        headers=people["ada"],
    )
    assert reported.status_code == 204
    assert [(t, d["kind"]) for _, t, _, d in pushes.sent] == [("Signalement", "report")]

    assert client.get("/v1/admin/reports", headers=people["ada"]).status_code == 403
    [report] = client.get("/v1/admin/reports", headers=admin).json()
    assert (report["reporter"]["handle"], report["reported"]["handle"]) == ("ada", "dan")
    assert (report["reason"], report["note"], report["resolved"]) == (
        "harassment",
        "Messages insistants.",
        False,
    )
    assert (
        client.post(f"/v1/admin/reports/{report['id']}/resolve", headers=admin).status_code == 204
    )
    assert client.get("/v1/admin/reports", headers=admin).json()[0]["resolved"] is True
