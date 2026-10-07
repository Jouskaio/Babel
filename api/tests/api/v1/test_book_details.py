"""Series, volumes and the details of a book, corrected by its reader."""

from typing import Any

import pytest
from fastapi.testclient import TestClient

from tests.api.v1.test_library import account, upload
from tests.books import cbz, epub


@pytest.fixture
def ada(client: TestClient) -> dict[str, str]:
    return account(client, "ada@example.com")


def add(client: TestClient, auth: dict[str, str], content: bytes, name: str = "b.epub") -> Any:
    response = upload(client, auth, content, name=name)
    assert response.status_code == 201, response.text
    return response.json()["item"]


def test_a_volume_is_recognized_from_its_title(client: TestClient, ada: dict[str, str]) -> None:
    item = add(client, ada, epub(title="Homunculus 3", isbn=None))
    assert (item["series"], item["series_index"]) == ("Homunculus", 3.0)
    plain = add(client, ada, epub(title="Jane Eyre", isbn=None))
    assert (plain["series"], plain["series_index"]) == (None, None)
    year = add(client, ada, epub(title="Fahrenheit 451", isbn=None))
    assert year["series"] is None


def test_a_file_that_names_its_series_wins_over_the_title(
    client: TestClient, ada: dict[str, str]
) -> None:
    calibre = add(client, ada, epub(title="Dune 1", isbn=None, series=("Le Cycle de Dune", "1.0")))
    assert (calibre["series"], calibre["series_index"]) == ("Le Cycle de Dune", 1.0)
    comic = add(
        client,
        ada,
        cbz("<Series>Akira</Series><Number>06</Number><Genre>Seinen, Sci-Fi</Genre>"),
        name="akira-6.cbz",
    )
    assert (comic["series"], comic["series_index"]) == ("Akira", 6.0)


def test_the_reader_corrects_a_book(client: TestClient, ada: dict[str, str]) -> None:
    item = add(client, ada, epub(title="Homunculus 3", isbn=None))
    url = f"/v1/library/{item['id']}"

    renamed = client.patch(
        url,
        json={
            "title": "  Homunculus — tome 3 ",
            "authors": ["Hideo  Yamamoto", " "],
            "series": "Homunculus (Big Spirits)",
            "series_index": 3,
            "cover_id": 777,
        },
        headers=ada,
    ).json()

    assert renamed["title"] == "Homunculus — tome 3"
    assert renamed["authors"] == ["Hideo Yamamoto"]
    assert (renamed["series"], renamed["series_index"]) == ("Homunculus (Big Spirits)", 3.0)
    assert renamed["cover_path"] == "/v1/catalog/covers/777/M"
    assert renamed["cover_id"] == 777
    # The change reaches the other devices through the log.
    log = client.get("/v1/sync", params={"since": 0}, headers=ada).json()["changes"]
    assert log[-1]["data"]["title"] == "Homunculus — tome 3"
    assert log[-1]["data"]["series"] == "Homunculus (Big Spirits)"

    # Only what is sent changes; an empty series clears the volume too; a null cover goes
    # back to the file's.
    partly = client.patch(url, json={"series_index": 4}, headers=ada).json()
    assert (partly["title"], partly["series_index"]) == ("Homunculus — tome 3", 4.0)
    cleared = client.patch(url, json={"series": "", "cover_id": None}, headers=ada).json()
    assert (cleared["series"], cleared["series_index"]) == (None, None)
    assert cleared["cover_path"] != "/v1/catalog/covers/777/M"


def test_invalid_details_and_other_readers(client: TestClient, ada: dict[str, str]) -> None:
    bob = account(client, "bob@example.com")
    item = add(client, ada, epub(title="Emma", isbn=None))
    url = f"/v1/library/{item['id']}"

    assert client.patch(url, json={"title": ""}, headers=ada).status_code == 422
    assert client.patch(url, json={"series_index": -1}, headers=ada).status_code == 422
    # A title of spaces passes the shape check but is no title.
    assert client.patch(url, json={"title": "   "}, headers=ada).status_code == 400
    assert client.patch(url, json={"title": "Mine"}, headers=bob).status_code == 404
    assert client.get("/v1/library", headers=ada).json()[0]["title"] == "Emma"
