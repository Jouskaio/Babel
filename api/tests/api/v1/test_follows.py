import asyncio
import uuid
from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager
from dataclasses import replace
from datetime import timedelta

import httpx
import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from babel_api.adapters.sources.ao3 import Ao3Connector
from babel_api.api.dependencies import Container, make_follow_service
from babel_api.services.follow_loop import check_due_follows
from babel_api.services.follows import FollowService
from tests.api.v1.test_library import account
from tests.api.v1.test_sync import device, pull, push
from tests.books import epub

LINK = "https://archiveofourown.org/works/77"


class Ao3:
    """One work whose chapters the test makes progress."""

    def __init__(self) -> None:
        self.chapters = "3/?"
        self.updated = "2026-10-01"
        self.downloads = 0

    def page(self) -> str:
        return (
            '<html><body><dl class="stats">'
            f'<dd class="status">{self.updated}</dd><dd class="chapters">{self.chapters}</dd>'
            '</dl><h2 class="title heading">Arcane</h2>'
            '<h3 class="byline heading"><a rel="author" href="/users/z">ittybittyzz</a></h3>'
            '<ul><li class="download"><a href="/downloads/77/Arcane.epub">EPUB</a></li></ul>'
            "</body></html>"
        )

    def __call__(self, request: httpx.Request) -> httpx.Response:
        if request.url.path == "/works/77":
            return httpx.Response(200, text=self.page())
        if request.url.path.startswith("/downloads/77"):
            self.downloads += 1
            # Each version is a different file (more chapters).
            content = epub(
                title="Arcane",
                author="ittybittyzz",
                isbn=None,
                opf_extra=f"<!-- {self.chapters} -->",
            )
            return httpx.Response(200, content=content)
        return httpx.Response(404)


@pytest.fixture
def ao3(app: FastAPI) -> Ao3:
    fake = Ao3()
    app.state.container = replace(
        app.state.container,
        ao3=Ao3Connector(httpx.MockTransport(fake), pause=0, download_pause=0),
    )
    return fake


@pytest.fixture
def ada(client: TestClient) -> dict[str, str]:
    return account(client, "ada@example.com")


def follows(client: TestClient, auth: dict[str, str]) -> list[dict[str, object]]:
    return client.get("/v1/library/follows", headers=auth).json()


def import_link(client: TestClient, auth: dict[str, str]) -> dict[str, object]:
    response = client.post("/v1/library/links", json={"url": LINK}, headers=auth)
    assert response.status_code == 201
    return response.json()


def test_unfinished_works_are_followed(client: TestClient, ao3: Ao3, ada: dict[str, str]) -> None:
    item = import_link(client, ada)
    [follow] = follows(client, ada)
    assert (follow["item_id"], follow["chapters"], follow["complete"]) == (item["id"], "3/?", False)
    assert follow["url"] == LINK


def test_finished_works_are_not_followed(client: TestClient, ao3: Ao3, ada: dict[str, str]) -> None:
    ao3.chapters = "12/12"
    import_link(client, ada)
    assert follows(client, ada) == []


def test_nothing_new_means_nothing_downloaded(
    client: TestClient, ao3: Ao3, ada: dict[str, str]
) -> None:
    import_link(client, ada)
    follow_id = follows(client, ada)[0]["id"]
    checked = client.post(f"/v1/library/follows/{follow_id}/check", headers=ada)
    assert checked.status_code == 200
    assert ao3.downloads == 1  # the import only


def test_new_chapters_replace_the_book_file(
    client: TestClient, ao3: Ao3, ada: dict[str, str]
) -> None:
    item = import_link(client, ada)
    phone = device(client, ada, "Phone")
    note_id = str(uuid.uuid4())
    push(
        client,
        ada,
        phone,
        {
            "key": str(uuid.uuid4()),
            "entity": "annotation",
            "entity_id": note_id,
            "op": "upsert",
            "data": {
                "item_id": item["id"],
                "chapter": 1,
                "quote": "Hextech",
                "color": "gold",
                "client_time": "2026-10-04T10:00:00Z",
            },
        },
    )
    since = pull(client, ada)["cursor"]

    ao3.chapters, ao3.updated = "4/?", "2026-10-05"
    follow_id = follows(client, ada)[0]["id"]
    checked = client.post(f"/v1/library/follows/{follow_id}/check", headers=ada).json()
    assert checked["chapters"] == "4/?"

    [book] = client.get("/v1/library", headers=ada).json()
    assert book["id"] == item["id"]  # same book…
    assert book["sha256"] != item["sha256"]  # …new file
    changes = pull(client, ada, since)["changes"]
    updated = next(c for c in changes if c["entity"] == "library_item")
    assert updated["data"]["sha256"] == book["sha256"]
    moved = next(c for c in changes if c["entity"] == "annotation")
    assert (moved["entity_id"], moved["data"]["file_sha256"]) == (note_id, book["sha256"])


def test_finished_works_stop_being_followed(
    client: TestClient, ao3: Ao3, ada: dict[str, str]
) -> None:
    import_link(client, ada)
    ao3.chapters, ao3.updated = "5/5", "2026-10-06"
    follow_id = follows(client, ada)[0]["id"]
    assert client.post(f"/v1/library/follows/{follow_id}/check", headers=ada).json()["complete"]


def test_following_can_be_stopped(client: TestClient, ao3: Ao3, ada: dict[str, str]) -> None:
    import_link(client, ada)
    bob = account(client, "bob@example.com")
    follow_id = follows(client, ada)[0]["id"]
    assert client.delete(f"/v1/library/follows/{follow_id}", headers=bob).status_code == 404
    assert client.delete(f"/v1/library/follows/{follow_id}", headers=ada).status_code == 204
    assert follows(client, ada) == []
    assert len(client.get("/v1/library", headers=ada).json()) == 1  # the book stays


def test_removing_the_book_stops_following(
    client: TestClient, ao3: Ao3, ada: dict[str, str]
) -> None:
    item = import_link(client, ada)
    client.delete(f"/v1/library/{item['id']}", headers=ada)
    assert follows(client, ada) == []


def test_the_daily_round_checks_due_works(
    app: FastAPI, client: TestClient, ao3: Ao3, ada: dict[str, str]
) -> None:
    import_link(client, ada)
    ao3.chapters, ao3.updated = "4/?", "2026-10-05"
    container: Container = app.state.container

    @asynccontextmanager
    async def services() -> AsyncGenerator[FollowService]:
        async with container.sessions() as session:
            yield make_follow_service(container, session)

    # Checked at import: not due before a day…
    assert asyncio.run(check_due_follows(services, timedelta(hours=24))) == 0
    # …due with a zero interval.
    assert asyncio.run(check_due_follows(services, timedelta(0))) == 1
    assert follows(client, ada)[0]["chapters"] == "4/?"
