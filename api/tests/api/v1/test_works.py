from dataclasses import replace

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from babel_api.domain.catalog import SourceEdition, SourceWork

JANE = SourceWork("OL1W", "Jane Eyre", ("Charlotte Brontë",), 1847, 8235363, None, 1170)
FRENCH = SourceEdition(
    "OL10M", "OL1W", "Jane Eyre", "fr", "Gallimard", "2008", 640, "Paperback", 123,
    isbn13=("9782070360246",), isbn10=("2070360245",),
    cover_ids=(123, 124, 125),
    description="Orpheline, Jane devient gouvernante à Thornfield Hall, où le maître des lieux "
    "cache un secret que la nuit trahit : rires dans le couloir, flammes, cris.",
)  # fmt: skip
ENGLISH = SourceEdition("OL11M", "OL1W", "Jane Eyre", "en", isbn13=("9780141441146",))


class FakeBooks:
    def __init__(self) -> None:
        self.calls: list[str] = []
        self.down = False
        # What Google Books would answer, and what it was asked.
        self.blurb_text: str | None = None
        self.blurbs: list[tuple[str | None, str, str | None]] = []
        # What a saga search answers, and the searches made.
        self.saga: list[SourceWork] = []
        self.queries: list[str] = []

    def _call(self, name: str) -> None:
        self.calls.append(name)
        if self.down:
            raise RuntimeError("Open Library is down")

    async def search(self, query: str, limit: int, language: str | None = None) -> list[SourceWork]:
        self._call("search")
        if query.startswith("title:"):
            self.queries.append(query)
            return self.saga
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

    async def blurb(
        self, isbn13: str | None, title: str, authors: tuple[str, ...], language: str | None
    ) -> str | None:
        self.blurbs.append((isbn13, title, language))
        return self.blurb_text


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

    # The work's own line is short: the fullest edition blurb replaces it.
    assert work["description"].startswith("Orpheline")
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


def test_details_do_not_override_the_year_and_cover_from_search(
    client: TestClient, books: FakeBooks, auth: dict[str, str]
) -> None:
    async def later_work(open_library_id: str) -> SourceWork | None:
        return replace(JANE, first_publish_year=1996, cover_id=999, description="A governess.")

    books.work = later_work  # type: ignore[method-assign]
    (hit,) = client.get("/v1/catalog/search", params={"q": "jane"}, headers=auth).json()

    work = client.get(f"/v1/catalog/works/{hit['id']}", headers=auth).json()

    assert work["first_publish_year"] == 1847
    assert work["cover_path"] == "/v1/catalog/covers/8235363/M"


def test_editions_show_all_their_covers_and_their_description(
    client: TestClient, books: FakeBooks, auth: dict[str, str]
) -> None:
    (hit,) = client.get("/v1/catalog/search", params={"q": "jane"}, headers=auth).json()

    work = client.get(f"/v1/catalog/works/{hit['id']}", params={"lang": "fr"}, headers=auth).json()

    french = next(e for e in work["editions"] if e["language"] == "fr")
    assert french["cover_paths"] == [
        "/v1/catalog/covers/123/M",
        "/v1/catalog/covers/124/M",
        "/v1/catalog/covers/125/M",
    ]
    english = next(e for e in work["editions"] if e["language"] == "en")
    assert english["cover_paths"] == []
    # The French blurb is the fullest, and the reader reads French.
    assert work["description"].startswith("Orpheline")
    # In English the work's own (shorter) description is not replaced by a French one.
    other = client.get(f"/v1/catalog/works/{hit['id']}", params={"lang": "en"}, headers=auth).json()
    assert other["description"].startswith("Orpheline")  # still the longest on offer


LONG_BLURB = "Jane Eyre, orpheline recueillie puis rejetée, devient gouvernante. " * 12


def test_short_descriptions_are_completed_with_a_fuller_blurb(
    client: TestClient, books: FakeBooks, auth: dict[str, str]
) -> None:
    books.blurb_text = LONG_BLURB
    (hit,) = client.get("/v1/catalog/search", params={"q": "jane"}, headers=auth).json()

    work = client.get(f"/v1/catalog/works/{hit['id']}", params={"lang": "fr"}, headers=auth).json()

    # Asked by ISBN for the edition that has one, once per language.
    assert ("9782070360246", "Jane Eyre", "fr") in books.blurbs
    assert {language for _, _, language in books.blurbs} >= {"fr", "en", None}
    assert work["description"] == LONG_BLURB.strip() or work["description"].startswith("Jane Eyre,")
    assert len(work["description"]) > 400
    french = next(e for e in work["editions"] if e["language"] == "fr")
    assert french["description"] == LONG_BLURB


def test_full_descriptions_are_not_replaced(
    client: TestClient, books: FakeBooks, auth: dict[str, str], app: FastAPI
) -> None:
    books.blurb_text = LONG_BLURB
    (hit,) = client.get("/v1/catalog/search", params={"q": "jane"}, headers=auth).json()
    client.get(f"/v1/catalog/works/{hit['id']}", headers=auth)
    asked = len(books.blurbs)

    # A second visit is answered from the database: Google Books is not asked again.
    client.get(f"/v1/catalog/works/{hit['id']}", headers=auth)

    assert len(books.blurbs) == asked


def test_a_missing_blurb_source_changes_nothing(
    client: TestClient, books: FakeBooks, auth: dict[str, str]
) -> None:
    (hit,) = client.get("/v1/catalog/search", params={"q": "jane"}, headers=auth).json()

    work = client.get(f"/v1/catalog/works/{hit['id']}", headers=auth).json()

    assert work["description"].startswith("Orpheline")


def volume(key: str, title: str, cover: int | None = None) -> SourceWork:
    return SourceWork(key, title, ("Hideo Yamamoto",), 2007, cover, None, 1)


def test_a_saga_lists_every_volume_in_order(
    client: TestClient, books: FakeBooks, auth: dict[str, str]
) -> None:
    books.saga = [
        volume("OL3W", "Homunculus 3", 33),
        volume("OL10W", "Homunculus 10", 100),
        volume("OL1W", "Homunculus 01"),  # no cover
        volume("OL1bW", "Homunculus 1", 11),  # a reprint of volume 1, with a cover
        volume("OL2W", "Homunculus, Tome 2", 22),
        volume("OL9W", "Homunculus (Omnibus) Vol. 3-4"),  # not one volume
        volume("OL5W", "Homunkurusu 5", 55),  # another spelling: another series
        volume("OL7W", "Homunculus Returns"),  # no volume number
    ]

    found = client.get(
        "/v1/catalog/saga",
        params={"series": "Homunculus", "author": "Hideo Yamamoto"},
        headers=auth,
    ).json()

    assert [v["number"] for v in found] == [1, 2, 3, 10]
    assert [v["work"]["title"] for v in found] == [
        "Homunculus 1",
        "Homunculus, Tome 2",
        "Homunculus 3",
        "Homunculus 10",
    ]
    assert found[0]["work"]["cover_path"] == "/v1/catalog/covers/11/M"
    assert books.queries == ['title:"Homunculus" author:"Hideo Yamamoto"']
    # Each volume is a work of its own that can be opened.
    opened = client.get(f"/v1/catalog/works/{found[2]['work']['id']}", headers=auth)
    assert opened.status_code == 200


def test_a_saga_search_needs_a_name_and_may_find_nothing(
    client: TestClient, books: FakeBooks, auth: dict[str, str]
) -> None:
    assert client.get("/v1/catalog/saga", params={"series": "x"}, headers=auth).status_code == 422
    nothing = client.get("/v1/catalog/saga", params={"series": "Unknown saga"}, headers=auth)
    assert nothing.json() == []
    books.down = True
    down = client.get("/v1/catalog/saga", params={"series": "Homunculus"}, headers=auth)
    assert down.status_code == 503
