"""Deleting a book for good, and the tags that help find books in the library."""

import json
import sqlite3
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

from babel_api.api import dependencies
from babel_api.core.config import Settings
from tests.api.v1.test_annotations import NOTE_ID, annotation
from tests.api.v1.test_library import account, upload
from tests.api.v1.test_sync import device, position, pull, push
from tests.books import PDF, epub


@pytest.fixture
def ada(client: TestClient) -> dict[str, str]:
    return account(client, "ada@example.com")


@pytest.fixture
def bob(client: TestClient) -> dict[str, str]:
    return account(client, "bob@example.com")


def stored_books(settings: Settings) -> list[Path]:
    """The stored files (covers kept next to them are not books)."""
    return [
        p
        for p in Path(settings.files_dir).rglob("*")
        if p.is_file() and "covers" not in p.parts and "exports" not in p.parts
    ]


def test_a_book_only_its_reader_has_is_deleted_with_its_file(
    client: TestClient, settings: Settings, ada: dict[str, str]
) -> None:
    item = upload(client, ada, PDF).json()["item"]
    assert stored_books(settings)

    response = client.delete(f"/v1/library/{item['id']}/forever", headers=ada)

    assert response.status_code == 200
    assert response.json() == {"file_deleted": True}
    assert client.get("/v1/library", headers=ada).json() == []
    assert client.get(f"/v1/files/{item['sha256']}", headers=ada).status_code == 404
    assert stored_books(settings) == []
    # Devices learn it left the library.
    deletes = [c for c in pull(client, ada)["changes"] if c["op"] == "delete"]
    assert [c["entity_id"] for c in deletes] == [item["id"]]


def test_a_book_deleted_for_good_comes_back_without_its_data(
    client: TestClient, ada: dict[str, str]
) -> None:
    item = upload(client, ada, epub()).json()["item"]
    phone = device(client, ada, "Phone")
    push(client, ada, phone, position("op-00001", item["id"], 40, "2026-11-08T10:00:00+00:00"))
    push(client, ada, phone, annotation(item["id"], "2026-11-08T10:00:00+00:00"))
    assert client.get(f"/v1/library/{item['id']}/positions", headers=ada).json()
    since = pull(client, ada)["cursor"]

    client.delete(f"/v1/library/{item['id']}/forever", headers=ada)
    again = upload(client, ada, epub()).json()["item"]

    assert again["id"] != item["id"]
    assert client.get(f"/v1/library/{again['id']}/positions", headers=ada).json() == []
    # Its highlights are gone from every device.
    deleted = [
        (c["entity"], c["entity_id"])
        for c in pull(client, ada, since)["changes"]
        if c["op"] == "delete"
    ]
    assert ("annotation", NOTE_ID) in deleted
    assert ("library_item", item["id"]) in deleted


def test_a_file_other_readers_have_stays_for_them(
    client: TestClient, ada: dict[str, str], bob: dict[str, str]
) -> None:
    item = upload(client, ada, PDF).json()["item"]
    client.post(f"/v1/library/files/{item['sha256']}", headers=bob)

    response = client.delete(f"/v1/library/{item['id']}/forever", headers=ada)

    assert response.json() == {"file_deleted": False}
    assert client.get("/v1/library", headers=ada).json() == []
    assert client.get(f"/v1/files/{item['sha256']}", headers=bob).status_code == 200


def test_a_book_taken_out_of_the_library_can_be_deleted_for_good(
    client: TestClient, settings: Settings, ada: dict[str, str]
) -> None:
    item = upload(client, ada, PDF).json()["item"]
    client.delete(f"/v1/library/{item['id']}", headers=ada)

    response = client.delete(f"/v1/library/{item['id']}/forever", headers=ada)

    assert response.json() == {"file_deleted": True}
    assert stored_books(settings) == []


def test_nobody_deletes_another_readers_book(
    client: TestClient, settings: Settings, ada: dict[str, str], bob: dict[str, str]
) -> None:
    item = upload(client, ada, PDF).json()["item"]

    response = client.delete(f"/v1/library/{item['id']}/forever", headers=bob)

    assert response.status_code == 404
    assert len(client.get("/v1/library", headers=ada).json()) == 1
    assert stored_books(settings)


def test_library_books_carry_the_tags_of_their_file(
    client: TestClient, ada: dict[str, str]
) -> None:
    content = epub(
        subjects=(
            "Fantasy",
            "Governesses -- Fiction",
            "fantasy",
            "nyt:hardcover-fiction=2008-05-04",
        )
    )

    item = upload(client, ada, content).json()["item"]

    assert item["tags"] == ["Fantasy", "Governesses"]
    assert client.get("/v1/library", headers=ada).json()[0]["tags"] == ["Fantasy", "Governesses"]


def test_books_written_to_devices_before_tags_get_them(
    client: TestClient, ada: dict[str, str], settings: Settings
) -> None:
    upload(client, ada, epub(subjects=("Romance",)))
    # As the change log wrote it before books had tags.
    with sqlite3.connect(settings.database_url.removeprefix("sqlite+aiosqlite:///")) as db:
        for seq, data in db.execute("SELECT seq, data FROM changes").fetchall():
            book = json.loads(data)
            book.pop("tags", None)
            db.execute("UPDATE changes SET data = ? WHERE seq = ?", (json.dumps(book), seq))
    dependencies._tags_checked.clear()  # pyright: ignore[reportPrivateUsage]

    first = client.get("/v1/sync", headers=ada).json()
    again = client.get("/v1/sync", params={"since": first["cursor"]}, headers=ada).json()

    [change] = again["changes"]
    assert change["entity"] == "library_item"
    assert change["data"]["tags"] == ["Romance"]
    # Once up to date, nothing more is written.
    dependencies._tags_checked.clear()  # pyright: ignore[reportPrivateUsage]
    client.get("/v1/sync", headers=ada)
    assert (
        client.get("/v1/sync", params={"since": again["cursor"]}, headers=ada).json()["changes"]
        == []
    )
