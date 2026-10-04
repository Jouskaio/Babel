import asyncio
import time

import pytest

from babel_api.adapters.sources.http import Throttle, book_format, check_url
from babel_api.domain.errors import SourceAddressBlockedError, SourceConnectionError


@pytest.mark.parametrize(
    "url",
    [
        "http://127.0.0.1/opds",
        "http://localhost:8080/opds",
        "http://192.168.1.106/",
        "http://10.0.0.5/dav",
        "http://169.254.169.254/latest/meta-data",
        "http://[::1]/",
        "http://[::ffff:192.168.1.1]/",
    ],
)
def test_private_addresses_are_refused(url: str) -> None:
    with pytest.raises(SourceAddressBlockedError):
        asyncio.run(check_url(url))


def test_allowed_hosts_can_be_private() -> None:
    asyncio.run(check_url("http://192.168.1.106/opds", ["192.168.1.106"]))


@pytest.mark.parametrize("url", ["ftp://example.com/x", "file:///etc/passwd", "http:///nohost"])
def test_only_http_urls_are_accepted(url: str) -> None:
    with pytest.raises(SourceConnectionError):
        asyncio.run(check_url(url))


def test_public_addresses_pass() -> None:
    asyncio.run(check_url("http://93.184.216.34/catalog"))


def test_formats_come_from_media_types_or_names() -> None:
    assert book_format("x", "application/epub+zip; charset=binary") == "epub"
    assert book_format("Book.PDF") == "pdf"
    assert book_format("comic.cbz") == "cbz"
    assert book_format("notes.txt") is None


def test_the_throttle_spaces_requests() -> None:
    async def three() -> float:
        throttle = Throttle(0.05)
        start = time.monotonic()
        for _ in range(3):
            await throttle.wait()
        return time.monotonic() - start

    assert asyncio.run(three()) >= 0.1


def test_a_cool_down_delays_the_next_request() -> None:
    async def run() -> float:
        throttle = Throttle(0)
        throttle.cool_down(0.1)
        start = time.monotonic()
        await throttle.wait()
        return time.monotonic() - start

    assert asyncio.run(run()) >= 0.09
