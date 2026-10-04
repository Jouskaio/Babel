from dataclasses import replace

import httpx
import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from babel_api.adapters.sources.ao3 import Ao3Connector
from babel_api.adapters.sources.links import LinkFetcher
from tests.api.v1.test_library import account
from tests.books import epub

FANFIC = epub(title="Home Is Where the Heart Is", author="wintersong", isbn=None)
CLASSIC = epub(title="Pride and Prejudice", author="Jane Austen", isbn=None)
WORK_PAGE = (
    '<html><body class="logged-out"><dl class="stats"><dd class="published">2026-01-02</dd>'
    '<dd class="status">2026-10-01</dd><dd class="chapters">12/12</dd></dl>'
    '<h2 class="title heading">Home Is Where the Heart Is</h2>'
    '<h3 class="byline heading"><a rel="author" href="/users/wintersong">wintersong</a></h3>'
    '<ul><li class="download"><a href="/downloads/48213345/Home.epub?updated_at=1">EPUB</a>'
    "</li></ul></body></html>"
)
GUTENBERG_OPDS = (
    '<?xml version="1.0"?><feed xmlns="http://www.w3.org/2005/Atom"><entry>'
    "<title>Pride and Prejudice</title><author><name>Austen, Jane</name></author>"
    "</entry></feed>"
)


class Web:
    """AO3, Gutenberg and a file host, counting downloads."""

    def __init__(self) -> None:
        self.downloads: list[str] = []

    def __call__(self, request: httpx.Request) -> httpx.Response:
        url = str(request.url)
        if request.url.path == "/works/48213345":
            return httpx.Response(200, text=WORK_PAGE)
        if request.url.path == "/works/404":
            return httpx.Response(404)
        if request.url.path.startswith("/downloads/"):
            self.downloads.append(url)
            return httpx.Response(200, content=FANFIC)
        if url == "https://www.gutenberg.org/ebooks/1342.opds":
            return httpx.Response(200, text=GUTENBERG_OPDS)
        if url == "https://www.gutenberg.org/ebooks/1342.epub3.images":
            self.downloads.append(url)
            return httpx.Response(200, content=CLASSIC)
        if url == "https://books.example.com/Jane%20Eyre.epub":
            self.downloads.append(url)
            return httpx.Response(200, content=epub(title="Jane Eyre", isbn=None))
        if url == "https://books.example.com/page.html":
            return httpx.Response(200, text="<html>not a book</html>")
        return httpx.Response(404)


@pytest.fixture
def web(app: FastAPI) -> Web:
    fake = Web()
    transport = httpx.MockTransport(fake)
    app.state.container = replace(
        app.state.container,
        ao3=Ao3Connector(transport, pause=0, download_pause=0),
        link_fetcher=LinkFetcher(
            httpx.AsyncClient(transport=transport),
            allowed_hosts=("books.example.com", "www.gutenberg.org"),
        ),
    )
    return fake


@pytest.fixture
def ada(client: TestClient) -> dict[str, str]:
    return account(client, "ada@example.com")


@pytest.fixture
def bob(client: TestClient) -> dict[str, str]:
    return account(client, "bob@example.com")


AO3_LINK = "https://archiveofourown.org/works/48213345/chapters/121548123#workskin"


def test_ao3_links_are_recognized(client: TestClient, web: Web, ada: dict[str, str]) -> None:
    preview = client.post("/v1/library/links/preview", json={"url": AO3_LINK}, headers=ada)
    assert preview.json() == {
        "kind": "ao3",
        "title": "Home Is Where the Heart Is",
        "authors": ["wintersong"],
        "detail": "12/12",
        "on_babel": False,
    }
    assert web.downloads == []


def test_an_ao3_work_is_imported_once_for_everyone(
    client: TestClient, web: Web, ada: dict[str, str], bob: dict[str, str]
) -> None:
    imported = client.post("/v1/library/links", json={"url": AO3_LINK}, headers=ada)
    assert imported.status_code == 201
    assert imported.json()["title"] == "Home Is Where the Heart Is"
    preview = client.post("/v1/library/links/preview", json={"url": AO3_LINK}, headers=bob)
    assert preview.json()["on_babel"] is True
    assert client.post("/v1/library/links", json={"url": AO3_LINK}, headers=bob).status_code == 201
    assert len(web.downloads) == 1
    assert len(client.get("/v1/library", headers=bob).json()) == 1


def test_gutenberg_books_come_as_epub(client: TestClient, web: Web, ada: dict[str, str]) -> None:
    link = {"url": "https://www.gutenberg.org/ebooks/1342"}
    preview = client.post("/v1/library/links/preview", json=link, headers=ada).json()
    assert (preview["kind"], preview["title"], preview["authors"]) == (
        "gutenberg",
        "Pride and Prejudice",
        ["Austen, Jane"],
    )
    imported = client.post("/v1/library/links", json=link, headers=ada)
    assert imported.json()["title"] == "Pride and Prejudice"


def test_direct_file_links(client: TestClient, web: Web, ada: dict[str, str]) -> None:
    link = {"url": "https://books.example.com/Jane%20Eyre.epub"}
    preview = client.post("/v1/library/links/preview", json=link, headers=ada).json()
    assert (preview["kind"], preview["title"]) == ("file", "Jane Eyre.epub")
    assert client.post("/v1/library/links", json=link, headers=ada).json()["title"] == "Jane Eyre"


def test_pages_that_are_not_books_are_refused(
    client: TestClient, web: Web, ada: dict[str, str]
) -> None:
    link = {"url": "https://books.example.com/page.html"}
    response = client.post("/v1/library/links", json=link, headers=ada)
    assert response.status_code in (400, 415)
    assert client.get("/v1/library", headers=ada).json() == []


@pytest.mark.parametrize(
    ("url", "status"),
    [
        ("ftp://books.example.com/x.epub", 400),
        ("https://archiveofourown.org/works/404", 400),
        ("http://192.168.1.1/book.epub", 400),
    ],
)
def test_unusable_links(
    client: TestClient, web: Web, ada: dict[str, str], url: str, status: int
) -> None:
    response = client.post("/v1/library/links", json={"url": url}, headers=ada)
    assert response.status_code == status


def test_links_need_an_account(client: TestClient, web: Web) -> None:
    assert client.post("/v1/library/links", json={"url": AO3_LINK}).status_code == 401
