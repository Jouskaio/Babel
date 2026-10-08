from collections.abc import Callable
from dataclasses import replace

import httpx
import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from babel_api.adapters.chaptarr import ChaptarrError
from babel_api.adapters.hardcover import HardcoverBook, HardcoverClient
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
        volume("OL7W", "Homunculus 07", 77),
        volume("OL1W", "Homunculus 01"),  # no cover, a leading zero
        volume("OL1bW", "Homunculus 1", 11),  # a reprint of volume 1, with a cover
        volume("OL2W", "Homunculus, Tome 2", 22),
        volume("OL9W", "Homunculus (Omnibus) Vol. 3-4"),  # not one volume
        volume("OL5W", "Homunkurusu 5", 55),  # another spelling: another series
        volume("OL8W", "Homunculus Returns"),  # no volume number
    ]

    found = client.get(
        "/v1/catalog/saga",
        params={"series": "Homunculus", "author": "Hideo Yamamoto"},
        headers=auth,
    ).json()

    assert [v["number"] for v in found] == [1, 2, 3, 7, 10]
    assert [v["work"]["title"] for v in found] == [
        "Homunculus 1",
        "Homunculus, Tome 2",
        "Homunculus 3",
        "Homunculus 07",
        "Homunculus 10",
    ]
    assert found[0]["work"]["cover_path"] == "/v1/catalog/covers/11/M"
    assert books.queries == ['title:"Homunculus" author:"Hideo Yamamoto"']
    # A volume's page says which saga it belongs to, so the app can offer the whole of it.
    third = client.get(f"/v1/catalog/works/{found[2]['work']['id']}", headers=auth).json()
    assert (third["series"], third["series_index"]) == ("Homunculus", 3)
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


# ---------------------------------------------------------------- requests (Chaptarr)
class FakeChaptarr:
    """Chaptarr's side: what it knows, what was added, and whether files arrived."""

    def __init__(self) -> None:
        self.known = [
            {"title": "Jane Eyre: study guide", "author": {"authorName": "Some Teacher"}},
            {"title": "Jane Eyre", "author": {"authorName": "Charlotte Brontë"}},
        ]
        self.added: list[dict[str, object]] = []
        self.arrived = False
        self.scans = 0
        self.downloading: dict[int, float] = {}

    def __call__(self) -> "FakeChaptarr":
        return self

    async def lookup(self, title: str, authors: tuple[str, ...]) -> dict[str, object] | None:
        from babel_api.adapters.chaptarr import best_match

        return best_match(self.known, title, authors)

    async def original_edition(
        self, title: str, authors: tuple[str, ...]
    ) -> dict[str, object] | None:
        return None

    async def add(self, book: dict[str, object]) -> int:
        self.added.append(book)
        return 7

    async def has_files(self, book_id: int) -> bool:
        return self.arrived

    async def queue_progress(self) -> dict[int, float]:
        return self.downloading

    async def aclose(self) -> None:
        return None


@pytest.fixture
def chaptarr(app: FastAPI, books: FakeBooks) -> FakeChaptarr:
    fake = FakeChaptarr()

    class FakeKavita:
        async def login_with_key(self, key: str) -> "FakeKavita":
            self.token = "admin"
            return self

        async def scan_all(self, admin_token: str) -> None:
            fake.scans += 1

        async def aclose(self) -> None:
            return None

    def kavita_client(url: str) -> FakeKavita:
        return FakeKavita()

    app.state.container = replace(
        app.state.container,
        chaptarr=fake,
        kavita_client=kavita_client,  # type: ignore[arg-type]
    )
    return fake


def test_only_premium_readers_can_request_a_book(
    client: TestClient, chaptarr: FakeChaptarr, auth: dict[str, str]
) -> None:
    (hit,) = client.get("/v1/catalog/search", params={"q": "jane"}, headers=auth).json()
    refused = client.post("/v1/requests", json={"work_id": hit["id"]}, headers=auth)
    assert refused.status_code == 403
    assert chaptarr.added == []
    # Without premium or a Chaptarr of their own the reader cannot ask; the server does offer one.
    assert client.get("/v1/requests", headers=auth).json()["enabled"] is False
    assert client.get("/v1/me/chaptarr", headers=auth).json()["server_offers"] is True


def test_a_premium_reader_requests_a_book_once(
    client: TestClient, chaptarr: FakeChaptarr, books: FakeBooks
) -> None:
    from tests.api.v1.test_library import account

    admin = account(client, "admin@example.com")  # administrators are premium
    (hit,) = client.get("/v1/catalog/search", params={"q": "jane"}, headers=admin).json()

    first = client.post("/v1/requests", json={"work_id": hit["id"]}, headers=admin)
    again = client.post("/v1/requests", json={"work_id": hit["id"]}, headers=admin)

    assert first.status_code == 201
    assert first.json()["status"] == "requested" == again.json()["status"]
    assert len(chaptarr.added) == 1  # the study guide did not match, the novel did
    assert chaptarr.added[0]["title"] == "Jane Eyre"

    # The same book in another language is another request.
    french = client.post(
        "/v1/requests", json={"work_id": hit["id"], "language": "fr"}, headers=admin
    )
    assert french.status_code == 201
    assert french.json()["language"] == "fr"
    languages = {r["language"] for r in client.get("/v1/requests", headers=admin).json()["items"]}
    assert languages == {"", "fr"}


def test_a_book_chaptarr_does_not_know_is_reported(
    client: TestClient, chaptarr: FakeChaptarr, books: FakeBooks
) -> None:
    from tests.api.v1.test_library import account

    chaptarr.known = []
    admin = account(client, "admin@example.com")
    (hit,) = client.get("/v1/catalog/search", params={"q": "jane"}, headers=admin).json()
    response = client.post("/v1/requests", json={"work_id": hit["id"]}, headers=admin)
    assert response.json()["status"] == "requested"  # answered at once; the search follows
    listed = client.get("/v1/requests", headers=admin).json()["items"]
    assert [i["status"] for i in listed] == ["not_found"]
    assert chaptarr.added == []


def test_a_request_becomes_available_when_the_files_arrive(
    client: TestClient, chaptarr: FakeChaptarr, books: FakeBooks
) -> None:
    from tests.api.v1.test_library import account

    admin = account(client, "admin@example.com")
    (hit,) = client.get("/v1/catalog/search", params={"q": "jane"}, headers=admin).json()
    client.post("/v1/requests", json={"work_id": hit["id"]}, headers=admin)
    assert client.get("/v1/requests", headers=admin).json()["items"][0]["status"] == "requested"

    chaptarr.downloading = {7: 42.5}  # Chaptarr's book 7 is being downloaded
    running = client.get("/v1/requests", headers=admin).json()["items"][0]
    assert running["status"] == "requested"
    assert running["progress"] == 42.5

    chaptarr.arrived = True
    assert client.get("/v1/requests", headers=admin).json()["items"][0]["status"] == "available"
    assert chaptarr.scans == 1


def test_the_title_alone_is_searched_before_the_title_with_its_author() -> None:
    import asyncio

    from babel_api.adapters.chaptarr import ChaptarrClient

    asked: list[str] = []
    novel: dict[str, object] = {"title": "Jane Eyre", "author": {"authorName": "Charlotte Brontë"}}
    about: dict[str, object] = {
        "title": "The Secret History of Jane Eyre",
        "author": {"authorName": "J. P."},
    }

    class Fake(ChaptarrClient):
        async def _call(  # type: ignore[override]
            self,
            method: str,
            path: str,
            json: object | None = None,
            params: dict[str, str] | None = None,
        ) -> list[dict[str, object]]:
            term = (params or {})["term"]
            asked.append(term)
            return [novel] if term == "Jane Eyre" else [about]

    client = Fake("http://x", "k")
    found = asyncio.run(client.lookup("Jane Eyre", ("Charlotte Brontë",)))
    assert found == novel
    assert asked == ["Jane Eyre"]  # found at once, no second search


def test_a_requested_book_is_watched_and_searched_after_it_is_added() -> None:
    import asyncio
    from typing import Any

    from babel_api.adapters.chaptarr import ChaptarrClient

    calls: list[tuple[str, str]] = []

    class Fake(ChaptarrClient):
        async def _call(  # type: ignore[override]
            self,
            method: str,
            path: str,
            json: object | None = None,
            params: dict[str, str] | None = None,
        ) -> Any:
            calls.append((method, path))
            if path == "qualityprofile":
                return [{"id": 1, "profileType": "ebook"}]
            if path == "metadataprofile":
                return [{"id": 2, "profileType": 2}]
            if path == "rootfolder":
                return [{"path": "/data/books/ebooks"}]
            if path == "book":
                return {"id": 671}
            return []

    book_id = asyncio.run(Fake("http://x", "k").add({"title": "Frankenstein", "author": {}}))
    assert book_id == 671
    assert calls[-2:] == [("PUT", "book/monitor"), ("POST", "command")]


def test_a_volume_matches_however_chaptarr_spells_it() -> None:
    from babel_api.adapters.chaptarr import best_match

    def book(title: str, author: str = "Hideo Yamamoto") -> dict[str, object]:
        return {"title": title, "author": {"authorName": author}}

    volume = book("Homunculus, Band 3")
    found = [
        book("Homunculus, Band 2"),
        book("Homunculus, Vol. 3-4"),  # omnibus
        book("Homunculus 3", "Someone Else"),  # another author
        book("Homunculus Returns"),
        volume,
    ]
    assert best_match(found, "Homunculus 3", ("Hideo Yamamoto",)) is volume
    assert best_match(found, "Homunculus 5", ("Hideo Yamamoto",)) is None
    # A plain title still matches as before.
    novel = book("Jane Eyre", "Charlotte Brontë")
    assert (
        best_match(
            [book("Jane Eyre: study guide", "A. Teacher"), novel],
            "Jane Eyre",
            ("Charlotte Brontë",),
        )
        is novel
    )


def test_hardcover_names_the_volumes_of_a_series() -> None:
    import asyncio

    import httpx

    from babel_api.adapters.hardcover import HardcoverClient

    asked: list[str] = []

    def handler(request: httpx.Request) -> httpx.Response:
        import json

        body = json.loads(request.content)
        asked.append(body["query"][:20])
        assert request.headers["authorization"] == "Bearer secret"
        if "search" in body["query"]:
            doc = {"name": "Homunculus", "author_name": "Hideo Yamamoto"}
            other = {"name": "Homunculus Returns", "author_name": "X"}
            hits = {"hits": [{"document": other}, {"document": doc}]}
            return httpx.Response(200, json={"data": {"search": {"ids": [1, 2], "results": hits}}})
        links = [
            {"position": 1, "book": {"id": 11, "title": "Homunculus 1"}},
            {"position": 2.5, "book": {"id": 12, "title": "Interlude"}},
            {"position": None, "book": {"title": "Artbook"}},
        ]
        return httpx.Response(200, json={"data": {"series": [{"book_series": links}]}})

    client = HardcoverClient("secret", httpx.AsyncClient(transport=httpx.MockTransport(handler)))
    found = asyncio.run(client.series_volumes("Homunculus", "Hideo Yamamoto"))
    assert found == [(1.0, "Homunculus 1", 11), (2.5, "Interlude", 12)]  # no position, no volume
    assert asyncio.run(client.series_volumes("Homunculus", "Hideo Yamamoto")) == found
    assert len(asked) == 2  # the second answer came from the cache


def test_a_hardcover_failure_reads_as_nothing_known() -> None:
    import asyncio

    import httpx

    from babel_api.adapters.hardcover import HardcoverClient

    def down(request: httpx.Request) -> httpx.Response:
        return httpx.Response(503)

    client = HardcoverClient("k", httpx.AsyncClient(transport=httpx.MockTransport(down)))
    assert asyncio.run(client.series_volumes("Homunculus", None)) == []


def _hardcover(handler: Callable[[httpx.Request], httpx.Response]) -> HardcoverClient:

    return HardcoverClient("k", httpx.AsyncClient(transport=httpx.MockTransport(handler)))


def test_hardcover_gives_the_description_of_the_right_book() -> None:
    import asyncio

    import httpx

    long_text = "<p>An orphan becomes a governess at Thornfield Hall.</p> " + "x" * 80
    wrong = {
        "title": "Jane Eyre Study Guide",
        "author_names": ["A. Teacher"],
        "description": long_text,
    }
    right = {"title": "Jane Eyre", "author_names": ["Charlotte Brontë"], "description": long_text}
    calls: list[int] = []

    def handler(request: httpx.Request) -> httpx.Response:
        calls.append(1)
        hits = {"hits": [{"document": wrong}, {"document": right}]}
        return httpx.Response(200, json={"data": {"search": {"results": hits}}})

    client = _hardcover(handler)
    text = asyncio.run(client.description("Jane Eyre", ("Charlotte Brontë",)))
    assert text is not None
    assert text.startswith("An orphan")
    assert "<p>" not in text
    asyncio.run(client.description("Jane Eyre", ("Charlotte Brontë",)))
    assert len(calls) == 1  # kept for the day


def test_hardcover_rests_after_a_429_and_stops_at_its_daily_budget() -> None:
    import asyncio

    import httpx

    from babel_api.adapters import hardcover

    calls: list[int] = []

    def limited(request: httpx.Request) -> httpx.Response:
        calls.append(1)
        return httpx.Response(429, headers={"retry-after": "120"})

    client = _hardcover(limited)
    assert asyncio.run(client.description("Jane Eyre", ("Charlotte Brontë",))) is None
    assert asyncio.run(client.description("Emma", ("Jane Austen",))) is None
    assert len(calls) == 1  # the second one did not even ask

    def empty(request: httpx.Request) -> httpx.Response:
        return httpx.Response(200, json={"data": {"search": {"results": {}}}})

    ok = _hardcover(empty)
    ok._used = hardcover.DAILY_BUDGET  # type: ignore[attr-defined]
    assert asyncio.run(ok.description("Emma", ("Jane Austen",))) is None
    assert ok._used == hardcover.DAILY_BUDGET  # type: ignore[attr-defined]


def test_a_single_series_of_that_name_is_taken_whatever_its_author_spelling() -> None:
    from typing import Any

    from babel_api.adapters.hardcover import pick_series

    def search(*docs: dict[str, Any]) -> dict[str, Any]:
        hits = {"hits": [{"document": d} for d in docs]}
        return {"ids": list(range(1, len(docs) + 1)), "results": hits}

    only = {"name": "Homunculus", "author_name": "山本英夫"}
    assert pick_series(search(only), "Homunculus", "Hideo Yamamoto") == 1
    other = {"name": "Homunculus", "author_name": "Christian Gude"}
    mine = {"name": "Homunculus", "author_name": "Hideo Yamamoto"}
    assert pick_series(search(other, mine), "Homunculus", "Hideo Yamamoto") == 2
    assert pick_series(search(other, only), "Homunculus", "Hideo Yamamoto") is None  # ambiguous


def test_a_series_named_in_japanese_with_the_latin_name_in_brackets_is_found() -> None:
    from typing import Any

    from babel_api.adapters.hardcover import pick_series

    def search(*docs: dict[str, Any]) -> dict[str, Any]:
        return {
            "ids": list(range(1, len(docs) + 1)),
            "results": {"hits": [{"document": d} for d in docs]},
        }

    main = {"name": "ホムンクルス [Homunculus]", "author_name": "Hideo Yamamoto"}
    reissue = {"name": "ホムンクルス 文庫版 [Homunculus bunkoban]", "author_name": "Hideo Yamamoto"}
    assert pick_series(search(reissue, main), "Homunculus", "Hideo Yamamoto") == 2
    # Only the reissue exists: better than nothing, and the author agrees.
    assert pick_series(search(reissue), "Homunculus", "Hideo Yamamoto") == 1


def test_series_are_recognised_whatever_the_extras_around_their_name() -> None:
    from typing import Any

    from babel_api.adapters.hardcover import pick_series

    def search(*docs: dict[str, Any]) -> dict[str, Any]:
        return {
            "ids": [100 + n for n in range(len(docs))],
            "results": {"hits": [{"document": d} for d in docs]},
        }

    def doc(name: str, author: str, readers: int = 0) -> dict[str, Any]:
        return {"name": name, "author_name": author, "readers_count": readers}

    collins = "Suzanne Collins"
    hunger = search(doc("Hunger Games Trilogy", collins, 90), doc("The Hunger Games", "Someone", 5))
    assert pick_series(hunger, "The Hunger Games", collins) == 100  # "Trilogy", and the author
    potter = search(doc("Harry Potter Series", "J.K. Rowling", 900))
    assert pick_series(potter, "Harry Potter", "J. K. Rowling") == 100
    discworld = search(
        doc("Discworld", "Terry Pratchett", 500), doc("Discworld (Death)", "Terry Pratchett", 40)
    )
    assert pick_series(discworld, "Discworld", None) == 100  # same name: most readers
    spin = search(doc("Homunculus Returns", "Christian Gude", 1))
    assert pick_series(spin, "Homunculus", "Hideo Yamamoto") is None  # another author's series
    assert (
        pick_series(search(doc("Dune Chronicles", "Frank Herbert", 800)), "Dune", "Frank Herbert")
        == 100
    )


def test_a_volume_only_hardcover_knows_becomes_a_work_you_can_open(
    client: TestClient, books: FakeBooks, auth: dict[str, str]
) -> None:
    body = {
        "hardcover_id": 4242,
        "title": "Le sceptre maudit",
        "author": "Sophie Audouin-Mamikonian",
    }
    first = client.post("/v1/catalog/works/hardcover", json=body, headers=auth)
    again = client.post("/v1/catalog/works/hardcover", json=body, headers=auth)
    assert first.status_code == 200
    assert first.json()["title"] == "Le sceptre maudit"
    assert first.json()["id"] == again.json()["id"]  # the same volume is the same work

    calls_before = len(books.calls)
    opened = client.get(f"/v1/catalog/works/{first.json()['id']}", headers=auth)
    assert opened.status_code == 200
    assert opened.json()["authors"] == ["Sophie Audouin-Mamikonian"]
    assert len(books.calls) == calls_before  # Open Library is not asked about an "hc:" work


class FakeHardcoverSearch:
    """Hardcover's side of a catalog search."""

    def __init__(self, found: list[HardcoverBook]) -> None:
        self.found = found
        self.asked: list[str] = []

    async def search_books(self, query: str, limit: int = 10) -> list[HardcoverBook]:
        self.asked.append(query)
        return self.found[:limit]


def test_the_search_adds_what_hardcover_knows_and_the_catalog_lacks(
    app: FastAPI, client: TestClient, books: FakeBooks, auth: dict[str, str]
) -> None:
    fake = FakeHardcoverSearch(
        [
            HardcoverBook(1, "Jane Eyre: An Autobiography", ("Charlotte Brontë",), 1847, None),
            HardcoverBook(2, "Jane Eyre, Tome 2", ("Charlotte Brontë",), 2001, None),
            HardcoverBook(3, "Jane Eyre", ("Someone Else",), 2010, "x" * 120),
        ]
    )
    app.state.container = replace(app.state.container, hardcover=fake)
    hits = client.get("/v1/catalog/search", params={"q": "jane"}, headers=auth).json()
    titles = [h["title"] for h in hits]
    # The catalog's own hit first; its twin from Hardcover (same title, same author) is not
    # added again; the others are.
    assert titles == ["Jane Eyre", "Jane Eyre, Tome 2", "Jane Eyre"]
    assert fake.asked == ["jane"]
    # They open like any work, without asking Open Library about them.
    extra = next(h for h in hits if h["title"] == "Jane Eyre, Tome 2")
    before = len(books.calls)
    opened = client.get(f"/v1/catalog/works/{extra['id']}", headers=auth)
    assert opened.status_code == 200
    assert len(books.calls) == before

    # A one-letter query is not worth a request to Hardcover; two letters are (Open Library
    # refuses them, so only Hardcover is asked: "oz").
    client.get("/v1/catalog/search", params={"q": "j"}, headers=auth)
    assert fake.asked == ["jane"]
    short = client.get("/v1/catalog/search", params={"q": "oz"}, headers=auth)
    assert short.status_code == 200
    assert fake.asked == ["jane", "oz"]


def test_the_search_still_answers_when_open_library_is_down(
    app: FastAPI, client: TestClient, books: FakeBooks, auth: dict[str, str]
) -> None:
    fake = FakeHardcoverSearch(
        [HardcoverBook(5, "Le sceptre maudit", ("Sophie Audouin",), 2003, None)]
    )
    app.state.container = replace(app.state.container, hardcover=fake)
    books.down = True
    hits = client.get("/v1/catalog/search", params={"q": "sceptre"}, headers=auth)
    assert hits.status_code == 200
    assert [h["title"] for h in hits.json()] == ["Le sceptre maudit"]

    # Both down: the search fails as before.
    app.state.container = replace(app.state.container, hardcover=FakeHardcoverSearch([]))
    assert (
        client.get("/v1/catalog/search", params={"q": "sceptre"}, headers=auth).status_code == 503
    )


class ReaderChaptarr(FakeChaptarr):
    """A reader's own Chaptarr, reached by address and key."""

    def __init__(self) -> None:
        super().__init__()
        self.reached: list[tuple[str, str]] = []
        self.refuse: str | None = None

    def __call__(self, *args: str) -> "ReaderChaptarr":  # type: ignore[override]
        self.reached.append((args[0], args[1]))
        return self

    async def check(self) -> None:
        if self.refuse:
            raise ChaptarrError(self.refuse)


def test_a_reader_links_their_own_chaptarr_and_asks_it_for_books(
    app: FastAPI, client: TestClient, books: FakeBooks, auth: dict[str, str]
) -> None:
    from cryptography.fernet import Fernet

    from babel_api.adapters.security.secrets import SecretBox

    mine = ReaderChaptarr()
    app.state.container = replace(
        app.state.container,
        chaptarr=None,  # the server has none, and this reader is not premium
        chaptarr_for_reader=mine,
        secrets=SecretBox(Fernet.generate_key().decode()),
    )
    (hit,) = client.get("/v1/catalog/search", params={"q": "jane"}, headers=auth).json()
    nothing = client.get("/v1/requests", headers=auth).json()
    assert nothing["enabled"] is False
    refused = client.post("/v1/requests", json={"work_id": hit["id"]}, headers=auth)
    assert refused.status_code == 503  # no Chaptarr at all

    body = {"base_url": "https://chaptarr.example.com/", "api_key": "my-secret-key"}
    linked = client.put("/v1/me/chaptarr", json=body, headers=auth)
    assert linked.status_code == 200
    assert linked.json() == {
        "linked": True,
        "base_url": "https://chaptarr.example.com",
        "server_offers": False,
    }
    assert "my-secret-key" not in linked.text  # the key is never given back
    assert mine.reached[-1] == ("https://chaptarr.example.com", "my-secret-key")

    assert client.get("/v1/requests", headers=auth).json()["enabled"] is True
    asked = client.post("/v1/requests", json={"work_id": hit["id"]}, headers=auth)
    assert asked.status_code == 201
    assert len(mine.added) == 1  # it went to the reader's Chaptarr, with the stored key
    assert mine.reached[-1] == ("https://chaptarr.example.com", "my-secret-key")

    assert client.delete("/v1/me/chaptarr", headers=auth).status_code == 204
    assert client.get("/v1/me/chaptarr", headers=auth).json()["linked"] is False
    assert client.get("/v1/requests", headers=auth).json()["enabled"] is False


def test_a_chaptarr_that_does_not_answer_properly_is_not_linked(
    app: FastAPI, client: TestClient, auth: dict[str, str]
) -> None:
    from cryptography.fernet import Fernet

    from babel_api.adapters.security.secrets import SecretBox

    mine = ReaderChaptarr()
    app.state.container = replace(
        app.state.container,
        chaptarr_for_reader=mine,
        secrets=SecretBox(Fernet.generate_key().decode()),
    )
    body = {"base_url": "https://chaptarr.example.com", "api_key": "my-secret-key"}
    mine.refuse = "unauthorized"
    wrong = client.put("/v1/me/chaptarr", json=body, headers=auth)
    assert wrong.status_code == 400
    assert wrong.json()["detail"] == "chaptarr:unauthorized"
    odd = {"base_url": "ftp://chaptarr.example.com", "api_key": "my-secret-key"}
    assert (
        client.put("/v1/me/chaptarr", json=odd, headers=auth).json()["detail"] == "chaptarr:address"
    )
    assert client.get("/v1/me/chaptarr", headers=auth).json()["linked"] is False


def test_the_search_does_not_wait_for_a_slow_open_library(
    app: FastAPI, client: TestClient, books: FakeBooks, auth: dict[str, str]
) -> None:
    import asyncio
    import time

    from babel_api.services import works as service

    fake = FakeHardcoverSearch(
        [HardcoverBook(9, "Le dragon renégat", ("Sophie Audouin",), 2004, None)]
    )
    app.state.container = replace(app.state.container, hardcover=fake)

    async def slow_search(query: str, limit: int, language: str | None = None) -> list[SourceWork]:
        await asyncio.sleep(5)
        return [JANE]

    books.search = slow_search  # type: ignore[method-assign]
    patience = service.OPEN_LIBRARY_PATIENCE
    service.OPEN_LIBRARY_PATIENCE = 0.2
    try:
        started = time.monotonic()
        hits = client.get("/v1/catalog/search", params={"q": "dragon"}, headers=auth).json()
        took = time.monotonic() - started
    finally:
        service.OPEN_LIBRARY_PATIENCE = patience
    assert [h["title"] for h in hits] == ["Le dragon renégat"]
    assert took < 3  # Open Library's 5 seconds were not waited for


def test_an_address_without_chaptarr_api_is_not_a_chaptarr() -> None:
    import asyncio

    import httpx

    from babel_api.adapters.chaptarr import ChaptarrClient

    def handler(request: httpx.Request) -> httpx.Response:
        return httpx.Response(404)

    client = ChaptarrClient(
        "https://example.com", "k", httpx.AsyncClient(transport=httpx.MockTransport(handler))
    )
    with pytest.raises(ChaptarrError) as refused:
        asyncio.run(client.check())
    assert refused.value.reason == "not_chaptarr"


def test_a_volume_is_also_found_under_its_original_title() -> None:
    from babel_api.adapters.chaptarr import original_match

    nekokurage = {"authorName": "Nekokurage"}
    books = [
        {"title": "Les Carnets de l'Apothicaire, Tome 1", "author": nekokurage},
        {"title": "薬屋のひとりごと 2 [Kusuriya no Hitorigoto 2]", "author": nekokurage},
        {"title": "薬屋のひとりごと 1-2巻セット", "author": nekokurage},
        {"title": "薬屋のひとりごと 1 [Kusuriya no Hitorigoto 1]", "author": {"authorName": "X"}},
        {"title": "薬屋のひとりごと 1 [Kusuriya no Hitorigoto 1]", "author": nekokurage},
    ]
    found = original_match(books, 1, ("Natsu Hyuuga", "Nekokurage"))
    assert found is books[4]
    assert original_match(books, 7, ("Nekokurage",)) is None
