"""KOReader's progress sync."""

import hashlib
import uuid
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


def test_the_community_library_shares_books_but_fanfictions_only_when_chosen(
    app: FastAPI, client: TestClient, ada: dict[str, str]
) -> None:
    from dataclasses import replace

    from babel_api.domain.sources import RemoteEntry

    class FakeAo3:
        async def work(self, work_id: str) -> RemoteEntry:
            return RemoteEntry(path=f"/works/{work_id}", size=0, remote_id=f"{work_id}:1/1|x")

    app.state.container = replace(app.state.container, ao3=FakeAo3())
    bob = account(client, "bob@example.com")
    book = upload(client, ada, epub(title="Jane Eyre", isbn=None)).json()["item"]
    fic = upload(
        client,
        ada,
        epub(title="A Work", isbn=None, source="https://archiveofourown.org/works/9"),
    ).json()["item"]
    assert fic["origin"] == "ao3"

    seen = client.get("/v1/community", headers=bob).json()
    assert [b["title"] for b in seen["books"]] == ["Jane Eyre"]  # the fanfiction is kept private
    assert seen["books"][0]["in_library"] is False
    assert client.get("/v1/community", params={"q": "eyre"}, headers=bob).json()["books"]
    assert client.get("/v1/community", params={"q": "zzz"}, headers=bob).json()["books"] == []

    added = client.post(f"/v1/library/files/{book['sha256']}", headers=bob)
    assert added.status_code == 201
    assert client.get("/v1/community", headers=bob).json()["books"][0]["in_library"] is True

    shared = client.put(f"/v1/library/{fic['id']}/shared", json={"shared": True}, headers=ada)
    assert shared.json()["shared"] is True
    titles = {b["title"] for b in client.get("/v1/community", headers=bob).json()["books"]}
    assert titles == {"Jane Eyre", "A Work"}


def test_the_plugin_lists_and_downloads_the_books_for_the_e_reader(
    client: TestClient, ada: dict[str, str]
) -> None:
    content = epub(title="Jane Eyre", isbn=None)
    item = upload(client, ada, content).json()["item"]
    password = client.post("/v1/me/koreader/password", headers=ada).json()["password"]
    key = {
        "x-auth-user": "ada@example.com",
        "x-auth-key": hashlib.md5(password.encode(), usedforsecurity=False).hexdigest(),
    }
    assert client.get("/v1/kosync/library", headers=key).json() == {"books": []}
    client.put(f"/v1/library/{item['id']}/ereader", json={"ereader": True}, headers=ada)
    (book,) = client.get("/v1/kosync/library", headers=key).json()["books"]
    assert book["name"] == "Charlotte Brontë - Jane Eyre.epub"
    assert book["size"] == len(content)
    got = client.get(f"/v1/kosync/library/files/{book['sha256']}", headers=key)
    assert got.content == content
    assert client.get(f"/v1/kosync/library/files/{book['sha256']}").status_code == 401
    everything = client.get("/v1/kosync/library", params={"scope": "all"}, headers=key)
    assert len(everything.json()["books"]) == 1


def test_a_book_finished_and_highlights_made_in_koreader_reach_babel(
    client: TestClient, ada: dict[str, str]
) -> None:
    content = epub(title="Jane Eyre", isbn=None)
    item = upload(client, ada, content).json()["item"]
    client.put(f"/v1/library/{item['id']}/ereader", json={"ereader": True}, headers=ada)
    password = client.post("/v1/me/koreader/password", headers=ada).json()["password"]
    key = {
        "x-auth-user": "ada@example.com",
        "x-auth-key": hashlib.md5(password.encode(), usedforsecurity=False).hexdigest(),
    }
    (book,) = client.get("/v1/kosync/library", headers=key).json()["books"]
    document = "c" * 32
    # KOReader names the book by its own identifier: link it first, as the reader would.
    client.put(
        "/v1/kosync/syncs/progress",
        json={"document": document, "progress": "x", "percentage": 0.5, "device": "Boox"},
        headers=key,
    )
    client.post("/v1/me/koreader/link", json={"md5": document, "item_id": item["id"]}, headers=ada)

    notes = {
        "document": document,
        "device": "Boox",
        "annotations": [
            {"text": "Reader, I married him.", "note": "yes", "datetime": "2026-10-20 21:00:00"}
        ],
    }
    first = client.put("/v1/kosync/syncs/annotations", json=notes, headers=key)
    assert first.json() == {"added": 1}
    assert client.put("/v1/kosync/syncs/annotations", json=notes, headers=key).json() == {
        "added": 0
    }  # sent again: nothing new
    assert client.put(
        "/v1/kosync/syncs/annotations", json={**notes, "document": "d" * 32}, headers=key
    ).json() == {"added": 0}  # a book Babel does not have

    done = client.put(
        "/v1/kosync/syncs/finished", json={"document": document, "device": "Boox"}, headers=key
    )
    assert done.json() == {"applied": True}
    listed = client.get("/v1/library", headers=ada).json()
    assert listed[0]["status"] == "finished"
    # A finished book leaves the e-reader's list.
    assert client.get("/v1/kosync/library", headers=key).json() == {"books": []}
    assert book["name"].endswith("Jane Eyre.epub")


def test_a_shared_file_can_be_reported_and_the_administrators_decide(
    client: TestClient, ada: dict[str, str]
) -> None:
    bob = account(client, "bob@example.com")
    boss = account(client, "admin@example.com")
    item = upload(client, ada, epub(title="Jane Eyre", isbn=None)).json()["item"]
    sha = item["sha256"]
    assert client.get("/v1/admin/file-reports", headers=boss).json() == []

    sent = client.post(
        f"/v1/community/{sha}/report", json={"reason": "not mine to share"}, headers=bob
    )
    assert sent.status_code == 204
    client.post(f"/v1/community/{sha}/report", json={"reason": "again"}, headers=bob)  # no double
    (report,) = client.get("/v1/admin/file-reports", headers=boss).json()
    assert (report["sha256"], report["reports"]) == (sha, 1)
    assert client.get("/v1/admin/file-reports", headers=bob).status_code == 403
    assert client.post(f"/v1/community/{'0' * 64}/report", json={}, headers=bob).status_code == 404

    kept = client.post(f"/v1/admin/file-reports/{sha}/dismiss", headers=boss)
    assert kept.status_code == 204
    assert client.get("/v1/admin/file-reports", headers=boss).json() == []


def test_books_coming_from_the_e_reader_are_marked_as_on_it(
    client: TestClient, ada: dict[str, str], tmp_path: Path
) -> None:
    password = client.post("/v1/me/koreader/password", headers=ada).json()["password"]
    key = {
        "x-auth-user": "ada@example.com",
        "x-auth-key": hashlib.md5(password.encode(), usedforsecurity=False).hexdigest(),
    }
    content = epub(title="Jane Eyre", isbn=None)
    path = tmp_path / "jane.epub"
    path.write_bytes(content)
    document = partial_md5(path)

    # The plugin asks which of its books Babel lacks, then sends them.
    lacking = client.post("/v1/kosync/library/missing", json={"documents": [document]}, headers=key)
    assert lacking.json() == {"missing": [document]}
    sent = client.put(
        "/v1/kosync/library/upload", params={"name": "jane.epub"}, content=content, headers=key
    )
    assert sent.status_code == 200
    (item,) = client.get("/v1/library", headers=ada).json()
    assert item["ereader"] is True
    assert client.post(
        "/v1/kosync/library/missing", json={"documents": [document]}, headers=key
    ).json() == {"missing": []}

    # Taken off the e-reader by hand, a book is marked again only if it newly shows up there.
    client.put(f"/v1/library/{item['id']}/ereader", json={"ereader": False}, headers=ada)
    body = {"document": document, "progress": "x", "percentage": 0.1, "device": "Boox"}
    client.put("/v1/kosync/syncs/progress", json=body, headers=key)
    assert client.get("/v1/library", headers=ada).json()[0]["ereader"] is True
    client.put(f"/v1/library/{item['id']}/ereader", json={"ereader": False}, headers=ada)
    client.put("/v1/kosync/syncs/progress", json=body, headers=key)
    assert client.get("/v1/library", headers=ada).json()[0]["ereader"] is False


def test_a_book_uploaded_from_the_e_reader_cloud_is_on_the_e_reader(
    client: TestClient, ada: dict[str, str]
) -> None:
    import base64

    password = client.post("/v1/me/koreader/password", headers=ada).json()["password"]
    token = base64.b64encode(f"ada@example.com:{password}".encode()).decode()
    sent = client.put(
        "/v1/webdav/Any.epub",
        content=epub(title="Emma", isbn=None),
        headers={"authorization": f"Basic {token}"},
    )
    assert sent.status_code == 201
    assert client.get("/v1/library", headers=ada).json()[0]["ereader"] is True


def test_a_fanfiction_gets_a_page_of_its_own(
    app: FastAPI, client: TestClient, ada: dict[str, str]
) -> None:
    from dataclasses import replace

    from babel_api.domain.sources import RemoteEntry

    class FakeAo3:
        async def work(self, work_id: str) -> RemoteEntry:
            return RemoteEntry(path=f"/works/{work_id}", size=0, remote_id=f"{work_id}:1/1|x")

    app.state.container = replace(app.state.container, ao3=FakeAo3())
    fic = upload(
        client,
        ada,
        epub(title="Let's Make a Deal", isbn=None, source="https://archiveofourown.org/works/9"),
    ).json()["item"]
    book = upload(client, ada, epub(title="Jane Eyre", isbn=None)).json()["item"]

    made = client.post(f"/v1/library/{fic['id']}/work/fanfic", headers=ada)
    assert made.status_code == 200
    work_id = made.json()["work_id"]
    assert work_id is not None
    again = client.post(f"/v1/library/{fic['id']}/work/fanfic", headers=ada)
    assert again.json()["work_id"] == work_id  # the same fanfiction, the same page
    page = client.get(f"/v1/catalog/works/{work_id}", headers=ada)
    assert page.status_code == 200
    assert page.json()["title"] == "Let's Make a Deal"
    # Only a fanfiction gets one.
    assert client.post(f"/v1/library/{book['id']}/work/fanfic", headers=ada).status_code in (
        400,
        415,
        422,
    )


def test_what_the_plugin_does_counts_as_the_e_reader_being_connected(
    client: TestClient, ada: dict[str, str]
) -> None:
    password = client.post("/v1/me/koreader/password", headers=ada).json()["password"]
    key = {
        "x-auth-user": "ada@example.com",
        "x-auth-key": hashlib.md5(password.encode(), usedforsecurity=False).hexdigest(),
    }
    assert [d["name"] for d in client.get("/v1/devices", headers=ada).json()] == []
    stats = {
        "device": "gocolor7",
        "books": [{"md5": "a" * 32, "title": "Jane Eyre", "total_read_time": 60}],
        "days": [{"md5": "a" * 32, "day": "2026-10-20", "seconds": 60, "pages": 3}],
    }
    assert client.put("/v1/kosync/syncs/stats", json=stats, headers=key).status_code == 200
    (device,) = client.get("/v1/devices", headers=ada).json()
    assert device["name"] == "KOReader · gocolor7"
    assert device["last_seen_at"] is not None
    assert (
        client.get("/v1/kosync/library", params={"device": "Boox"}, headers=key).status_code == 200
    )
    names = {d["name"] for d in client.get("/v1/devices", headers=ada).json()}
    assert names == {"KOReader · gocolor7", "KOReader · Boox"}


def test_a_book_sent_after_its_progress_picks_that_progress_up(
    client: TestClient, ada: dict[str, str], tmp_path: Path
) -> None:
    password = client.post("/v1/me/koreader/password", headers=ada).json()["password"]
    key = {
        "x-auth-user": "ada@example.com",
        "x-auth-key": hashlib.md5(password.encode(), usedforsecurity=False).hexdigest(),
    }
    content = epub(title="Jane Eyre", isbn=None)
    path = tmp_path / "jane.epub"
    path.write_bytes(content)
    document = partial_md5(path)
    body = {"document": document, "progress": "x", "percentage": 0.4, "device": "gocolor7"}
    client.put("/v1/kosync/syncs/progress", json=body, headers=key)
    before = client.get("/v1/me/koreader/status", headers=ada).json()
    assert (before["unknown_books"], before["recent"], before["ereader_books"]) == (1, [], 0)

    sent = client.put(
        "/v1/kosync/library/upload",
        params={"name": "jane.epub", "device": "gocolor7"},
        content=content,
        headers=key,
    )
    assert sent.status_code == 200
    after = client.get("/v1/me/koreader/status", headers=ada).json()
    assert after["unknown_books"] == 0
    assert after["ereader_books"] == 1
    (recent,) = after["recent"]
    assert recent["title"] == "Jane Eyre"
    assert recent["percent"] == pytest.approx(40.0)


def test_a_book_read_on_the_e_reader_is_reading_and_has_its_stats(
    client: TestClient, ada: dict[str, str], tmp_path: Path
) -> None:
    content = epub(title="Jane Eyre", isbn=None)
    item = upload(client, ada, content).json()["item"]
    path = tmp_path / "jane.epub"
    path.write_bytes(content)
    document = partial_md5(path)
    password = client.post("/v1/me/koreader/password", headers=ada).json()["password"]
    key = {
        "x-auth-user": "ada@example.com",
        "x-auth-key": hashlib.md5(password.encode(), usedforsecurity=False).hexdigest(),
    }
    # The library's file gets its KOReader identifier the first time it is looked up.
    client.post("/v1/kosync/library/missing", json={"documents": [document]}, headers=key)
    assert client.get("/v1/library", headers=ada).json()[0]["status"] is None

    stats = {
        "device": "gocolor7",
        "books": [{"md5": document, "title": "Jane Eyre", "total_read_time": 600, "pages": 300}],
        "days": [{"md5": document, "day": "2026-10-20", "seconds": 600, "pages": 12}],
    }
    assert client.put("/v1/kosync/syncs/stats", json=stats, headers=key).status_code == 200
    assert client.get("/v1/library", headers=ada).json()[0]["status"] == "reading"
    totals = client.get(f"/v1/me/koreader/books/{item['id']}", headers=ada).json()
    assert (totals["read_seconds"], totals["read_pages"]) == (600, 12)
    assert client.get(f"/v1/me/koreader/books/{uuid.uuid4()}", headers=ada).status_code == 404
