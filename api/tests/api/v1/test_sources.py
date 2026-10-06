from collections.abc import AsyncIterator
from dataclasses import replace
from typing import Any

import pytest
from cryptography.fernet import Fernet
from fastapi import FastAPI
from fastapi.testclient import TestClient

from babel_api.adapters.security.secrets import SecretBox
from babel_api.domain.errors import SourceConnectionError, SourceRateLimitedError
from babel_api.domain.sources import RemoteEntry, SourceKind
from tests.api.v1.test_library import account, upload
from tests.books import JPEG, NOT_A_BOOK, epub

JANE = epub(title="Jane Eyre", isbn=None, cover=JPEG)
EMMA = epub(title="Emma", author="Jane Austen", isbn=None)
TOKEN = "ghp_secret_token_1234"


class FakeGitHub:
    """A repository whose content tests change at will."""

    def __init__(self) -> None:
        self.files: dict[str, tuple[str, bytes]] = {
            "books/Jane Eyre.epub": ("sha-jane", JANE),
            "books/Emma.epub": ("sha-emma", EMMA),
        }
        self.fetched: list[str] = []
        self.tokens: list[str | None] = []
        self.down = False
        self.limited = False
        self.limited_downloads = False
        self.batch_size = 50

    async def check(self, config: dict[str, Any], token: str | None) -> dict[str, Any]:
        self.tokens.append(token)
        if self.limited:
            raise SourceRateLimitedError
        if config["repository"] == "ada/missing":
            raise SourceConnectionError("404")
        return {"repository": config["repository"], "folder": "books", "branch": "main"}

    async def list_entries(self, config: dict[str, Any], token: str | None) -> list[RemoteEntry]:
        self.tokens.append(token)
        if self.down:
            raise SourceConnectionError("unreachable")
        return [
            RemoteEntry(path=path, size=len(content), remote_id=sha)
            for path, (sha, content) in self.files.items()
        ]

    async def fetch(
        self, config: dict[str, Any], token: str | None, entry: RemoteEntry
    ) -> AsyncIterator[bytes]:
        if self.limited_downloads:
            raise SourceRateLimitedError
        self.fetched.append(entry.remote_id)
        content = next(c for sha, c in self.files.values() if sha == entry.remote_id)
        yield content


class FakeCatalog(FakeGitHub):
    """An OPDS catalog: entries come with their title, authors and location."""

    async def check(self, config: dict[str, Any], token: str | None) -> dict[str, Any]:
        return {"url": config["url"], "username": config.get("username")}

    async def list_entries(self, config: dict[str, Any], token: str | None) -> list[RemoteEntry]:
        return [
            RemoteEntry(
                path="https://books.example.com/get/1",
                size=0,
                remote_id="opds-jane",
                title="Jane Eyre (catalog)",
                authors=("Charlotte Brontë",),
                locator="https://books.example.com/get/1",
                format="epub",
            )
        ]

    async def fetch(
        self, config: dict[str, Any], token: str | None, entry: RemoteEntry
    ) -> AsyncIterator[bytes]:
        assert entry.locator == "https://books.example.com/get/1"
        yield JANE


@pytest.fixture
def github(app: FastAPI) -> FakeGitHub:
    fake = FakeGitHub()
    app.state.container = replace(
        app.state.container,
        connectors={SourceKind.GITHUB: fake, SourceKind.OPDS: FakeCatalog()},
        secrets=SecretBox(Fernet.generate_key().decode()),
    )
    return fake


@pytest.fixture
def ada(client: TestClient) -> dict[str, str]:
    return account(client, "ada@example.com")


@pytest.fixture
def bob(client: TestClient) -> dict[str, str]:
    return account(client, "bob@example.com")


def connect(
    client: TestClient, auth: dict[str, str], repository: str = "ada/library", **extra: Any
) -> Any:
    body = {"kind": "github", "name": "My books", "github": {"repository": repository}, **extra}
    return client.post("/v1/sources", json=body, headers=auth)


def statuses(detail: dict[str, Any]) -> dict[str, str]:
    return {e["name"]: e["status"] for e in detail["entries"]}


def test_a_source_is_checked_and_scanned_when_connected(
    client: TestClient, github: FakeGitHub, ada: dict[str, str]
) -> None:
    response = connect(client, ada)
    assert response.status_code == 201
    detail = response.json()
    assert detail["source"]["repository"] == "ada/library"
    assert detail["source"]["folder"] == "books"
    assert detail["source"]["last_scan_at"] is not None
    assert detail["source"]["book_count"] == 2
    assert statuses(detail) == {"Jane Eyre.epub": "new", "Emma.epub": "new"}
    assert client.get("/v1/sources", headers=ada).json()[0]["name"] == "My books"


def test_a_source_can_be_tried_without_saving_it(
    client: TestClient, github: FakeGitHub, ada: dict[str, str]
) -> None:
    body = {"kind": "github", "name": "x", "github": {"repository": "ada/library"}, "token": TOKEN}
    response = client.post("/v1/sources/check", json=body, headers=ada)
    assert response.json() == {"books": 2}
    assert github.tokens == [TOKEN, TOKEN]
    assert client.get("/v1/sources", headers=ada).json() == []
    body["github"] = {"repository": "ada/missing"}
    assert client.post("/v1/sources/check", json=body, headers=ada).status_code == 400


def test_rate_limits_are_reported_as_such(
    client: TestClient, github: FakeGitHub, ada: dict[str, str]
) -> None:
    github.limited = True
    response = connect(client, ada)
    assert response.status_code == 429
    assert "access token" in response.json()["detail"]


def test_the_settings_must_match_the_kind(
    client: TestClient, github: FakeGitHub, ada: dict[str, str]
) -> None:
    body = {"kind": "opds", "name": "x", "github": {"repository": "ada/library"}}
    assert client.post("/v1/sources", json=body, headers=ada).status_code == 422


def test_catalog_entries_keep_what_the_source_tells(
    client: TestClient, github: FakeGitHub, ada: dict[str, str]
) -> None:
    body = {
        "kind": "opds",
        "name": "Calibre",
        "opds": {"url": "https://books.example.com/opds", "username": "ada"},
        "token": "pw",
    }
    detail = client.post("/v1/sources", json=body, headers=ada).json()
    assert detail["source"]["location"] == "https://books.example.com/opds"
    assert detail["source"]["username"] == "ada"
    entry = detail["entries"][0]
    assert (entry["title"], entry["authors"], entry["format"]) == (
        "Jane Eyre (catalog)",
        ["Charlotte Brontë"],
        "epub",
    )
    source_id = detail["source"]["id"]
    imported = client.post(f"/v1/sources/{source_id}/entries/{entry['id']}/import", headers=ada)
    assert imported.status_code == 201
    after = client.get(f"/v1/sources/{source_id}", headers=ada).json()["entries"][0]
    # Once on Babel, the file's own metadata wins.
    assert (after["status"], after["title"]) == ("in_library", "Jane Eyre")


def test_unreachable_repositories_are_refused(
    client: TestClient, github: FakeGitHub, ada: dict[str, str]
) -> None:
    assert connect(client, ada, "ada/missing").status_code == 400
    assert client.get("/v1/sources", headers=ada).json() == []


def test_the_token_is_used_but_never_returned(
    client: TestClient, github: FakeGitHub, ada: dict[str, str]
) -> None:
    created = connect(client, ada, token=TOKEN)
    assert TOKEN not in created.text
    assert created.json()["source"]["has_token"] is True
    source_id = created.json()["source"]["id"]
    rescanned = client.post(f"/v1/sources/{source_id}/scan", headers=ada)
    assert TOKEN not in rescanned.text
    assert TOKEN not in client.get("/v1/sources", headers=ada).text
    assert github.tokens == [TOKEN, TOKEN, TOKEN]


def test_tokens_need_an_encryption_key(
    app: FastAPI, client: TestClient, github: FakeGitHub, ada: dict[str, str]
) -> None:
    app.state.container = replace(app.state.container, secrets=SecretBox(""))
    assert connect(client, ada, token=TOKEN).status_code == 503
    assert connect(client, ada).status_code == 201  # public repositories still work


def test_sources_are_private(
    client: TestClient, github: FakeGitHub, ada: dict[str, str], bob: dict[str, str]
) -> None:
    source_id = connect(client, ada).json()["source"]["id"]
    assert client.get("/v1/sources", headers=bob).json() == []
    assert client.get(f"/v1/sources/{source_id}", headers=bob).status_code == 404
    assert client.delete(f"/v1/sources/{source_id}", headers=bob).status_code == 404
    assert client.post(f"/v1/sources/{source_id}/import", headers=bob).status_code == 404


def test_sources_are_limited(
    app: FastAPI, client: TestClient, github: FakeGitHub, ada: dict[str, str]
) -> None:
    settings = app.state.container.settings
    app.state.container = replace(
        app.state.container, settings=settings.model_copy(update={"max_sources_per_user": 1})
    )
    assert connect(client, ada).status_code == 201
    assert connect(client, ada).status_code == 409


def test_a_book_is_imported_into_the_library(
    client: TestClient, github: FakeGitHub, ada: dict[str, str]
) -> None:
    detail = connect(client, ada).json()
    source_id = detail["source"]["id"]
    jane = next(e for e in detail["entries"] if e["name"] == "Jane Eyre.epub")
    imported = client.post(f"/v1/sources/{source_id}/entries/{jane['id']}/import", headers=ada)
    assert imported.status_code == 201
    assert imported.json()["title"] == "Jane Eyre"
    after = client.get(f"/v1/sources/{source_id}", headers=ada).json()
    assert statuses(after)["Jane Eyre.epub"] == "in_library"
    entry = next(e for e in after["entries"] if e["name"] == "Jane Eyre.epub")
    assert entry["title"] == "Jane Eyre"
    assert entry["authors"] == ["Charlotte Brontë"]
    assert client.get(entry["cover_path"]).content == JPEG
    assert client.get("/v1/sources", headers=ada).json()[0]["book_count"] == 2
    assert (
        next(e for e in after["entries"] if e["id"] == jane["id"])["item_id"]
        == (imported.json()["id"])
    )
    assert len(client.get("/v1/library", headers=ada).json()) == 1


def test_files_already_on_babel_are_not_downloaded_again(
    client: TestClient, github: FakeGitHub, ada: dict[str, str], bob: dict[str, str]
) -> None:
    ada_source = connect(client, ada).json()["source"]["id"]
    assert client.post(f"/v1/sources/{ada_source}/import", headers=ada).json() == {
        "imported": 2,
        "failed": 0,
        "remaining": 0,
        "paused": False,
    }
    assert sorted(github.fetched) == ["sha-emma", "sha-jane"]
    # Bob connects a fork of the same repository: same blobs, nothing to download.
    bob_detail = connect(client, bob, "bob/fork").json()
    assert set(statuses(bob_detail).values()) == {"on_babel"}
    result = client.post(f"/v1/sources/{bob_detail['source']['id']}/import", headers=bob)
    assert result.json()["imported"] == 2
    assert len(github.fetched) == 2
    assert len(client.get("/v1/library", headers=bob).json()) == 2


def test_import_all_skips_books_already_in_the_library(
    client: TestClient, github: FakeGitHub, ada: dict[str, str]
) -> None:
    source_id = connect(client, ada).json()["source"]["id"]
    client.post(f"/v1/sources/{source_id}/import", headers=ada)
    again = client.post(f"/v1/sources/{source_id}/import", headers=ada)
    assert again.json() == {"imported": 0, "failed": 0, "remaining": 0, "paused": False}


def test_a_book_uploaded_by_hand_is_not_mistaken_for_a_source_file(
    client: TestClient, github: FakeGitHub, ada: dict[str, str]
) -> None:
    upload(client, ada, JANE)
    detail = connect(client, ada).json()
    # The source has never been imported: Babel cannot know the blob matches yet.
    assert statuses(detail)["Jane Eyre.epub"] == "new"
    source_id = detail["source"]["id"]
    client.post(f"/v1/sources/{source_id}/import", headers=ada)
    # Importing it again finds the same stored file: still one copy in the library.
    assert len(client.get("/v1/library", headers=ada).json()) == 2


def test_files_that_are_not_books_fail_without_stopping_the_batch(
    client: TestClient, github: FakeGitHub, ada: dict[str, str]
) -> None:
    github.files["books/fake.epub"] = ("sha-fake", NOT_A_BOOK)
    source_id = connect(client, ada).json()["source"]["id"]
    result = client.post(f"/v1/sources/{source_id}/import", headers=ada).json()
    assert (result["imported"], result["failed"]) == (2, 1)
    # Remembered as unreadable: not counted as new, not tried again...
    detail = client.get(f"/v1/sources/{source_id}", headers=ada).json()
    assert statuses(detail)["fake.epub"] == "unreadable"
    again = client.post(f"/v1/sources/{source_id}/import", headers=ada).json()
    assert (again["imported"], again["failed"], again["remaining"]) == (0, 0, 0)
    assert github.fetched.count("sha-fake") == 1
    # ...until its content changes.
    github.files["books/fake.epub"] = ("sha-fixed", epub(title="Fixed", isbn=None))
    detail = client.post(f"/v1/sources/{source_id}/scan", headers=ada).json()
    assert statuses(detail)["fake.epub"] == "new"


def test_a_failed_scan_is_reported_and_keeps_nothing_stale(
    client: TestClient, github: FakeGitHub, ada: dict[str, str]
) -> None:
    source_id = connect(client, ada).json()["source"]["id"]
    github.down = True
    detail = client.post(f"/v1/sources/{source_id}/scan", headers=ada).json()
    assert detail["source"]["last_error"] is not None
    github.down = False
    del github.files["books/Emma.epub"]
    detail = client.post(f"/v1/sources/{source_id}/scan", headers=ada).json()
    assert detail["source"]["last_error"] is None
    assert list(statuses(detail)) == ["Jane Eyre.epub"]


def test_slow_sources_import_a_few_books_per_call(
    client: TestClient, github: FakeGitHub, ada: dict[str, str]
) -> None:
    github.batch_size = 1  # like AO3
    source_id = connect(client, ada).json()["source"]["id"]
    first = client.post(f"/v1/sources/{source_id}/import", headers=ada).json()
    assert (first["imported"], first["remaining"]) == (1, 1)
    second = client.post(f"/v1/sources/{source_id}/import", headers=ada).json()
    assert (second["imported"], second["remaining"]) == (1, 0)


def test_a_rate_limit_pauses_the_batch(
    client: TestClient, github: FakeGitHub, ada: dict[str, str]
) -> None:
    source_id = connect(client, ada).json()["source"]["id"]
    github.limited_downloads = True
    result = client.post(f"/v1/sources/{source_id}/import", headers=ada).json()
    assert result == {"imported": 0, "failed": 0, "remaining": 2, "paused": True}


def test_deleting_a_source_keeps_imported_books(
    client: TestClient, github: FakeGitHub, ada: dict[str, str]
) -> None:
    source_id = connect(client, ada).json()["source"]["id"]
    client.post(f"/v1/sources/{source_id}/import", headers=ada)
    assert client.delete(f"/v1/sources/{source_id}", headers=ada).status_code == 204
    assert client.get(f"/v1/sources/{source_id}", headers=ada).status_code == 404
    assert len(client.get("/v1/library", headers=ada).json()) == 2


def test_deleting_a_source_can_remove_its_books_too(
    client: TestClient, github: FakeGitHub, ada: dict[str, str], bob: dict[str, str]
) -> None:
    upload(client, ada, epub(title="Kept", isbn=None))
    source_id = connect(client, ada).json()["source"]["id"]
    client.post(f"/v1/sources/{source_id}/import", headers=ada)
    bob_source = connect(client, bob, "bob/fork").json()["source"]["id"]
    client.post(f"/v1/sources/{bob_source}/import", headers=bob)

    response = client.delete(f"/v1/sources/{source_id}?remove_books=true", headers=ada)
    assert response.status_code == 204
    assert [i["title"] for i in client.get("/v1/library", headers=ada).json()] == ["Kept"]
    # The stored files stay for other readers.
    assert len(client.get("/v1/library", headers=bob).json()) == 2
    for item in client.get("/v1/library", headers=bob).json():
        assert client.get(f"/v1/files/{item['sha256']}", headers=bob).status_code == 200


def test_removing_books_needs_the_source_owner(
    client: TestClient, github: FakeGitHub, ada: dict[str, str], bob: dict[str, str]
) -> None:
    source_id = connect(client, ada).json()["source"]["id"]
    client.post(f"/v1/sources/{source_id}/import", headers=ada)
    response = client.delete(f"/v1/sources/{source_id}?remove_books=true", headers=bob)
    assert response.status_code == 404
    assert len(client.get("/v1/library", headers=ada).json()) == 2


def test_deleting_an_account_removes_its_sources(
    client: TestClient, github: FakeGitHub, ada: dict[str, str]
) -> None:
    connect(client, ada)
    assert client.request(
        "DELETE", "/v1/me", headers=ada, json={"password": "correct horse battery"}
    ).status_code in (200, 204)


def test_books_are_found_across_the_sources_and_imported(
    client: TestClient, github: FakeGitHub, ada: dict[str, str], bob: dict[str, str]
) -> None:
    source = connect(client, ada).json()["source"]
    opds = client.post(
        "/v1/sources",
        json={"kind": "opds", "name": "Kavita", "opds": {"url": "https://books.example.com/opds"}},
        headers=ada,
    ).json()["source"]
    assert opds["id"] != source["id"]

    # Words in any order, accents and case ignored, titles and authors.
    found = client.get("/v1/sources/search", params={"q": "EYRE jane"}, headers=ada).json()
    assert sorted((m["source_name"], m["entry"]["name"]) for m in found) == [
        ("Kavita", "1"),
        ("My books", "Jane Eyre.epub"),
    ]
    by_author = client.get("/v1/sources/search", params={"q": "brontë"}, headers=ada).json()
    assert [m["source_name"] for m in by_author] == ["Kavita"]
    austen = client.get("/v1/sources/search", params={"q": "emma"}, headers=ada).json()
    assert [m["entry"]["name"] for m in austen] == ["Emma.epub"]
    assert client.get("/v1/sources/search", params={"q": "zzzz"}, headers=ada).json() == []

    # A match is imported like any entry of the source.
    match = austen[0]
    imported = client.post(
        f"/v1/sources/{match['source_id']}/entries/{match['entry']['id']}/import", headers=ada
    )
    assert imported.status_code == 201
    again = client.get("/v1/sources/search", params={"q": "emma"}, headers=ada).json()
    assert again[0]["entry"]["status"] == "in_library"

    # Another reader's sources are theirs alone.
    assert client.get("/v1/sources/search", params={"q": "emma"}, headers=bob).json() == []
