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
from typing import Any, NoReturn, cast

import httpx
from bs4 import BeautifulSoup, Tag

from babel_api.adapters.sources.http import TIMEOUT, USER_AGENT, Throttle, retry_after
from babel_api.adapters.sources.stdlib_transport import StdlibTransport
from babel_api.domain.errors import SourceConnectionError, SourceRateLimitedError
from babel_api.domain.sources import Ao3Hit, Ao3Page, Ao3Query, FanficDetails, RemoteEntry

log = logging.getLogger(__name__)

BASE = "https://archiveofourown.org"
_USERNAME = re.compile(r"^[A-Za-z0-9_]{3,40}$")
_WORK = re.compile(r"^/works/(\d+)$")
# A big account is scanned in the background, one page every few seconds: 150 pages is 3000 works.
MAX_PAGES = 150
SESSION_SECONDS = 30 * 60
SEARCH_SECONDS = 10 * 60
SEARCH_RETRIES = 2
SEARCH_CACHE = 100
_SORT = {
    "best": "_score",
    "kudos": "kudos_count",
    "hits": "hits",
    "date": "revised_at",
    "created": "created_at",
    "words": "word_count",
    "bookmarks": "bookmarks_count",
    "comments": "comments_count",
}
_FOUND = re.compile(r"(?:of\s+)?([\d,]+)\s+(?:Works?\s+)?(?:Found|found)", re.IGNORECASE)
DETAILS_SECONDS = 6 * 3600
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
        self._details: dict[str, tuple[float, FanficDetails]] = {}
        self._searches: dict[Ao3Query, tuple[float, Ao3Page]] = {}

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
        page = await self._get(client, "/users/login", retries=LISTING_RETRIES)
        if page.status_code >= 400:
            raise SourceConnectionError("unreachable")
        form = _soup(page)
        token = form.find("input", attrs={"name": "authenticity_token"})
        if not isinstance(token, Tag):
            raise SourceConnectionError("unreachable")
        data = {
            "authenticity_token": str(token.get("value") or ""),
            "user[login]": username,
            "user[password]": password,
            "user[remember_me]": "0",
            "commit": "Log in",
        }
        # AO3's front often fails (525) before the login reaches AO3: nothing was processed, so
        # sending it again is safe. A failure is "unreachable", never "wrong password".
        response: httpx.Response | None = None
        for attempt in range(LISTING_RETRIES + 1):
            if attempt:
                await asyncio.sleep(min(self._pause * 2 * attempt, MAX_RETRY_WAIT))
            await self._requests.wait()
            try:
                response = await client.post("/users/login", data=data)
            except httpx.HTTPError as error:
                if attempt == LISTING_RETRIES:
                    raise SourceConnectionError("unreachable") from error
                continue
            if response.status_code == 429:
                self._limited(response)
            if response.status_code < 500:
                break
            if attempt == LISTING_RETRIES:
                log.warning(
                    "AO3 answered %s to the login after %s tries", response.status_code, attempt + 1
                )
                raise SourceConnectionError("unreachable")
        if response is None:  # pragma: no cover - the loop always answers or raises
            raise SourceConnectionError("unreachable")
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

    async def details(
        self, config: dict[str, Any], token: str | None, work_id: str
    ) -> FanficDetails:
        """The fanfiction's page: summary, tags and numbers (kept for a few hours)."""
        cached = self._details.get(work_id)
        if cached is not None and time.monotonic() - cached[0] < DETAILS_SECONDS:
            return cached[1]
        username = str(config.get("username", "")).strip()
        client = await self._session(username, token) if username else self._client()
        response = await self._get(client, f"/works/{work_id}", view_adult="true")
        if response.status_code == 404:
            raise SourceConnectionError("404")
        if response.status_code >= 400:
            raise SourceConnectionError("unreachable")
        page = _soup(response)
        title = _text(page.select_one("h2.title"))
        if not title:
            raise SourceConnectionError("restricted")  # members only, or not a work page

        def tags(css: str) -> tuple[str, ...]:
            return tuple(_text(a) for a in page.select(f"dd.{css} a.tag"))

        def number(css: str) -> int | None:
            digits = _text(page.select_one(f"dl.stats dd.{css}")).replace(",", "")
            return int(digits) if digits.isdigit() else None

        summary = page.select_one("div.summary blockquote")
        series = page.select_one("dd.series span.series a")
        details = FanficDetails(
            title=title,
            authors=tuple(_text(a) for a in page.select("h3.byline a[rel=author]"))[:5],
            summary=_text(summary) or None,
            rating=next(iter(tags("rating")), None),
            warnings=tags("warning"),
            categories=tags("category"),
            fandoms=tags("fandom"),
            relationships=tags("relationship"),
            characters=tags("character"),
            tags=tags("freeform"),
            language=_text(page.select_one("dd.language")) or None,
            words=number("words"),
            chapters=_text(page.select_one("dl.stats dd.chapters")) or None,
            published=_text(page.select_one("dl.stats dd.published")) or None,
            updated=_text(page.select_one("dl.stats dd.status")) or None,
            kudos=number("kudos"),
            hits=number("hits"),
            comments=number("comments"),
            bookmarks=number("bookmarks"),
            series=_text(series) or None,
        )
        self._details[work_id] = (time.monotonic(), details)
        return details

    @staticmethod
    def search_params(q: Ao3Query) -> dict[str, str]:
        text = q.text.strip()
        tags = [t.strip() for t in q.tags if t.strip()]
        params = {"commit": "Search"}
        if tags and not q.any_tag:
            # Every tag is required: AO3's own tag fields work that way.
            params["work_search[freeform_names]"] = ",".join(tags)
        elif tags:
            either = " OR ".join(f'"{t}"' for t in tags)
            text = f"({either}) {text}".strip() if text else f"({either})"
        excluded = [t.strip() for t in q.excluded if t.strip()]
        if excluded:
            text = " ".join([text, *(f'-"{t}"' for t in excluded)]).strip()
        if text:
            params["work_search[query]"] = text
        if q.fandom.strip():
            params["work_search[fandom_names]"] = q.fandom.strip()
        if q.language:
            params["work_search[language_id]"] = q.language
        if q.complete is not None:
            params["work_search[complete]"] = "T" if q.complete else "F"
        for field, value in (
            ("word_count", q.min_words),
            ("kudos_count", q.min_kudos),
            ("hits", q.min_hits),
        ):
            if value:
                params[f"work_search[{field}]"] = f">{value}"
        if q.updated_within.strip():
            params["work_search[revised_at]"] = f"<{q.updated_within.strip()} ago"
        params["work_search[sort_column]"] = _SORT.get(q.sort, "_score")
        params["work_search[sort_direction]"] = "desc" if q.descending else "asc"
        if q.page > 1:
            params["page"] = str(q.page)
        return params

    @staticmethod
    def _hit(blurb: Tag) -> Ao3Hit | None:
        link = blurb.select_one("h4.heading a[href^='/works/']")
        match = _WORK.fullmatch(str(link.get("href") or "")) if link else None
        if link is None or match is None:
            return None  # a series or an external work

        def tags(css: str) -> tuple[str, ...]:
            return tuple(_text(a) for a in blurb.select(f"ul.tags li.{css} a.tag"))

        def number(css: str) -> int | None:
            digits = _text(blurb.select_one(f"dl.stats dd.{css}")).replace(",", "")
            return int(digits) if digits.isdigit() else None

        status = blurb.select_one("span.iswip")
        title = str(status.get("title") or "").lower() if status else ""
        summary = blurb.select_one("blockquote.summary")
        rating = blurb.select_one("span.rating")
        return Ao3Hit(
            work_id=match.group(1),
            title=_text(link),
            authors=tuple(_text(a) for a in blurb.select("a[rel=author]"))[:5],
            fandoms=tuple(_text(a) for a in blurb.select("h5.fandoms a.tag"))[:5],
            rating=_text(rating.select_one(".text")) or _text(rating) if rating else None,
            warnings=tags("warnings"),
            relationships=tags("relationships")[:6],
            characters=tags("characters")[:6],
            tags=tags("freeforms")[:12],
            summary=_text(summary) or None,
            language=_text(blurb.select_one("dl.stats dd.language")) or None,
            words=number("words"),
            chapters=_text(blurb.select_one("dl.stats dd.chapters")) or None,
            updated=_text(blurb.select_one("p.datetime")) or None,
            complete=("complete" in title) if title else None,
            kudos=number("kudos"),
            hits=number("hits"),
            comments=number("comments"),
            bookmarks=number("bookmarks"),
        )

    async def search(self, query: Ao3Query) -> Ao3Page:
        """A page of AO3's work search (kept ten minutes: the same page is often asked again)."""
        cached = self._searches.get(query)
        if cached is not None and time.monotonic() - cached[0] < SEARCH_SECONDS:
            return cached[1]
        params: dict[str, Any] = dict(self.search_params(query))
        # AO3's front often answers 525 for a moment: a search is retried a few times.
        response = await self._get(
            self._client(), "/works/search", retries=SEARCH_RETRIES, **params
        )
        if response.status_code >= 400:
            raise SourceConnectionError(str(response.status_code))
        soup = _soup(response)
        hits = tuple(
            hit for blurb in soup.select("li.work.blurb") if (hit := self._hit(blurb)) is not None
        )
        found = _FOUND.search(_text(soup.select_one("h3.heading")))
        page = Ao3Page(
            hits=hits,
            page=max(1, query.page),
            has_next=soup.select_one("ol.pagination li.next a[rel=next]") is not None,
            total=int(found.group(1).replace(",", "")) if found else None,
        )
        if len(self._searches) >= SEARCH_CACHE:
            self._searches.pop(next(iter(self._searches)))
        self._searches[query] = (time.monotonic(), page)
        return page

    async def suggest_tags(self, term: str) -> list[str]:
        """Tags AO3 knows that start like [term] (its own autocomplete)."""
        term = term.strip()
        if len(term) < 2:
            return []
        response = await self._get(
            self._client(), "/autocomplete/freeform", retries=1, term=term[:80]
        )
        if response.status_code >= 400:
            raise SourceConnectionError(str(response.status_code))
        try:
            found: Any = response.json()
        except ValueError:
            return []
        if not isinstance(found, list):
            return []
        names: list[str] = []
        for entry in cast(list[Any], found):
            if not isinstance(entry, dict):
                continue
            name = cast(dict[str, Any], entry).get("name")
            if isinstance(name, str) and name:
                names.append(name)
        return names[:10]

    async def kudos(self, config: dict[str, Any], token: str | None, work_id: str) -> bool:
        """Leaves kudos on a work, as the reader when a password is known (else as a guest).
        True when they were given now, False when this reader had already given them."""
        username = str(config.get("username", "")).strip()
        client = await self._session(username, token) if username else self._client()
        page = await self._get(client, f"/works/{work_id}", view_adult="true")
        if page.status_code >= 400:
            raise SourceConnectionError("unreachable")
        soup = _soup(page)
        meta = soup.find("meta", attrs={"name": "csrf-token"})
        field = soup.select_one("form#new_kudo input[name=authenticity_token]")
        csrf = str((meta or field or {}).get("content" if meta else "value") or "")  # type: ignore[union-attr]
        if not csrf:
            raise SourceConnectionError("restricted")
        await self._requests.wait()
        try:
            response = await client.post(
                "/kudos.js",
                data={
                    "authenticity_token": csrf,
                    "kudo[commentable_id]": work_id,
                    "kudo[commentable_type]": "Work",
                },
                headers={
                    "X-CSRF-Token": csrf,
                    "X-Requested-With": "XMLHttpRequest",
                    "Accept": "application/json, text/javascript, */*; q=0.01",
                    "Referer": f"{BASE}/works/{work_id}",
                },
            )
        except httpx.HTTPError as error:
            raise SourceConnectionError("unreachable") from error
        if response.status_code == 429:
            self._limited(response)
        if response.status_code in (200, 201):
            return True
        if response.status_code == 422:
            return False  # "You have already left kudos here"
        raise SourceConnectionError("unreachable")

    async def list_entries(self, config: dict[str, Any], token: str | None) -> list[RemoteEntry]:
        username = str(config["username"])
        try:
            client = await self._session(username, token)
        except SourceConnectionError as error:
            if str(error) != "unreachable":
                raise
            # AO3 refuses the sign-in (its front answers 418/525 at times): the public
            # bookmarks are still there to read, subscriptions wait for the next scan.
            log.warning("AO3 sign-in of %s failed: scanning the public bookmarks only", username)
            client, token = self._client(), None
        entries = await self._works(client, f"/users/{username}/bookmarks", "li.bookmark.blurb")
        if token:
            try:
                entries += await self._works(
                    client, f"/users/{username}/subscriptions", "dl.subscription dt"
                )
            except SourceConnectionError:
                # A subscriptions page that will not load must not lose the bookmarks scan.
                log.warning("AO3 subscriptions of %s skipped in this scan", username)
        unique: dict[str, RemoteEntry] = {}
        for entry in entries:
            unique.setdefault(entry.path, entry)
        return list(unique.values())

    async def subscriptions(self, config: dict[str, Any], token: str | None) -> list[RemoteEntry]:
        """The works the reader is subscribed to (needs the AO3 password)."""
        username = str(config["username"])
        client = await self._session(username, token)
        return await self._works(client, f"/users/{username}/subscriptions", "dl.subscription dt")

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
