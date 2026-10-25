"""KOReader's progress sync."""

import hashlib
from pathlib import Path

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from babel_api.domain.koreader import partial_md5
from tests.api.v1.test_library import account, upload
from tests.books import epub


def test_koreader_identifies_a_file_by_a_few_samples(tmp_path: Path) -> None:
    data = bytes(range(256)) * 40  # 10 240 bytes: samples at 0, 1 KiB, 4 KiB, then past the end
    path = tmp_path / "book.epub"
    path.write_bytes(data)
    expected = hashlib.md5(
        data[0:1024] + data[1024:2048] + data[4096:5120], usedforsecurity=False
    ).hexdigest()
    assert partial_md5(path) == expected


@pytest.fixture
def ada(client: TestClient) -> dict[str, str]:
    return account(client, "ada@example.com")


def test_progress_goes_both_ways_with_koreader(
    client: TestClient, ada: dict[str, str], tmp_path: Path
) -> None:
    content = epub(title="Jane Eyre", isbn=None)
    item = upload(client, ada, content).json()["item"]
    path = tmp_path / "jane.epub"
    path.write_bytes(content)
    document = partial_md5(path)

    status = client.get("/v1/me/koreader/status", headers=ada).json()
    assert (status["last_seen_at"], status["last_unmatched_at"], status["recent"]) == (
        None,
        None,
        [],
    )
    info = client.get("/v1/me/koreader", headers=ada).json()
    assert info["has_password"] is False
    assert info["username"] == "ada@example.com"
    # The public address, which KOReader can reach directly (not the proxy's http one).
    assert info["server"] == "http://localhost:8080/v1/kosync"
    assert info["webdav"] == "http://localhost:8080/v1/webdav"
    password = client.post("/v1/me/koreader/password", headers=ada).json()["password"]
    key = {
        "x-auth-user": "ada@example.com",
        "x-auth-key": hashlib.md5(password.encode(), usedforsecurity=False).hexdigest(),
    }

    assert client.get("/v1/kosync/users/auth", headers=key).json() == {"authorized": "OK"}
    wrong = {**key, "x-auth-key": "0" * 32}
    assert client.get("/v1/kosync/users/auth", headers=wrong).status_code == 401
    assert (
        "percentage" not in client.get("/v1/kosync/syncs/progress/" + document, headers=key).json()
    )

    body = {
        "document": document,
        "progress": "/body/DocFragment[3]/body/p[2]/text().10",
        "percentage": 0.42,
        "device": "Boox Go",
        "device_id": "abc",
    }
    assert client.put("/v1/kosync/syncs/progress", json=body, headers=key).status_code == 200
    back = client.get("/v1/kosync/syncs/progress/" + document, headers=key).json()
    assert back["progress"] == body["progress"]
    assert back["percentage"] == pytest.approx(0.42)
    assert back["device"] == "KOReader · Boox Go"

    # It is a reading position like any other: the book is now "reading", on an e-reader.
    positions = client.get(f"/v1/library/{item['id']}/positions", headers=ada).json()
    assert positions[0]["percent"] == pytest.approx(42.0)
    # A book that is not in the library does not make KOReader fail: its position is kept aside.
    unknown = {**body, "document": "f" * 32, "percentage": 0.1}
    assert client.put("/v1/kosync/syncs/progress", json=unknown, headers=key).status_code == 200
    kept = client.get("/v1/kosync/syncs/progress/" + "f" * 32, headers=key).json()
    assert kept["percentage"] == pytest.approx(0.1)
    nothing = client.get("/v1/kosync/syncs/progress/" + "e" * 32, headers=key)
    assert nothing.status_code == 200
    assert "percentage" not in nothing.json()  # "no progress yet", not an error

    # The reader can check it works: KOReader called, its books, and a book Babel did not know.
    status = client.get("/v1/me/koreader/status", headers=ada).json()
    assert status["last_seen_at"] is not None
    assert status["last_unmatched_at"] is not None
    assert [d["name"] for d in status["devices"]] == ["Boox Go"]
    (recent,) = status["recent"]
    assert (recent["title"], recent["device"]) == ("Jane Eyre", "KOReader · Boox Go")
    assert recent["percent"] == pytest.approx(42.0)
    assert status["unknown_books"] == 1


def test_koreader_can_also_name_a_book_by_its_file_name(
    client: TestClient, ada: dict[str, str]
) -> None:
    content = epub(title="Jane Eyre", isbn=None)
    upload(client, ada, content, name="Jane Eyre.epub")
    password = client.post("/v1/me/koreader/password", headers=ada).json()["password"]
    key = {
        "x-auth-user": "ada@example.com",
        "x-auth-key": hashlib.md5(password.encode(), usedforsecurity=False).hexdigest(),
    }
    by_name = hashlib.md5(b"Jane Eyre.epub", usedforsecurity=False).hexdigest()
    body = {
        "document": by_name,
        "progress": "x",
        "percentage": 0.5,
        "device": "Boox",
        "device_id": "1",
    }
    assert client.put("/v1/kosync/syncs/progress", json=body, headers=key).status_code == 200


def test_koreader_cloud_storage_lists_downloads_and_receives_books(
    app: FastAPI, client: TestClient, ada: dict[str, str]
) -> None:
    import base64
    from dataclasses import replace

    from babel_api.domain.sources import RemoteEntry

    class FakeAo3:
        async def work(self, work_id: str) -> RemoteEntry:
            return RemoteEntry(path=f"/works/{work_id}", size=0, remote_id=f"{work_id}:3/3|2026")

    app.state.container = replace(app.state.container, ao3=FakeAo3())

    content = epub(title="Jane Eyre", isbn=None)
    upload(client, ada, content, name="Jane Eyre.epub")
    password = client.post("/v1/me/koreader/password", headers=ada).json()["password"]
    login = base64.b64encode(f"ada@example.com:{password}".encode()).decode()
    auth = {"authorization": f"Basic {login}"}

    assert client.request("OPTIONS", "/v1/webdav").headers["dav"] == "1"
    assert client.request("PROPFIND", "/v1/webdav/").status_code == 401  # not signed in
    bad = base64.b64encode(b"ada@example.com:wrong").decode()
    refused = client.request("PROPFIND", "/v1/webdav/", headers={"authorization": f"Basic {bad}"})
    assert refused.status_code == 401

    listing = client.request("PROPFIND", "/v1/webdav/", headers={**auth, "depth": "1"})
    assert listing.status_code == 207
    assert "<D:collection/>" in listing.text
    # Named after the author and the title, not after whatever the file was called.
    assert "Charlotte%20Bront%C3%AB%20-%20Jane%20Eyre.epub" in listing.text
    assert f"<D:getcontentlength>{len(content)}</D:getcontentlength>" in listing.text

    nice = "/v1/webdav/Charlotte%20Bront%C3%AB%20-%20Jane%20Eyre.epub"
    assert client.get(nice, headers=auth).content == content
    assert client.get("/v1/webdav/missing.epub", headers=auth).status_code == 404

    # The Babel plugin is offered as a folder, to install it without unzipping anything.
    assert "babel.koplugin" in listing.text
    folder = client.request("PROPFIND", "/v1/webdav/babel.koplugin/", headers=auth)
    assert "main.lua.txt" in folder.text
    assert "_meta.lua.txt" in folder.text
    assert "Babel" in client.get("/v1/webdav/babel.koplugin/_meta.lua.txt", headers=auth).text
    assert client.get("/v1/webdav/babel.koplugin/x.lua", headers=auth).status_code == 404

    # Sending a file from the e-reader puts it in the library (a fanfiction is recognised).
    fic = epub(
        title="A Work", isbn=None, source="https://archiveofourown.org/works/9", author="Someone"
    )
    sent = client.put("/v1/webdav/A%20Work.epub", content=fic, headers=auth)
    assert sent.status_code == 201
    library = client.get("/v1/library", headers=ada).json()
    assert {i["title"]: i["origin"] for i in library} == {"Jane Eyre": None, "A Work": "ao3"}
    again = client.put("/v1/webdav/A%20Work.epub", content=fic, headers=auth)
    assert again.status_code == 201
    assert len(client.get("/v1/library", headers=ada).json()) == 2  # not twice


def test_koreader_reading_statistics_join_the_readers_own(
    client: TestClient, ada: dict[str, str]
) -> None:
    from datetime import date

    password = client.post("/v1/me/koreader/password", headers=ada).json()["password"]
    key = {
        "x-auth-user": "ada@example.com",
        "x-auth-key": hashlib.md5(password.encode(), usedforsecurity=False).hexdigest(),
    }
    year = date.today().year
    md5 = "a" * 32
    body = {
        "books": [
            {"md5": md5, "title": "Jane Eyre", "authors": "Brontë", "pages": 400,
             "total_read_time": 5400, "total_read_pages": 180}
        ],
        "days": [
            {"md5": md5, "day": f"{year}-03-01", "seconds": 3600, "pages": 100},
            {"md5": md5, "day": f"{year}-03-02", "seconds": 1800, "pages": 80},
        ],
    }  # fmt: skip
    sent = client.put("/v1/kosync/syncs/stats", json=body, headers=key)
    assert sent.json() == {"books": 1, "days": 2}
    # Sent again with a day corrected: replaced, not added.
    body["days"][1]["seconds"] = 600
    client.put("/v1/kosync/syncs/stats", json=body, headers=key)
    empty = client.put("/v1/kosync/syncs/stats", json={"books": {}, "days": {}}, headers=key)
    assert empty.status_code == 200  # an empty Lua table arrives as {}

    stats = client.get("/v1/me/stats", params={"year": year}, headers=ada).json()
    assert stats["reading_seconds"] == 4200
    assert stats["pages_read"] == 180
    assert stats["reading_days"] == 2  # days measured on the e-reader count
    status = client.get("/v1/me/koreader/status", headers=ada).json()
    assert (status["stats_books"], status["stats_seconds"]) == (1, 4200)
    assert status["stats_at"] is not None
    other = client.get("/v1/me/stats", params={"year": year - 1}, headers=ada).json()
    assert other["reading_seconds"] == 0


def test_a_koreader_book_can_be_tied_by_hand_to_a_library_book(
    client: TestClient, ada: dict[str, str]
) -> None:
    item = upload(client, ada, epub(title="Jane Eyre", isbn=None)).json()["item"]
    password = client.post("/v1/me/koreader/password", headers=ada).json()["password"]
    key = {
        "x-auth-user": "ada@example.com",
        "x-auth-key": hashlib.md5(password.encode(), usedforsecurity=False).hexdigest(),
    }
    document = "a" * 32  # a file converted on the e-reader: another md5 than the library's
    body = {"document": document, "progress": "x", "percentage": 0.3, "device": "Boox"}
    assert client.put("/v1/kosync/syncs/progress", json=body, headers=key).status_code == 200

    (unknown,) = client.get("/v1/me/koreader/unknown", headers=ada).json()
    assert unknown["md5"] == document
    assert unknown["percent"] == pytest.approx(30.0)

    tie = {"md5": document, "item_id": item["id"]}
    assert client.post("/v1/me/koreader/link", json=tie, headers=ada).status_code == 204
    assert client.get("/v1/me/koreader/unknown", headers=ada).json() == []
    positions = client.get(f"/v1/library/{item['id']}/positions", headers=ada).json()
    assert positions[0]["percent"] == pytest.approx(30.0)
    back = client.get("/v1/kosync/syncs/progress/" + document, headers=key).json()
    assert back["percentage"] == pytest.approx(0.3)
    nobody = {"md5": document, "item_id": "00000000-0000-0000-0000-000000000000"}
    assert client.post("/v1/me/koreader/link", json=nobody, headers=ada).status_code == 404


def test_a_koreader_book_can_be_forgotten_and_stays_out(
    client: TestClient, ada: dict[str, str]
) -> None:
    password = client.post("/v1/me/koreader/password", headers=ada).json()["password"]
    key = {
        "x-auth-user": "ada@example.com",
        "x-auth-key": hashlib.md5(password.encode(), usedforsecurity=False).hexdigest(),
    }
    document = "b" * 32
    body = {"document": document, "progress": "x", "percentage": 0.3, "device": "Boox"}
    client.put("/v1/kosync/syncs/progress", json=body, headers=key)
    assert len(client.get("/v1/me/koreader/unknown", headers=ada).json()) == 1

    gone = client.delete(f"/v1/me/koreader/unknown/{document}", headers=ada)
    assert gone.status_code == 204
    assert client.get("/v1/me/koreader/unknown", headers=ada).json() == []
    # KOReader keeps sending it: still nothing kept.
    client.put("/v1/kosync/syncs/progress", json=body, headers=key)
    assert client.get("/v1/me/koreader/unknown", headers=ada).json() == []
    assert client.get("/v1/me/koreader/status", headers=ada).json()["unknown_books"] == 0


def test_a_download_is_named_after_the_book(client: TestClient, ada: dict[str, str]) -> None:
    item = upload(
        client, ada, epub(title="Jane Eyre", isbn=None), name="x (Z-Library).epub"
    ).json()["item"]
    assert item["filename"] == "Charlotte Brontë - Jane Eyre.epub"
    got = client.get(f"/v1/files/{item['sha256']}", headers=ada)
    disposition = got.headers["content-disposition"]
    assert "Jane%20Eyre.epub" in disposition
    assert "Z-Library" not in disposition
