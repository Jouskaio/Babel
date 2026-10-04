"""Books reached by a link pasted by a reader: Project Gutenberg pages and direct files.

AO3 links go through the AO3 connector, so they share its pacing.
"""

import re
from collections.abc import AsyncIterator
from urllib.parse import unquote, urlsplit

import httpx
from defusedxml import ElementTree

from babel_api.adapters.sources.http import check_url, guarded_client
from babel_api.domain.errors import SourceConnectionError

GUTENBERG = "https://www.gutenberg.org"
_ATOM = "{http://www.w3.org/2005/Atom}"


def file_name(url: str) -> str:
    """The last segment of a link's path, decoded ("Jane%20Eyre.epub" -> "Jane Eyre.epub")."""
    name = unquote(urlsplit(url).path.rstrip("/").rsplit("/", 1)[-1])
    return name[:255] or "book"


class LinkFetcher:
    def __init__(
        self, client: httpx.AsyncClient | None = None, allowed_hosts: tuple[str, ...] = ()
    ) -> None:
        self._allowed = allowed_hosts
        self._client = client or guarded_client(allowed_hosts)

    async def gutenberg_details(self, book_id: str) -> tuple[str | None, tuple[str, ...]]:
        """Title and authors from the book's OPDS entry (nothing if it cannot be read)."""
        try:
            response = await self._client.get(f"{GUTENBERG}/ebooks/{book_id}.opds")
            root = ElementTree.fromstring(response.content)
        except (httpx.HTTPError, ElementTree.ParseError, ValueError):
            return None, ()
        entry = root.find(f"{_ATOM}entry")
        if response.status_code >= 400 or entry is None:
            return None, ()
        title = entry.findtext(f"{_ATOM}title")
        authors = tuple(
            name for a in entry.iterfind(f"{_ATOM}author") if (name := a.findtext(f"{_ATOM}name"))
        )
        return (title.strip() if title else None), authors[:5]

    async def stream(self, url: str) -> AsyncIterator[bytes]:
        await check_url(url, self._allowed)
        try:
            async with self._client.stream("GET", url) as response:
                if response.status_code in (401, 403, 404, 410):
                    raise SourceConnectionError(str(response.status_code))
                if response.status_code >= 400:
                    raise SourceConnectionError("unreachable")
                async for chunk in response.aiter_bytes(1024 * 1024):
                    yield chunk
        except httpx.HTTPError as error:
            raise SourceConnectionError("unreachable") from error

    async def aclose(self) -> None:
        await self._client.aclose()


GUTENBERG_BOOK = re.compile(
    r"^https?://(?:www\.)?gutenberg\.org/(?:ebooks|cache/epub)/(\d+)(?:[/.].*)?$", re.I
)
AO3_WORK = re.compile(
    r"^https?://(?:www\.)?archiveofourown\.org/(?:collections/[^/]+/)?works/(\d+)(?:[/?#].*)?$",
    re.I,
)
