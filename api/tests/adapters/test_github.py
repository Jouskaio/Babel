import asyncio

import httpx
import pytest

from babel_api.adapters.sources.github import GitHubConnector
from babel_api.domain.errors import SourceConnectionError, SourceRateLimitedError
from babel_api.domain.sources import RemoteEntry

TREE = {
    "tree": [
        {"path": "README.md", "type": "blob", "sha": "a1", "size": 10},
        {"path": "books", "type": "tree", "sha": "t1"},
        {"path": "books/Jane Eyre.epub", "type": "blob", "sha": "b1", "size": 1200},
        {"path": "books/manga/One.CBZ", "type": "blob", "sha": "b2", "size": 3400},
        {"path": "other/notes.pdf", "type": "blob", "sha": "b3", "size": 50},
    ]
}


def connector(handler: object, seen: list[httpx.Request] | None = None) -> GitHubConnector:
    def record(request: httpx.Request) -> httpx.Response:
        if seen is not None:
            seen.append(request)
        return handler(request)  # type: ignore[operator]

    return GitHubConnector(httpx.AsyncClient(transport=httpx.MockTransport(record)))


def github(request: httpx.Request) -> httpx.Response:
    path = request.url.path
    if path == "/repos/ada/library":
        return httpx.Response(200, json={"default_branch": "main"})
    if path == "/repos/ada/library/git/trees/main":
        return httpx.Response(200, json=TREE)
    if path == "/repos/ada/library/git/blobs/b1":
        return httpx.Response(200, content=b"epub bytes")
    return httpx.Response(404, json={"message": "Not Found"})


def test_check_normalizes_the_configuration() -> None:
    config = asyncio.run(
        connector(github).check({"repository": " ada/library ", "folder": "/books/"}, None)
    )
    assert config == {"repository": "ada/library", "folder": "books", "branch": "main"}


@pytest.mark.parametrize("repository", ["", "ada", "ada/library/extra", "../x", "ada/li brary"])
def test_check_refuses_malformed_repositories(repository: str) -> None:
    with pytest.raises(SourceConnectionError):
        asyncio.run(connector(github).check({"repository": repository}, None))


def test_check_reports_unknown_or_private_repositories() -> None:
    with pytest.raises(SourceConnectionError):
        asyncio.run(connector(github).check({"repository": "ada/secret"}, None))


def test_the_token_is_sent_as_a_bearer() -> None:
    seen: list[httpx.Request] = []
    asyncio.run(connector(github, seen).check({"repository": "ada/library"}, "ghp_test1234"))
    assert seen[0].headers["Authorization"] == "Bearer ghp_test1234"
    seen.clear()
    asyncio.run(connector(github, seen).check({"repository": "ada/library"}, None))
    assert "Authorization" not in seen[0].headers


def test_only_books_inside_the_folder_are_listed() -> None:
    config = {"repository": "ada/library", "folder": "books", "branch": "main"}
    entries = asyncio.run(connector(github).list_entries(config, None))
    assert entries == [
        RemoteEntry(path="books/Jane Eyre.epub", size=1200, remote_id="b1"),
        RemoteEntry(path="books/manga/One.CBZ", size=3400, remote_id="b2"),
    ]
    assert entries[0].name == "Jane Eyre.epub"


def test_without_folder_the_whole_repository_is_listed() -> None:
    config = {"repository": "ada/library", "folder": "", "branch": "main"}
    entries = asyncio.run(connector(github).list_entries(config, None))
    assert [e.remote_id for e in entries] == ["b1", "b2", "b3"]


def test_fetch_streams_the_raw_blob() -> None:
    seen: list[httpx.Request] = []
    config = {"repository": "ada/library", "branch": "main"}

    async def read() -> bytes:
        entry = RemoteEntry(path="books/Jane Eyre.epub", size=10, remote_id="b1")
        return b"".join([c async for c in connector(github, seen).fetch(config, None, entry)])

    assert asyncio.run(read()) == b"epub bytes"
    assert seen[0].headers["Accept"] == "application/vnd.github.raw+json"


def test_errors_while_listing_are_connection_errors() -> None:
    def down(request: httpx.Request) -> httpx.Response:
        raise httpx.ConnectError("down", request=request)

    config = {"repository": "ada/library", "branch": "main"}
    with pytest.raises(SourceConnectionError):
        asyncio.run(connector(down).list_entries(config, None))


@pytest.mark.parametrize(
    ("status", "headers"),
    [(403, {"x-ratelimit-remaining": "0"}), (429, {})],
)
def test_rate_limits_are_told_apart(status: int, headers: dict[str, str]) -> None:
    def limited(request: httpx.Request) -> httpx.Response:
        return httpx.Response(status, headers=headers, json={"message": "rate limit"})

    with pytest.raises(SourceRateLimitedError):
        asyncio.run(connector(limited).check({"repository": "ada/library"}, None))
    config = {"repository": "ada/library", "branch": "main"}
    with pytest.raises(SourceRateLimitedError):
        asyncio.run(connector(limited).list_entries(config, None))


def test_a_403_with_requests_left_is_a_refusal() -> None:
    def forbidden(request: httpx.Request) -> httpx.Response:
        return httpx.Response(403, headers={"x-ratelimit-remaining": "42"})

    with pytest.raises(SourceConnectionError) as raised:
        asyncio.run(connector(forbidden).check({"repository": "ada/library"}, None))
    assert not isinstance(raised.value, SourceRateLimitedError)
