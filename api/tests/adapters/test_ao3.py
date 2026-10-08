import asyncio

import httpx
import pytest

from babel_api.adapters.sources.ao3 import Ao3Connector
from babel_api.domain.errors import SourceConnectionError, SourceRateLimitedError


def blurb(work_id: int, title: str, author: str, chapters: str, date: str) -> str:
    return (
        f'<li id="bookmark_{work_id}" class="bookmark blurb group" role="article">'
        f'<div class="header module"><h4 class="heading"><a href="/works/{work_id}">{title}</a>'
        f' by <a rel="author" href="/users/{author}/pseuds/{author}">{author}</a></h4>'
        f'<p class="datetime">{date}</p></div>'
        f'<dl class="stats"><dt>Chapters:</dt><dd class="chapters">{chapters}</dd></dl></li>'
    )


def page(items: str, *, next_page: bool = False, logged_in: bool = False) -> str:
    pagination = (
        '<ol class="pagination actions"><li class="next"><a rel="next" href="?page=2">Next</a>'
        "</li></ol>"
        if next_page
        else ""
    )
    body_class = "logged-in" if logged_in else "logged-out"
    listing = f'<ol class="bookmark index group">{items}</ol>'
    return f'<html><body class="{body_class}">{listing}{pagination}</body></html>'


class FakeAo3:
    def __init__(self) -> None:
        self.requests: list[httpx.Request] = []
        self.limited = False
        self.flaky = 0

    def __call__(self, request: httpx.Request) -> httpx.Response:
        self.requests.append(request)
        if self.limited:
            return httpx.Response(429)
        if self.flaky:
            self.flaky -= 1
            return httpx.Response(525)
        path, query = request.url.path, dict(request.url.params)
        signed_in = "session=ada" in request.headers.get("cookie", "")
        if path == "/users/login" and request.method == "GET":
            return httpx.Response(
                200, text='<form><input name="authenticity_token" value="tok"/></form>'
            )
        if path == "/users/login":
            ok = b"user%5Bpassword%5D=right" in request.content and b"tok" in request.content
            return httpx.Response(
                200,
                text=page("", logged_in=ok),
                headers={"set-cookie": "session=ada; Path=/"} if ok else {},
            )
        if path == "/users/ada":
            return httpx.Response(200, text=page(""))
        if path == "/users/ada/bookmarks":
            if query.get("page") == "2":
                return httpx.Response(
                    200, text=page(blurb(3, "Third", "carol", "1/1", "01 Sep 2026"))
                )
            items = blurb(1, "First", "alice", "3/?", "02 Oct 2026") + (
                '<li class="bookmark blurb group"><h4 class="heading">'
                '<a href="/series/9">A series</a></h4></li>'
            )
            if signed_in:
                items += blurb(2, "Private one", "bob", "1/1", "03 Oct 2026")
            return httpx.Response(200, text=page(items, next_page=True))
        if path == "/users/ada/subscriptions":
            return httpx.Response(
                200,
                text='<html><body class="logged-in"><dl class="subscription index group">'
                '<dt><a href="/works/4">Followed</a> by <a rel="author" href="/users/dan">dan</a>'
                "</dt></dl></body></html>",
            )
        if path == "/works/1":
            return httpx.Response(
                200,
                text='<ul><li class="download"><a href="/downloads/1/First.epub?updated_at=1">'
                "EPUB</a></li></ul>",
            )
        if path == "/downloads/1/First.epub":
            return httpx.Response(200, content=b"epub bytes")
        return httpx.Response(404)


def connector(fake: FakeAo3) -> Ao3Connector:
    return Ao3Connector(httpx.MockTransport(fake), pause=0, download_pause=0)


def test_public_bookmarks_are_listed_page_by_page() -> None:
    fake = FakeAo3()
    entries = asyncio.run(connector(fake).list_entries({"username": "ada"}, None))
    assert [(e.title, e.authors, e.path) for e in entries] == [
        ("First", ("alice",), "/works/1"),
        ("Third", ("carol",), "/works/3"),
    ]
    assert all(e.format == "epub" for e in entries)


def test_signing_in_adds_private_bookmarks_and_subscriptions() -> None:
    entries = asyncio.run(connector(FakeAo3()).list_entries({"username": "ada"}, "right"))
    assert {e.title for e in entries} == {"First", "Private one", "Third", "Followed"}


def test_wrong_passwords_are_refused() -> None:
    with pytest.raises(SourceConnectionError, match="401"):
        asyncio.run(connector(FakeAo3()).check({"username": "ada"}, "wrong"))


def test_check_validates_the_account() -> None:
    assert asyncio.run(connector(FakeAo3()).check({"username": " ada "}, None)) == {
        "username": "ada"
    }
    with pytest.raises(SourceConnectionError):
        asyncio.run(connector(FakeAo3()).check({"username": "nobody"}, None))
    with pytest.raises(SourceConnectionError):
        asyncio.run(connector(FakeAo3()).check({"username": "../x"}, None))


def test_new_chapters_make_a_new_version() -> None:
    fake = FakeAo3()
    first = asyncio.run(connector(fake).list_entries({"username": "ada"}, None))[0]
    assert "3/?" in first.remote_id


def test_works_are_downloaded_as_epub() -> None:
    fake = FakeAo3()
    ao3 = connector(fake)
    entry = asyncio.run(ao3.list_entries({"username": "ada"}, None))[0]

    async def download() -> bytes:
        return b"".join([c async for c in ao3.fetch({"username": "ada"}, None, entry)])

    assert asyncio.run(download()) == b"epub bytes"
    assert fake.requests[-2].url.params["view_adult"] == "true"


def test_rate_limits_are_reported() -> None:
    fake = FakeAo3()
    fake.limited = True
    with pytest.raises(SourceRateLimitedError):
        asyncio.run(connector(fake).list_entries({"username": "ada"}, None))


def test_sessions_are_not_shared_between_readers() -> None:
    fake = FakeAo3()
    ao3 = connector(fake)
    asyncio.run(ao3.list_entries({"username": "ada"}, "right"))
    fake.requests.clear()
    # Another reader without a password: no cookie from Ada's session.
    asyncio.run(ao3.list_entries({"username": "ada"}, None))
    assert all("session=ada" not in r.headers.get("cookie", "") for r in fake.requests)


def test_passing_server_errors_are_retried() -> None:
    fake = FakeAo3()
    fake.flaky = 2
    assert asyncio.run(connector(fake).check({"username": "ada"}, None)) == {"username": "ada"}
    fake.flaky = 3
    with pytest.raises(SourceConnectionError):
        asyncio.run(connector(fake).check({"username": "ada"}, None))


def test_a_slow_bookmarks_page_is_retried_longer_than_other_requests() -> None:
    fake = FakeAo3()
    fake.flaky = 5  # a big account: AO3's front gives up several times first
    assert asyncio.run(connector(fake).list_entries({"username": "ada"}, None)) is not None
    fake.flaky = 6
    with pytest.raises(SourceConnectionError):
        asyncio.run(connector(fake).list_entries({"username": "ada"}, None))


def test_a_rate_limit_pauses_every_request() -> None:
    fake = FakeAo3()
    ao3 = connector(fake)
    fake.limited = True
    with pytest.raises(SourceRateLimitedError):
        asyncio.run(ao3.check({"username": "ada"}, None))
    fake.limited = False
    fake.requests.clear()

    async def soon() -> None:
        # Retry-After absent: two minutes. Nothing is sent meanwhile.
        await asyncio.wait_for(ao3.check({"username": "ada"}, None), timeout=0.2)

    with pytest.raises(TimeoutError):
        asyncio.run(soon())
    assert fake.requests == []
