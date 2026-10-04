from dataclasses import replace
from pathlib import Path

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from babel_api.core.config import Settings
from tests.api.v1.test_works import FakeBooks
from tests.books import NOT_A_BOOK, PDF, epub

PASSWORD = "correct horse battery"


def account(client: TestClient, email: str) -> dict[str, str]:
    session = client.post(
        "/v1/auth/register",
        json={"email": email, "password": PASSWORD, "display_name": email.split("@")[0]},
    ).json()
    return {"Authorization": f"Bearer {session['access_token']}"}


def upload(client: TestClient, auth: dict[str, str], content: bytes, name: str = "book.epub"):
    return client.post("/v1/library/files", files={"file": (name, content)}, headers=auth)


@pytest.fixture
def ada(client: TestClient) -> dict[str, str]:
    return account(client, "ada@example.com")


@pytest.fixture
def bob(client: TestClient) -> dict[str, str]:
    return account(client, "bob@example.com")


@pytest.fixture
def admin(client: TestClient) -> dict[str, str]:
    return account(client, "admin@example.com")


def stored(settings: Settings) -> list[Path]:
    return [p for p in Path(settings.files_dir).rglob("*") if p.is_file()]


def test_an_epub_is_imported_with_its_metadata(client: TestClient, ada: dict[str, str]) -> None:
    response = upload(client, ada, epub())

    assert response.status_code == 201
    body = response.json()
    assert body["deduplicated"] is False
    item = body["item"]
    assert item["title"] == "Jane Eyre"
    assert item["authors"] == ["Charlotte Brontë"]
    assert item["format"] == "epub"
    assert client.get("/v1/library", headers=ada).json() == [item]


def test_the_file_is_linked_to_the_known_edition(
    app: FastAPI, client: TestClient, ada: dict[str, str]
) -> None:
    app.state.container = replace(app.state.container, books=FakeBooks())
    edition_id = client.get("/v1/catalog/isbn/9782070360246", headers=ada).json()["edition_id"]

    item = upload(client, ada, epub()).json()["item"]

    assert item["edition_id"] == edition_id


def test_a_file_is_stored_once_for_everyone(
    client: TestClient, settings: Settings, ada: dict[str, str], bob: dict[str, str]
) -> None:
    upload(client, ada, epub())

    second = upload(client, bob, epub(), name="copy.epub").json()

    assert second["deduplicated"] is True
    assert len(stored(settings)) == 1
    assert len(client.get("/v1/library", headers=bob).json()) == 1


def test_a_stored_file_can_be_added_and_downloaded_without_uploading(
    client: TestClient, ada: dict[str, str], bob: dict[str, str]
) -> None:
    sha = upload(client, ada, PDF, name="essay.pdf").json()["item"]["sha256"]

    added = client.post(f"/v1/library/files/{sha}", headers=bob)
    download = client.get(f"/v1/files/{sha}", headers=bob)

    assert added.status_code == 201
    assert added.json()["title"] == "essay"
    assert download.status_code == 200
    assert download.content == PDF
    assert download.headers["content-type"] == "application/pdf"
    assert 'filename="essay.pdf"' in download.headers["content-disposition"]


def test_downloads_can_be_resumed(client: TestClient, ada: dict[str, str]) -> None:
    sha = upload(client, ada, PDF, name="essay.pdf").json()["item"]["sha256"]

    partial = client.get(f"/v1/files/{sha}", headers={**ada, "Range": "bytes=5-"})

    assert partial.status_code == 206
    assert partial.content == PDF[5:]


def test_downloads_require_an_account(client: TestClient, ada: dict[str, str]) -> None:
    sha = upload(client, ada, PDF).json()["item"]["sha256"]
    assert client.get(f"/v1/files/{sha}").status_code == 401


def test_files_that_are_not_books_are_refused(
    client: TestClient, settings: Settings, ada: dict[str, str]
) -> None:
    assert upload(client, ada, NOT_A_BOOK, name="book.epub").status_code == 415
    assert stored(settings) == []


def test_files_over_the_limit_are_refused(
    app: FastAPI, client: TestClient, settings: Settings, ada: dict[str, str]
) -> None:
    container = app.state.container
    app.state.container = replace(
        container, settings=container.settings.model_copy(update={"max_upload_mb": 0})
    )

    assert upload(client, ada, PDF).status_code == 413
    assert stored(settings) == []


def test_removing_a_book_keeps_it_for_other_readers(
    client: TestClient, ada: dict[str, str], bob: dict[str, str]
) -> None:
    item = upload(client, ada, PDF).json()["item"]
    client.post(f"/v1/library/files/{item['sha256']}", headers=bob)

    assert client.delete(f"/v1/library/{item['id']}", headers=ada).status_code == 204
    assert client.get("/v1/library", headers=ada).json() == []
    assert client.get(f"/v1/files/{item['sha256']}", headers=bob).status_code == 200
    # Nobody else can remove someone's library item.
    bob_item = client.get("/v1/library", headers=bob).json()[0]
    assert client.delete(f"/v1/library/{bob_item['id']}", headers=ada).status_code == 404


def test_only_administrators_can_withdraw(client: TestClient, ada: dict[str, str]) -> None:
    sha = upload(client, ada, PDF).json()["item"]["sha256"]

    response = client.post(f"/v1/admin/files/{sha}/withdraw", json={"reason": "test"}, headers=ada)

    assert response.status_code == 403


def test_a_withdrawn_file_disappears_and_cannot_come_back(
    client: TestClient,
    settings: Settings,
    ada: dict[str, str],
    bob: dict[str, str],
    admin: dict[str, str],
) -> None:
    sha = upload(client, ada, PDF).json()["item"]["sha256"]
    client.post(f"/v1/library/files/{sha}", headers=bob)

    response = client.post(
        f"/v1/admin/files/{sha}/withdraw", json={"reason": "Rights holder request"}, headers=admin
    )

    assert response.status_code == 204
    assert stored(settings) == []
    assert client.get("/v1/library", headers=ada).json() == []
    assert client.get("/v1/library", headers=bob).json() == []
    assert client.get(f"/v1/files/{sha}", headers=bob).status_code == 404
    assert upload(client, bob, PDF).status_code == 451
    assert stored(settings) == []


def test_a_file_withdrawn_without_blocking_can_be_imported_again(
    client: TestClient, ada: dict[str, str], admin: dict[str, str]
) -> None:
    sha = upload(client, ada, PDF).json()["item"]["sha256"]
    client.post(
        f"/v1/admin/files/{sha}/withdraw",
        json={"reason": "Duplicate cleanup", "block": False},
        headers=admin,
    )

    again = upload(client, ada, PDF)

    assert again.status_code == 201
    assert client.get(f"/v1/files/{sha}", headers=ada).status_code == 200


def test_entitled_policy_limits_downloads_to_owners(
    app: FastAPI, client: TestClient, ada: dict[str, str], bob: dict[str, str]
) -> None:
    container = app.state.container
    app.state.container = replace(
        container, settings=container.settings.model_copy(update={"file_access": "entitled"})
    )
    sha = upload(client, ada, PDF).json()["item"]["sha256"]

    assert client.get(f"/v1/files/{sha}", headers=ada).status_code == 200
    assert client.get(f"/v1/files/{sha}", headers=bob).status_code == 403
    assert client.post(f"/v1/library/files/{sha}", headers=bob).status_code == 403
