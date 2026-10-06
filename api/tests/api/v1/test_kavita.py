import json
from dataclasses import replace
from typing import Any

import httpx
import pytest
from cryptography.fernet import Fernet
from fastapi import FastAPI
from fastapi.testclient import TestClient
from pydantic import SecretStr

from babel_api.adapters.kavita import KavitaClient
from babel_api.adapters.security.secrets import SecretBox
from babel_api.adapters.sources.opds import OpdsConnector
from babel_api.domain.sources import SourceKind
from tests.api.v1.test_library import account

ADMIN_KEY = "admin-key-0123456789"
BASE = "https://kavita.example.com"
ACQ = "http://opds-spec.org/acquisition"


class Kavita:
    """A fake Kavita 0.9.1: accounts, invitations, auth keys and an OPDS catalog."""

    def __init__(self) -> None:
        # username -> account
        self.users: dict[str, dict[str, Any]] = {
            "jouskaio": {
                "email": "owner@example.com",
                "password": "owner-pass",
                "admin": True,
                "keys": [{"id": 1, "name": "Babel admin", "key": ADMIN_KEY}],
            },
            "lea": {"email": "lea@kavita.lan", "password": "lea-pass", "admin": False, "keys": []},
        }
        self.invites: dict[str, list[int]] = {}
        self.deleted: list[str] = []
        self.requests: list[str] = []
        self._next_key = 100

    def _token_user(self, request: httpx.Request) -> str | None:
        auth = request.headers.get("Authorization", "")
        return auth.removeprefix("Bearer jwt-") if auth.startswith("Bearer jwt-") else None

    def _user_by_key(self, key: str) -> str | None:
        return next((u for u, a in self.users.items() for k in a["keys"] if k["key"] == key), None)

    def __call__(self, request: httpx.Request) -> httpx.Response:
        path = request.url.path
        self.requests.append(f"{request.method} {path}")
        body: dict[str, Any] = json.loads(request.content) if request.content else {}
        me = self._token_user(request) or ""
        if path == "/api/health":
            return httpx.Response(200, text="Ok")
        if path == "/api/Account/login":
            if body.get("apiKey"):
                user = self._user_by_key(body["apiKey"])
            else:
                user = body.get("username")
                if user not in self.users or self.users[user]["password"] != body.get("password"):
                    user = None
            if user is None:
                return httpx.Response(401, text="Your credentials are not correct")
            return httpx.Response(200, json={"username": user, "token": f"jwt-{user}"})
        if path == "/api/Library/libraries":
            return httpx.Response(200, json=[{"id": 1, "name": "Livres"}, {"id": 2, "name": "BD"}])
        if path == "/api/Account/invite":
            assert me
            assert self.users[me]["admin"]
            email = body["email"]
            if any(a["email"] == email for a in self.users.values()) or email in self.invites:
                return httpx.Response(400, text="User is already registered as owner")
            assert body["roles"] == ["Login", "Download", "Bookmark", "Change Password"]
            self.invites[email] = body["libraries"]
            return httpx.Response(
                200,
                json={
                    "emailLink": f"{BASE}/registration/confirm-email"
                    f"?token=tok%2B{len(self.invites)}&email={email}",
                    "emailSent": False,
                    "invalidEmail": True,
                },
            )
        if path == "/api/Account/confirm-email":
            if body["email"] not in self.invites or not body["token"].startswith("tok+"):
                return httpx.Response(400, text="invalid-email-confirmation")
            if body["username"] in self.users:
                return httpx.Response(
                    400, text='[{"code":"DuplicateUserName","description":"Username taken"}]'
                )
            assert len(body["password"]) >= 6
            libraries = self.invites.pop(body["email"])
            self.users[body["username"]] = {
                "email": body["email"],
                "password": body["password"],
                "admin": False,
                "keys": [],
                "libraries": libraries,
            }
            return httpx.Response(
                200, json={"username": body["username"], "token": f"jwt-{body['username']}"}
            )
        if path == "/api/Account/auth-keys":
            return httpx.Response(200, json=self.users[me]["keys"])
        if path == "/api/Account/create-auth-key":
            self._next_key += 1
            key = {
                "id": self._next_key,
                "name": body["name"],
                "key": f"key{self._next_key}" + "x" * 20,
            }
            self.users[me]["keys"].append(key)
            return httpx.Response(200, json=key)
        if path == "/api/Account/opds-url":
            name = request.url.params["authKeyName"]
            key = next(k["key"] for k in self.users[me]["keys"] if k["name"] == name)
            return httpx.Response(200, text=f"{BASE}/api/opds/{key}")
        if path == "/api/Users/delete-user":
            assert me
            assert self.users[me]["admin"]
            name = request.url.params["username"]
            self.deleted.append(name)
            self.users.pop(name, None)
            for email in [e for e in self.invites if e == name]:
                self.invites.pop(email)
            return httpx.Response(200)
        if path.startswith("/api/opds/"):
            key = path.split("/")[3]
            if self._user_by_key(key) is None:
                return httpx.Response(401)
            return httpx.Response(
                200,
                headers={"content-type": "application/atom+xml"},
                text='<?xml version="1.0"?><feed xmlns="http://www.w3.org/2005/Atom"><title>K</title>'
                f'<entry><title>Monte-Cristo</title><link rel="{ACQ}" type="application/epub+zip" '
                f'href="/api/opds/{key}/series/1/volume/1/chapter/1/download/mc.epub"/></entry></feed>',
            )
        return httpx.Response(404)


@pytest.fixture
def kavita(app: FastAPI) -> Kavita:
    fake = Kavita()
    allowed = ("kavita.example.com",)

    def client(url: str) -> KavitaClient:
        return KavitaClient(url, httpx.AsyncClient(transport=httpx.MockTransport(fake)), allowed)

    container = app.state.container
    settings = container.settings.model_copy(
        update={"kavita_url": BASE, "kavita_admin_key": SecretStr(ADMIN_KEY)}
    )
    connectors = dict(container.connectors)
    connectors[SourceKind.OPDS] = OpdsConnector(
        httpx.AsyncClient(transport=httpx.MockTransport(fake)), allowed_hosts=allowed
    )
    app.state.container = replace(
        container,
        settings=settings,
        kavita_client=client,
        connectors=connectors,
        secrets=SecretBox(Fernet.generate_key().decode()),
    )
    return fake


def settle(app: FastAPI, client: TestClient) -> None:
    """Waits for background account creations (they run on the app's event loop)."""

    async def wait() -> None:
        await app.state.container.kavita.wait()

    client.portal.call(wait)  # type: ignore[union-attr]


def me(client: TestClient, auth: dict[str, str]) -> dict[str, Any]:
    return client.get("/v1/me", headers=auth).json()


def test_any_reader_links_their_own_kavita(client: TestClient, kavita: Kavita) -> None:
    reader = account(client, "reader@example.com")
    assert client.get("/v1/me/kavita", headers=reader).json() is None

    wrong = client.post(
        "/v1/me/kavita",
        json={"url": BASE, "username": "lea", "password": "nope"},
        headers=reader,
    )
    assert (wrong.status_code, wrong.json()["detail"]) == (400, "kavita:unauthorized")

    linked = client.post(
        "/v1/me/kavita",
        json={"url": BASE, "username": "lea", "password": "lea-pass"},
        headers=reader,
    )
    assert linked.status_code == 200, linked.text
    assert (linked.json()["status"], linked.json()["managed"]) == ("ready", False)
    # A "Babel" key was made on Lea's account; her password is not kept.
    assert [k["name"] for k in kavita.users["lea"]["keys"]] == ["Babel"]
    [source] = client.get("/v1/sources", headers=reader).json()
    assert (source["kind"], source["name"], source["book_count"]) == ("opds", "Kavita", 1)
    assert "{key}" in source["location"] or source["location"].startswith(BASE)

    # Linking again reuses the same key.
    client.post(
        "/v1/me/kavita",
        json={"url": BASE, "username": "lea", "password": "lea-pass"},
        headers=reader,
    )
    assert len(kavita.users["lea"]["keys"]) == 1
    assert len(client.get("/v1/sources", headers=reader).json()) == 1

    assert client.delete("/v1/me/kavita", headers=reader).status_code == 204
    assert client.get("/v1/me/kavita", headers=reader).json() is None
    assert client.get("/v1/sources", headers=reader).json() == []


def test_administrators_get_an_account_on_babels_kavita(
    app: FastAPI, client: TestClient, kavita: Kavita
) -> None:
    admin = account(client, "admin@example.com")  # listed in BABEL_ADMIN_EMAILS in tests
    assert me(client, admin)["admin"] is True
    assert me(client, admin)["premium"] is True
    settle(app, client)

    link = client.get("/v1/me/kavita", headers=admin).json()
    assert (link["status"], link["managed"], link["username"]) == ("ready", True, "admin")
    created = kavita.users["admin"]
    assert created["email"] == "admin@example.com"
    assert created["libraries"] == [1, 2]  # every library
    assert [k["name"] for k in created["keys"]] == ["Babel"]
    [source] = client.get("/v1/sources", headers=admin).json()
    assert source["book_count"] == 1


def test_admins_make_readers_premium_and_back(
    app: FastAPI, client: TestClient, kavita: Kavita
) -> None:
    admin = account(client, "admin@example.com")
    reader = account(client, "bob@example.com")
    settle(app, client)
    assert me(client, reader)["premium"] is False
    members = client.get("/v1/admin/users", headers=admin).json()
    bob = next(m for m in members if m["email"] == "bob@example.com")
    assert (bob["premium"], bob["kavita"]) == (False, None)

    # Only administrators.
    assert client.get("/v1/admin/users", headers=reader).status_code == 403
    assert (
        client.put(
            f"/v1/admin/users/{bob['id']}/premium", json={"premium": True}, headers=reader
        ).status_code
        == 403
    )

    granted = client.put(
        f"/v1/admin/users/{bob['id']}/premium", json={"premium": True}, headers=admin
    )
    assert granted.json()["premium"] is True
    settle(app, client)
    assert me(client, reader)["premium"] is True
    assert client.get("/v1/me/kavita", headers=reader).json()["status"] == "ready"
    assert "bob" in kavita.users

    client.put(f"/v1/admin/users/{bob['id']}/premium", json={"premium": False}, headers=admin)
    assert "bob" in kavita.deleted
    assert client.get("/v1/me/kavita", headers=reader).json() is None
    assert client.get("/v1/sources", headers=reader).json() == []


def test_an_existing_kavita_account_is_not_taken_over(
    app: FastAPI, client: TestClient, kavita: Kavita
) -> None:
    kavita.users["jouskaio"]["email"] = "admin@example.com"
    admin = account(client, "admin@example.com")
    settle(app, client)
    link = client.get("/v1/me/kavita", headers=admin).json()
    assert link["status"] == "exists"
    # Then the reader links it with its own password.
    linked = client.post(
        "/v1/me/kavita",
        json={"url": BASE, "username": "jouskaio", "password": "owner-pass"},
        headers=admin,
    )
    assert (linked.json()["status"], linked.json()["managed"]) == ("ready", False)


def test_a_taken_user_name_gets_a_number(app: FastAPI, client: TestClient, kavita: Kavita) -> None:
    kavita.users["admin"] = {"email": "other@x", "password": "p" * 8, "admin": False, "keys": []}
    account(client, "admin@example.com")
    settle(app, client)
    assert "admin2" in kavita.users


def test_deleting_the_babel_account_deletes_the_kavita_one(
    app: FastAPI, client: TestClient, kavita: Kavita
) -> None:
    admin = account(client, "admin@example.com")
    settle(app, client)
    assert client.delete("/v1/me", headers=admin).status_code == 204
    assert "admin" in kavita.deleted


def test_without_babels_kavita_nothing_is_created(app: FastAPI, client: TestClient) -> None:
    admin = account(client, "admin@example.com")
    settle(app, client)
    assert me(client, admin)["admin"] is True
    assert client.get("/v1/me/kavita", headers=admin).json() is None
