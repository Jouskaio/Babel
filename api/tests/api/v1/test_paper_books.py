"""Paper books: followed without a file, and given one to read on devices too."""

import uuid
from dataclasses import replace
from typing import Any

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from tests.api.v1.test_library import account, upload
from tests.api.v1.test_shelves import state
from tests.api.v1.test_sync import device, push
from tests.api.v1.test_works import FakeBooks
from tests.books import epub


@pytest.fixture
def books(app: FastAPI) -> FakeBooks:
    fake = FakeBooks()
    app.state.container = replace(app.state.container, books=fake)
    return fake


@pytest.fixture
def ada(client: TestClient) -> dict[str, str]:
    return account(client, "ada@example.com")


def jane(client: TestClient, auth: dict[str, str]) -> str:
    (hit,) = client.get("/v1/catalog/search", params={"q": "jane"}, headers=auth).json()
    return hit["id"]


def paper(client: TestClient, auth: dict[str, str], work: str) -> Any:
    return client.post("/v1/library/paper", json={"work_id": work}, headers=auth)


def attach(client: TestClient, auth: dict[str, str], item: str, content: bytes) -> Any:
    return client.post(
        f"/v1/library/{item}/file", files={"file": ("book.epub", content)}, headers=auth
    )


@pytest.mark.usefixtures("books")
def test_a_paper_book_is_followed_then_given_a_file(
    client: TestClient, ada: dict[str, str]
) -> None:
    work = jane(client, ada)
    created = paper(client, ada, work)
    assert created.status_code == 201, created.text
    book = created.json()
    assert (book["title"], book["paper"], book["work_id"]) == ("Jane Eyre", True, work)
    assert (book["sha256"], book["format"], book["size"]) == (None, None, None)
    assert book["cover_path"] == "/v1/catalog/covers/8235363/M"

    phone = device(client, ada, "Pixel")
    push(
        client,
        ada,
        phone,
        state("op-pa0001", book["id"], "2026-10-05T10:00:00+00:00", "reading", 30),
    )
    # No file, no notes in it.
    note = {
        "key": "op-pa0002",
        "entity": "annotation",
        "entity_id": str(uuid.uuid4()),
        "op": "upsert",
        "data": {
            "item_id": book["id"],
            "chapter": 0,
            "quote": "x",
            "client_time": "2026-10-05T10:00:00+00:00",
        },
    }
    assert push(client, ada, phone, note).json()["results"][0]["outcome"] == "rejected"

    # Read on the phone too: same book, same status and progress.
    with_file = attach(client, ada, book["id"], epub(title="Jane Eyre", isbn=None))
    assert with_file.status_code == 200, with_file.text
    assert with_file.json()["id"] == book["id"]
    assert with_file.json()["format"] == "epub"
    assert (with_file.json()["status"], with_file.json()["progress"]) == ("reading", 30)
    assert with_file.json()["paper"] is True
    [only] = client.get("/v1/library", headers=ada).json()
    assert only["id"] == book["id"]


@pytest.mark.usefixtures("books")
def test_a_book_already_in_the_library_is_marked_as_paper(
    client: TestClient, ada: dict[str, str]
) -> None:
    work = jane(client, ada)
    item = upload(client, ada, epub(title="Jane Eyre", isbn=None)).json()["item"]
    assert item["work_id"] == work

    marked = paper(client, ada, work).json()

    assert (marked["id"], marked["paper"], marked["format"]) == (item["id"], True, "epub")
    unmarked = client.put(f"/v1/library/{item['id']}/paper", json={"paper": False}, headers=ada)
    assert unmarked.json()["paper"] is False


@pytest.mark.usefixtures("books")
def test_a_paper_book_no_longer_owned_leaves_with_its_data(
    client: TestClient, ada: dict[str, str]
) -> None:
    work = jane(client, ada)
    book = paper(client, ada, work).json()
    client.put(f"/v1/library/{book['id']}/review", json={"rating": 5}, headers=ada)

    client.put(f"/v1/library/{book['id']}/paper", json={"paper": False}, headers=ada)

    assert client.get("/v1/library", headers=ada).json() == []
    [trace] = client.get("/v1/library/history", headers=ada).json()
    assert (trace["removed_at"] is not None, trace["available"]) == (True, True)
    back = paper(client, ada, work).json()
    assert back["id"] == book["id"]
    assert client.get(f"/v1/library/{book['id']}/review", headers=ada).json()["rating"] == 5


@pytest.mark.usefixtures("books")
def test_a_file_already_another_book_is_refused(client: TestClient, ada: dict[str, str]) -> None:
    content = epub(title="Villette", isbn=None)
    upload(client, ada, content)
    book = paper(client, ada, jane(client, ada)).json()

    assert attach(client, ada, book["id"], content).status_code == 409


@pytest.mark.usefixtures("books")
def test_paper_books_count_in_the_year(client: TestClient, ada: dict[str, str]) -> None:
    book = paper(client, ada, jane(client, ada)).json()
    push(
        client,
        ada,
        device(client, ada, "Pixel"),
        state("op-pa0003", book["id"], "2026-04-05T10:00:00+00:00", "finished"),
    )

    stats = client.get("/v1/me/stats", params={"year": 2026}, headers=ada).json()

    assert stats["formats"] == {"paper": 1}
    assert stats["finished"][0]["cover_path"] == "/v1/catalog/covers/8235363/M"
