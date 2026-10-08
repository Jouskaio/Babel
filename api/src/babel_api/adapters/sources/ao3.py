"""Archive of Our Own: a reader's bookmarks (and subscriptions when signed in).

AO3 has no API: pages are read like a browser would, slowly and identified by Babel's
user agent. Requests are spaced for the whole server (readers share its address), and
downloads even more: AO3 blocks addresses downloading many works in a row. When it asks
for a pause (429), every reader waits. Without a password only public bookmarks
are visible; with it, Babel signs in as the reader to also see private bookmarks,
subscriptions and works restricted to signed-in users. Sessions are kept per reader and
never shared between readers.
"""

import asyncio
import logging
import re
import time
from collections.abc import AsyncIterator
from typing import Any, NoReturn

import httpx
from bs4 import BeautifulSoup, Tag

from babel_api.adapters.sources.http import TIMEOUT, USER_AGENT, Throttle, retry_after
from babel_api.adapters.sources.stdlib_transport import StdlibTransport
from babel_api.domain.errors import SourceConnectionError, SourceRateLimitedError
from babel_api.domain.sources import RemoteEntry

log = logging.getLogger(__name__)

BASE = "https://archiveofourown.org"
_USERNAME = re.compile(r"^[A-Za-z0-9_]{3,40}$")
_WORK = re.compile(r"^/works/(\d+)$")
# A big account is scanned in the background, one page every few seconds: 150 pages is 3000 works.
MAX_PAGES = 150
SESSION_SECONDS = 30 * 60
RETRIES = 2
# A big account's bookmarks page is slow to build: AO3's front gives up (502/525) at the first
# tries, and the page is often ready for a later one. Lists are retried longer than downloads.
LISTING_RETRIES = 5
MAX_RETRY_WAIT = 30.0
# Pause asked by AO3 when it gives no Retry-After, and the longest one honored.
COOL_DOWN = 120.0
MAX_COOL_DOWN = 600.0


def _soup(response: httpx.Response) -> BeautifulSoup:
    return BeautifulSoup(response.text, "html.parser")


def _text(tag: Tag | None) -> str:
    return tag.get_text(" ", strip=True) if tag else ""


class Ao3Connector:
    # Works imported per "import all" call: each one waits for the download throttle.
    batch_size = 2

    def __init__(
        self,
        transport: httpx.AsyncBaseTransport | None = None,
        *,
        pause: float = 3.0,
        download_pause: float = 15.0,
    ) -> None:
        self._transport = transport or StdlibTransport()
        self._pause = pause
        self._requests = Throttle(pause)
        self._downloads = Throttle(download_pause)
        # Signed-in sessions, per reader: username -> (cookies, expiry).
        self._sessions: dict[str, tuple[httpx.Cookies, float]] = {}

    def _client(self, cookies: httpx.Cookies | None = None) -> httpx.AsyncClient:
        # One client per operation: cookies never leak from one reader to another.
        return httpx.AsyncClient(
            transport=self._transport,
            base_url=BASE,
            timeout=TIMEOUT,
            follow_redirects=True,
            headers={"User-Agent": USER_AGENT},
            cookies=cookies,
        )

    async def _get(
        self, client: httpx.AsyncClient, url: str, *, retries: int = RETRIES, **params: Any
    ) -> httpx.Response:
        # AO3 often answers 502/525 for a moment (its Cloudflare front): try a few times.
        for attempt in range(retries + 1):
            if attempt:
                await asyncio.sleep(min(self._pause * 2 * attempt, MAX_RETRY_WAIT))
            await self._requests.wait()
            try:
                response = await client.get(url, params=params or None)
            except httpx.HTTPError as error:
                if attempt == retries:
                    raise SourceConnectionError("unreachable") from error
                continue
            if response.status_code == 429:
                self._limited(response)
            if response.status_code < 500 or attempt == retries:
                if response.status_code >= 500:
                    log.warning(
                        "AO3 answered %s for %s after %s tries",
                        response.status_code,
                        url,
                        attempt + 1,
                    )
                return response
        raise SourceConnectionError("unreachable")  # pragma: no cover - loop always returns

    def _limited(self, response: httpx.Response) -> NoReturn:
        """AO3 asks for a pause: every reader of the server waits."""
        seconds = retry_after(response, COOL_DOWN, MAX_COOL_DOWN)
        self._requests.cool_down(seconds)
        self._downloads.cool_down(seconds)
        raise SourceRateLimitedError

    async def _session(self, username: str, password: str | None) -> httpx.AsyncClient:
        """A client signed in as the reader when a password is given."""
        if not password:
            return self._client()
        cached = self._sessions.get(username)
        if cached and cached[1] > time.monotonic():
            return self._client(cached[0])
        client = self._client()
        form = _soup(await self._get(client, "/users/login"))
        token = form.find("input", attrs={"name": "authenticity_token"})
        if not isinstance(token, Tag):
            raise SourceConnectionError("unreachable")
        await self._requests.wait()
        try:
            response = await client.post(
                "/users/login",
                data={
                    "authenticity_token": str(token.get("value") or ""),
                    "user[login]": username,
                    "user[password]": password,
                    "user[remember_me]": "0",
                    "commit": "Log in",
                },
            )
        except httpx.HTTPError as error:
            raise SourceConnectionError("unreachable") from error
        body = _soup(response).find("body")
        classes = body.get("class") if isinstance(body, Tag) else None
        if not classes or "logged-in" not in classes:
            raise SourceConnectionError("401")
        self._sessions[username] = (client.cookies, time.monotonic() + SESSION_SECONDS)
        return client

    async def check(self, config: dict[str, Any], token: str | None) -> dict[str, Any]:
        username = str(config.get("username", "")).strip()
        if not _USERNAME.fullmatch(username):
            raise SourceConnectionError("username")
        client = await self._session(username, token)
        response = await self._get(client, f"/users/{username}")
        if response.status_code == 404:
            raise SourceConnectionError("404")
        if response.status_code >= 400:
            raise SourceConnectionError("unreachable")
        return {"username": username}

    async def _works(self, client: httpx.AsyncClient, url: str, item: str) -> list[RemoteEntry]:
        """Works listed on every page of a bookmarks or subscriptions listing."""
        entries: list[RemoteEntry] = []
        for page in range(1, MAX_PAGES + 1):
            response = await self._get(client, url, retries=LISTING_RETRIES, page=page)
            if response.status_code >= 400:
                # A page that fails after its retries fails the scan: a silent partial list
                # would drop the works of the pages missing from it. Only the end of the list
                # (a 4xx after some pages) is a normal stop.
                if page == 1 or response.status_code >= 500:
                    raise SourceConnectionError(str(response.status_code))
                break
            soup = _soup(response)
            if page == 1 or page % 10 == 0:
                log.info("AO3 %s: page %s read, %s works so far", url, page, len(entries))
            for blurb in soup.select(item):
                entry = self._entry(blurb)
                if entry is not None:
                    entries.append(entry)
            if soup.select_one("ol.pagination li.next a[rel=next]") is None:
                break
        else:
            log.warning("AO3 list %s cut after %s pages", url, MAX_PAGES)
        return entries

    def _entry(self, blurb: Tag) -> RemoteEntry | None:
        link = next(
            (a for a in blurb.select("a[href]") if _WORK.fullmatch(str(a.get("href") or ""))),
            None,
        )
        if link is None:
            return None  # a series, an external or a deleted work
        work_id = _WORK.fullmatch(str(link.get("href")))
        assert work_id is not None  # noqa: S101 - matched just above
        # Chapters and update date change when the author posts: a new version to import.
        version = (
            f"{_text(blurb.select_one('dd.chapters'))}|{_text(blurb.select_one('p.datetime'))}"
        )
        return RemoteEntry(
            path=f"/works/{work_id.group(1)}",
            size=0,
            remote_id=f"{work_id.group(1)}:{version}"[:100],
            title=_text(link) or None,
            authors=tuple(_text(a) for a in blurb.select("a[rel=author]"))[:5],
            format="epub",
        )

    async def work(self, work_id: str) -> RemoteEntry:
        """A single work, from its page: what a pasted link points to."""
        client = self._client()
        response = await self._get(client, f"/works/{work_id}", view_adult="true")
        if response.status_code == 404:
            raise SourceConnectionError("404")
        if response.status_code >= 400:
            raise SourceConnectionError("unreachable")
        page = _soup(response)
        title = _text(page.select_one("h2.title"))
        if not title:
            # Restricted to signed-in members, or not a work page.
            raise SourceConnectionError("restricted")
        chapters = _text(page.select_one("dl.stats dd.chapters"))
        updated = _text(page.select_one("dl.stats dd.status")) or _text(
            page.select_one("dl.stats dd.published")
        )
        return RemoteEntry(
            path=f"/works/{work_id}",
            size=0,
            remote_id=f"{work_id}:{chapters}|{updated}"[:100],
            title=title,
            authors=tuple(_text(a) for a in page.select("h3.byline a[rel=author]"))[:5],
            format="epub",
        )

    async def list_entries(self, config: dict[str, Any], token: str | None) -> list[RemoteEntry]:
        username = str(config["username"])
        client = await self._session(username, token)
        entries = await self._works(client, f"/users/{username}/bookmarks", "li.bookmark.blurb")
        if token:
            entries += await self._works(
                client, f"/users/{username}/subscriptions", "dl.subscription dt"
            )
        unique: dict[str, RemoteEntry] = {}
        for entry in entries:
            unique.setdefault(entry.path, entry)
        return list(unique.values())

    async def fetch(
        self, config: dict[str, Any], token: str | None, entry: RemoteEntry
    ) -> AsyncIterator[bytes]:
        client = await self._session(str(config["username"]), token)
        work = await self._get(client, entry.path, view_adult="true")
        if work.status_code >= 400:
            raise SourceConnectionError(str(work.status_code))
        link = _soup(work).select_one("li.download a[href*='.epub']")
        if link is None:
            raise SourceConnectionError("no_download")  # restricted, or not available
        url = str(link.get("href"))
        for attempt in range(RETRIES + 1):
            if attempt:
                await asyncio.sleep(self._pause * 2 * attempt)
            await self._downloads.wait()
            await self._requests.wait()
            try:
                async with client.stream("GET", url) as response:
                    if response.status_code == 429:
                        self._limited(response)
                    if response.status_code >= 500 and attempt < RETRIES:
                        continue  # a passing error, before any byte was sent
                    if response.status_code >= 400:
                        raise SourceConnectionError(str(response.status_code))
                    async for chunk in response.aiter_bytes(1024 * 1024):
                        yield chunk
                    return
            except httpx.HTTPError as error:
                if attempt == RETRIES:
                    raise SourceConnectionError("unreachable") from error

    async def aclose(self) -> None:
        await self._transport.aclose()
