"""KOReader's progress sync."""

import hashlib
from pathlib import Path

import pytest
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

    info = client.get("/v1/me/koreader", headers=ada).json()
    assert info["has_password"] is False
    assert info["username"] == "ada@example.com"
    password = client.post("/v1/me/koreader/password", headers=ada).json()["password"]
    key = {
        "x-auth-user": "ada@example.com",
        "x-auth-key": hashlib.md5(password.encode(), usedforsecurity=False).hexdigest(),
    }

    assert client.get("/v1/kosync/users/auth", headers=key).json() == {"authorized": "OK"}
    wrong = {**key, "x-auth-key": "0" * 32}
    assert client.get("/v1/kosync/users/auth", headers=wrong).status_code == 401
    assert client.get("/v1/kosync/syncs/progress/" + document, headers=key).status_code == 404

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
    # A book that is not in the library is refused.
    unknown = {**body, "document": "f" * 32}
    assert client.put("/v1/kosync/syncs/progress", json=unknown, headers=key).status_code == 404
