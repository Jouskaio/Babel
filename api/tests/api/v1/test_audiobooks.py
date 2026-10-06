"""Audiobooks from a linked Audiobookshelf (a fake one here)."""

import json
import uuid
from dataclasses import replace
from typing import Any

import httpx
from cryptography.fernet import Fernet
import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from babel_api.adapters.audiobookshelf import AbsClient
from babel_api.adapters.security.secrets import SecretBox
from tests.api.v1.test_library import account
from tests.books import JPEG

URL = "http://abs.example.com"
AUDIO = bytes(range(256)) * 40  # a "track" of 10 240 bytes


class FakeAbs:
    def __init__(self) -> None:
        self.access = "a1"
        self.refresh = "r1"
        self.refresh_works = True
        self.progress: dict[str, Any] | None = None
        self.calls: list[str] = []

    def item(self) -> dict[str, Any]:
        return {
            "id": "li1",
            "media": {
                "metadata": {
                    "title": "Dune",
                    "authorName": "Frank Herbert",
                    "narratorName": "Simon Vance",
                    "genres": ["Science Fiction"],
                },
                "duration": 7200.0,
                "audioFiles": [
                    {"index": 2, "ino": "f2", "duration": 3600.0, "mimeType": "audio/mpeg"},
                    {"index": 1, "ino": "f1", "duration": 3600.0, "mimeType": "audio/mpeg"},
                ],
                "chapters": [
                    {"id": 0, "start": 0, "end": 3000, "title": "Livre un"},
                    {"id": 1, "start": 3000, "end": 7200, "title": "Livre deux"},
                ],
            },
        }

    def handler(self, request: httpx.Request) -> httpx.Response:
        path = request.url.path
        self.calls.append(f"{request.method} {path}")
        if path == "/status":
            return httpx.Response(200, json={"app": "audiobookshelf", "serverVersion": "2.37.1"})
        if path == "/login":
            body = json.loads(request.content)
            if body != {"username": "ada", "password": "right"}:
                return httpx.Response(401)
            assert request.headers["x-return-tokens"] == "true"
            return httpx.Response(
                200,
                json={
                    "user": {
                        "username": "ada",
                        "accessToken": self.access,
                        "refreshToken": self.refresh,
                    }
                },
            )
        if path == "/auth/refresh":
            if not self.refresh_works or request.headers.get("x-refresh-token") != self.refresh:
                return httpx.Response(401)
            self.access, self.refresh = "a-new", "r-new"
            return httpx.Response(
                200, json={"user": {"accessToken": self.access, "refreshToken": self.refresh}}
            )
        if request.headers.get("authorization") not in (f"Bearer {self.access}", "Bearer key-1"):
            return httpx.Response(401)
        if path == "/api/me":
            return httpx.Response(200, json={"username": "ada"})
        if path == "/api/libraries":
            return httpx.Response(
                200,
                json={
                    "libraries": [
                        {"id": "lib1", "name": "Livres audio", "mediaType": "book"},
                        {"id": "pod", "name": "Podcasts", "mediaType": "podcast"},
                    ]
                },
            )
        if path == "/api/libraries/lib1/items":
            return httpx.Response(200, json={"results": [self.item()]})
        if path == "/api/libraries/lib1/search":
            return httpx.Response(200, json={"book": [{"libraryItem": self.item()}]})
        if path == "/api/items/li1":
            return httpx.Response(200, json=self.item())
        if path == "/api/items/li1/cover":
            return httpx.Response(200, content=JPEG, headers={"content-type": "image/jpeg"})
        if path == "/api/me/progress/li1":
            if request.method == "PATCH":
                self.progress = json.loads(request.content)
                return httpx.Response(200)
            if self.progress is None:
                return httpx.Response(404)
            return httpx.Response(200, json={**self.progress, "lastUpdate": 1791280000000})
        if path == "/api/items/li1/file/f2":
            wanted = request.headers.get("range", "")
            if wanted.startswith("bytes="):
                start, end = (int(x) for x in wanted[6:].split("-"))
                return httpx.Response(
                    206,
                    content=AUDIO[start : end + 1],
                    headers={
                        "content-type": "audio/mpeg",
                        "content-range": f"bytes {start}-{end}/{len(AUDIO)}",
                        "accept-ranges": "bytes",
                    },
                )
            return httpx.Response(200, content=AUDIO, headers={"content-type": "audio/mpeg"})
        return httpx.Response(404)


@pytest.fixture
def abs_server(app: FastAPI) -> FakeAbs:
    fake = FakeAbs()

    def factory(url: str) -> AbsClient:
        return AbsClient(
            url,
            client=httpx.AsyncClient(transport=httpx.MockTransport(fake.handler)),
            allowed_hosts=("abs.example.com",),
        )

    app.state.container = replace(
        app.state.container,
        abs_client=factory,
        secrets=SecretBox(Fernet.generate_key().decode()),
    )
    return fake


@pytest.fixture
def ada(client: TestClient) -> dict[str, str]:
    return account(client, "ada@example.com")


def link(client: TestClient, auth: dict[str, str], **body: str) -> Any:
    return client.post("/v1/me/audiobookshelf", json={"url": URL, **body}, headers=auth)


def test_link_browse_add_and_listen(
    client: TestClient, ada: dict[str, str], abs_server: FakeAbs
) -> None:
    assert client.get("/v1/me/audiobookshelf", headers=ada).status_code == 204
    assert (
        link(client, ada, username="ada", password="wrong").json()["detail"] == "abs:unauthorized"
    )
    linked = link(client, ada, username="ada", password="right")
    assert linked.status_code == 200, linked.text
    assert linked.json() == {"base_url": URL, "username": "ada", "api_key": False, "expired": False}

    assert client.get("/v1/audiobookshelf/libraries", headers=ada).json() == [
        {"id": "lib1", "name": "Livres audio"}
    ]
    [dune] = client.get("/v1/audiobookshelf/libraries/lib1/books", headers=ada).json()
    assert (dune["title"], dune["authors"], dune["duration"], dune["item_id"]) == (
        "Dune",
        ["Frank Herbert"],
        7200.0,
        None,
    )
    found = client.get("/v1/audiobookshelf/libraries/lib1/books", params={"q": "dune"}, headers=ada)
    assert [b["id"] for b in found.json()] == ["li1"]

    added = client.post("/v1/audiobookshelf/books/li1", headers=ada)
    assert added.status_code == 201, added.text
    item = added.json()
    assert (item["title"], item["audio_duration"], item["sha256"]) == ("Dune", 7200.0, None)
    assert client.get(item["cover_path"]).content == JPEG
    again = client.get("/v1/audiobookshelf/libraries/lib1/books", headers=ada).json()
    assert again[0]["item_id"] == item["id"]

    playback = client.get(f"/v1/library/{item['id']}/audio", headers=ada).json()
    assert [(t["index"], t["start"]) for t in playback["tracks"]] == [(0, 0.0), (1, 3600.0)]
    assert [c["title"] for c in playback["chapters"]] == ["Livre un", "Livre deux"]
    assert (playback["narrators"], playback["remote_position"]) == (["Simon Vance"], None)

    # Tracks are signed: a player needs no header, and only this book is opened.
    path = playback["tracks"][1]["path"]
    part = client.get(path, headers={"Range": "bytes=100-199"})
    assert part.status_code == 206
    assert part.content == AUDIO[100:200]
    assert part.headers["content-range"] == f"bytes 100-199/{len(AUDIO)}"
    assert client.get(path.replace("ticket=", "ticket=x")).status_code == 401
    assert client.get(path.replace(item["id"], str(uuid.uuid4()))).status_code == 401

    saved = client.put(
        f"/v1/library/{item['id']}/audio/progress", json={"current_time": 4000}, headers=ada
    )
    assert saved.status_code == 204
    assert abs_server.progress == {
        "currentTime": 4000.0,
        "duration": 7200.0,
        "progress": pytest.approx(4000 / 7200),
        "isFinished": False,
    }
    remote = client.get(f"/v1/library/{item['id']}/audio", headers=ada).json()["remote_position"]
    assert remote["current_time"] == 4000.0


def test_sessions_are_refreshed_then_expire(
    client: TestClient, ada: dict[str, str], abs_server: FakeAbs
) -> None:
    link(client, ada, username="ada", password="right")
    # Audiobookshelf ended the access token: the refresh token gets a new one.
    abs_server.access = "a-rotated-elsewhere"
    abs_server.refresh, abs_server.refresh_works = "r1", True
    abs_server.access = "a1-expired"
    assert client.get("/v1/audiobookshelf/libraries", headers=ada).status_code == 200
    assert "POST /auth/refresh" in abs_server.calls

    abs_server.access = "a-gone"
    abs_server.refresh_works = False
    refused = client.get("/v1/audiobookshelf/libraries", headers=ada)
    assert refused.json()["detail"] == "abs:expired"
    assert client.get("/v1/me/audiobookshelf", headers=ada).json()["expired"] is True


def test_an_api_key_links_without_password(
    client: TestClient, ada: dict[str, str], abs_server: FakeAbs
) -> None:
    linked = link(client, ada, api_key="key-1").json()
    assert (linked["api_key"], linked["username"]) == (True, "ada")
    assert client.get("/v1/audiobookshelf/libraries", headers=ada).status_code == 200
    assert client.delete("/v1/me/audiobookshelf", headers=ada).status_code == 204
    assert client.get("/v1/me/audiobookshelf", headers=ada).status_code == 204


def test_audiobooks_count_as_books(
    client: TestClient, ada: dict[str, str], abs_server: FakeAbs
) -> None:
    link(client, ada, username="ada", password="right")
    item = client.post("/v1/audiobookshelf/books/li1", headers=ada).json()
    bob = account(client, "bob@example.com")
    assert client.get(f"/v1/library/{item['id']}/audio", headers=bob).status_code == 404
    # Removed then added again: the same book, data kept.
    client.delete(f"/v1/library/{item['id']}", headers=ada)
    back = client.post("/v1/audiobookshelf/books/li1", headers=ada).json()
    assert back["id"] == item["id"]
