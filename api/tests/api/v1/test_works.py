from dataclasses import replace

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from babel_api.domain.catalog import SourceEdition, SourceWork

JANE = SourceWork("OL1W", "Jane Eyre", ("Charlotte Brontë",), 1847, 8235363, None, 1170)
FRENCH = SourceEdition(
    "OL10M", "OL1W", "Jane Eyre", "fr", "Gallimard", "2008", 640, "Paperback", 123,
    isbn13=("9782070360246",), isbn10=("2070360245",),
)  # fmt: skip
ENGLISH = SourceEdition("OL11M", "OL1W", "Jane Eyre", "en", isbn13=("9780141441146",))


class FakeBooks:
    def __init__(self) -> None:
        self.calls: list[str] = []
        self.down = False

    def _call(self, name: str) -> None:
        self.calls.append(name)
        if self.down:
            raise RuntimeError("Open Library is down")

    async def search(self, query: str, limit: int, language: str | None = None) -> list[SourceWork]:
        self._call("search")
        if language == "fr":
            return [replace(JANE, localized_title="Jane Eyre (FR)", localized_cover_id=123)]
        return [JANE]

    async def work(self, open_library_id: str) -> SourceWork | None:
        self._call("work")
        return replace(JANE, description="A governess.") if open_library_id == "OL1W" else None

    async def editions(self, work_open_library_id: str, limit: int) -> list[SourceEdition]:
        self._call("editions")
        return [FRENCH, ENGLISH]

    async def edition_by_isbn(self, isbn13: str) -> SourceEdition | None:
        self._call("isbn")
        return FRENCH if isbn13 == "9782070360246" else None


@pytest.fixture
def books(app: FastAPI) -> FakeBooks:
    fake = FakeBooks()
    app.state.container = replace(app.state.container, books=fake)
    return fake


@pytest.fixture
def auth(client: TestClient) -> dict[str, str]:
    session = client.post(
        "/v1/auth/register",
        json={"email": "ada@example.com", "password": "correct horse battery", "display_name": "A"},
    ).json()
    return {"Authorization": f"Bearer {session['access_token']}"}


def test_catalog_requires_an_account(client: TestClient, books: FakeBooks) -> None:
    assert client.get("/v1/catalog/search", params={"q": "jane"}).status_code == 401


def test_search_then_open_a_work_with_its_editions(
    client: TestClient, books: FakeBooks, auth: dict[str, str]
) -> None:
    (hit,) = client.get("/v1/catalog/search", params={"q": "jane"}, headers=auth).json()
    assert hit["title"] == "Jane Eyre"
    assert hit["cover_path"] == "/v1/catalog/covers/8235363/M"

    work = client.get(f"/v1/catalog/works/{hit['id']}", headers=auth).json()

    assert work["description"] == "A governess."
    assert {e["language"] for e in work["editions"]} == {"fr", "en"}
    french = next(e for e in work["editions"] if e["language"] == "fr")
    assert french["isbn13"] == ["9782070360246"]


def test_editions_are_cached(client: TestClient, books: FakeBooks, auth: dict[str, str]) -> None:
    (hit,) = client.get("/v1/catalog/search", params={"q": "jane"}, headers=auth).json()

    client.get(f"/v1/catalog/works/{hit['id']}", headers=auth)
    client.get(f"/v1/catalog/works/{hit['id']}", headers=auth)

    assert books.calls.count("editions") == 1


def test_a_cached_work_is_served_when_the_source_is_down(
    client: TestClient, books: FakeBooks, auth: dict[str, str]
) -> None:
    (hit,) = client.get("/v1/catalog/search", params={"q": "jane"}, headers=auth).json()
    books.down = True

    response = client.get(f"/v1/catalog/works/{hit['id']}", headers=auth)

    assert response.status_code == 200
    assert response.json()["editions"] == []


def test_any_isbn_form_finds_the_edition_and_its_work(
    client: TestClient, books: FakeBooks, auth: dict[str, str]
) -> None:
    first = client.get("/v1/catalog/isbn/2070360245", headers=auth)
    second = client.get("/v1/catalog/isbn/978-2-07-036024-6", headers=auth)

    assert first.status_code == second.status_code == 200
    assert first.json()["edition_id"] == second.json()["edition_id"]
    assert first.json()["work"]["title"] == "Jane Eyre"
    # The second lookup is answered from the database.
    assert books.calls.count("isbn") == 1


def test_isbn_errors(client: TestClient, books: FakeBooks, auth: dict[str, str]) -> None:
    assert client.get("/v1/catalog/isbn/9782070360247", headers=auth).status_code == 400
    assert client.get("/v1/catalog/isbn/9780306406157", headers=auth).status_code == 404
    books.down = True
    assert client.get("/v1/catalog/isbn/9780141441146", headers=auth).status_code == 503


def test_unknown_works_are_404(client: TestClient, books: FakeBooks, auth: dict[str, str]) -> None:
    response = client.get("/v1/catalog/works/00000000-0000-0000-0000-000000000000", headers=auth)
    assert response.status_code == 404


def test_titles_follow_the_requested_language(
    client: TestClient, books: FakeBooks, auth: dict[str, str]
) -> None:
    (hit,) = client.get(
        "/v1/catalog/search", params={"q": "jane", "lang": "fr"}, headers=auth
    ).json()
    assert hit["title"] == "Jane Eyre (FR)"
    assert hit["original_title"] == "Jane Eyre"
    assert hit["cover_path"] == "/v1/catalog/covers/123/M"

    work = client.get(f"/v1/catalog/works/{hit['id']}", params={"lang": "fr"}, headers=auth).json()
    assert work["cover_path"] == "/v1/catalog/covers/123/M"  # cover of the French edition
