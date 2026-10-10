"""Readers ask for a book that is in none of their sources.

The request goes to the reader's own Chaptarr when they linked one, else to the server's (for
premium readers). Chaptarr finds and downloads the book into the library Kavita reads; once it
has the file, Babel asks Kavita to scan so the book soon shows up in the reader's sources.
"""

import logging
import re
from collections.abc import Awaitable, Callable
from dataclasses import replace
from datetime import UTC, datetime
from typing import Any, cast
from urllib.parse import urlsplit
from uuid import UUID

from babel_api.adapters.chaptarr import ChaptarrClient, ChaptarrError
from babel_api.adapters.db.request_repository import SqlRequestRepository
from babel_api.adapters.security.secrets import SecretBox
from babel_api.adapters.shelfmark import CJK, ShelfmarkClient, ShelfmarkError
from babel_api.domain.errors import (
    NotFoundError,
    PremiumRequiredError,
    RequestsUnavailableError,
)
from babel_api.domain.ports import UserRepository
from babel_api.domain.requests import BookRequest, ChaptarrLink, RequestStatus
from babel_api.domain.series import guess_series
from babel_api.services.works import WorkDetail, WorkService

log = logging.getLogger(__name__)

# chaptarr_id of a request sent to Shelfmark: it cannot be followed there.
SHELFMARK_ID = -1

ClientFactory = Callable[[str, str], ChaptarrClient]
ShelfmarkFactory = Callable[[str, str], ShelfmarkClient]


def volume_title(title: str) -> str:
    """ "Series - Subtitle To2" and "Series, Tome 2" are both "Series 2": the form catalogs and
    indexers agree on. Other titles are kept."""
    guess = guess_series(title)
    if guess is None:
        return title
    base = re.split(r"\s[-–:]\s|\(", guess.series)[0].strip()
    return f"{base} {guess.number:g}"


class RequestService:
    def __init__(
        self,
        requests: SqlRequestRepository,
        users: UserRepository,
        works: WorkService,
        server_chaptarr: Callable[[], ChaptarrClient] | None,
        reader_chaptarr: ClientFactory,
        secrets: SecretBox,
        scan_library: Callable[[], Awaitable[None]],
        shelfmark: Callable[[], ShelfmarkClient] | None = None,
        reader_shelfmark: ShelfmarkFactory | None = None,
    ) -> None:
        self._shelfmark = shelfmark
        self._reader_shelfmark = reader_shelfmark
        self._requests = requests
        self._users = users
        self._works = works
        self._server = server_chaptarr
        self._reader_client = reader_chaptarr
        self._secrets = secrets
        self._scan = scan_library

    # ------------------------------------------------------------ the reader's own Chaptarr
    async def link_status(self, user_id: UUID) -> ChaptarrLink | None:
        return await self._requests.link(user_id)

    @property
    def server_enabled(self) -> bool:
        return self._server is not None

    async def link(self, user_id: UUID, url: str, api_key: str) -> ChaptarrLink:
        """Checks the address and the key, then keeps them (the key encrypted)."""
        base = url.strip().rstrip("/")
        parts = urlsplit(base)
        if parts.scheme not in {"http", "https"} or not parts.hostname or not api_key.strip():
            raise ChaptarrError("address")
        client = self._reader_client(base, api_key.strip())
        try:
            await client.check()
        finally:
            await client.aclose()
        link = ChaptarrLink(
            user_id, base, self._secrets.encrypt(api_key.strip()), datetime.now(UTC)
        )
        await self._requests.save_link(link)
        await self._requests.commit()
        return link

    async def unlink(self, user_id: UUID) -> None:
        await self._requests.delete_link(user_id)
        await self._requests.commit()

    # ------------------------------------------------------------ the reader's own Shelfmark
    async def shelfmark_link_status(self, user_id: UUID) -> ChaptarrLink | None:
        return await self._requests.link(user_id, "shelfmark")

    @property
    def shelfmark_server_enabled(self) -> bool:
        return self._shelfmark is not None

    async def link_shelfmark(self, user_id: UUID, url: str, api_key: str) -> ChaptarrLink:
        """Checks the address and the key (SHELFMARK_API_KEY), then keeps them encrypted."""
        base = url.strip().rstrip("/")
        parts = urlsplit(base)
        if (
            self._reader_shelfmark is None
            or parts.scheme not in {"http", "https"}
            or not parts.hostname
            or not api_key.strip()
        ):
            raise ShelfmarkError("address")
        client = self._reader_shelfmark(base, api_key.strip())
        try:
            await client.check()
        finally:
            await client.aclose()
        link = ChaptarrLink(
            user_id, base, self._secrets.encrypt(api_key.strip()), datetime.now(UTC)
        )
        await self._requests.save_link(link, "shelfmark")
        await self._requests.commit()
        return link

    async def unlink_shelfmark(self, user_id: UUID) -> None:
        await self._requests.delete_link(user_id, "shelfmark")
        await self._requests.commit()

    async def _shelf_for(self, user_id: UUID) -> ShelfmarkClient | None:
        """The reader's own Shelfmark, else the server's when they are premium."""
        link = await self._requests.link(user_id, "shelfmark")
        if link is not None and self._reader_shelfmark is not None:
            return self._reader_shelfmark(link.base_url, self._secrets.decrypt(link.secret))
        user = await self._users.get_by_id(user_id)
        if self._shelfmark is not None and user is not None and user.has_premium:
            return self._shelfmark()
        return None

    # ------------------------------------------------------------ which Chaptarr
    async def _client_for(self, user_id: UUID) -> ChaptarrClient | None:
        """The reader's own Chaptarr, else the server's when they are premium."""
        link = await self._requests.link(user_id)
        if link is not None:
            return self._reader_client(link.base_url, self._secrets.decrypt(link.secret))
        user = await self._users.get_by_id(user_id)
        if self._server is not None and user is not None and user.has_premium:
            return self._server()
        return None

    async def enabled_for(self, user_id: UUID) -> bool:
        """Whether the reader can ask for books: they linked a Chaptarr, or the server has one
        and they are premium."""
        if await self._requests.link(user_id) is not None:
            return True
        if await self._requests.link(user_id, "shelfmark") is not None:
            return True
        user = await self._users.get_by_id(user_id)
        premium = user is not None and user.has_premium
        return premium and (self._server is not None or self._shelfmark is not None)

    # ------------------------------------------------------------ requests
    async def request(
        self, user_id: UUID, work_id: UUID, language: str = ""
    ) -> tuple[BookRequest, bool]:
        """Records the request at once (and whether it is new); [fulfill] then asks Chaptarr."""
        if not await self.enabled_for(user_id):
            # No Chaptarr or Shelfmark of their own: the server's are for premium readers.
            raise (
                PremiumRequiredError
                if self._server is not None or self._shelfmark is not None
                else RequestsUnavailableError
            )
        existing = await self._requests.get(user_id, work_id, language)
        if existing is not None and existing.status is not RequestStatus.NOT_FOUND:
            return existing, False
        await self._works.get(work_id)  # unknown work: not found
        saved = await self._requests.save(user_id, work_id, RequestStatus.REQUESTED, None, language)
        await self._requests.commit()
        return saved, True

    async def fulfill(self, user_id: UUID, work_id: UUID, language: str = "") -> None:
        """Finds the book in Chaptarr and adds it; a miss or a failure reads as "not found"
        (the reader can ask again)."""
        client = await self._client_for(user_id)
        shelf = await self._shelf_for(user_id)
        detail = await self._works.get(work_id)
        work = detail.work
        # The title the book bears in the language asked for ("Les Misérables", not "Les Mis...").
        title = volume_title(detail.localized(language or None)[0])
        # Shelfmark's search understands titles well (original ones too): it is asked for
        # everyone, and feeds the other titles Chaptarr is tried with.
        names, hits = await self._titles(title, detail, work.authors)
        queued = (
            await self._via_shelfmark(shelf, title, names, work.authors)
            if shelf is not None
            else None
        )
        if queued is not None:
            await self._requests.save(
                user_id,
                work_id,
                RequestStatus.REQUESTED,
                SHELFMARK_ID,
                language,
                shelfmark_ref=queued,
            )
            await self._requests.commit()
            if client is not None:
                await client.aclose()
            return
        if client is None:
            await self._requests.save(user_id, work_id, RequestStatus.NOT_FOUND, None, language)
            await self._requests.commit()
            return
        try:
            found = None
            for name in dict.fromkeys((title, *hits)):  # then the titles Shelfmark gave
                found = await client.lookup(name, work.authors)
                if found is not None:
                    break
            original = await self._english(client, detail, title, found)
            if found is None and original is None:
                await self._requests.save(user_id, work_id, RequestStatus.NOT_FOUND, None, language)
            else:
                # Indexers list manga under their English title: ask for that edition too.
                first = await client.add(found or cast(dict[str, Any], original))
                second = await self._add_extra(client, original) if found and original else None
                await self._requests.save(
                    user_id, work_id, RequestStatus.REQUESTED, first, language, second
                )
        except ChaptarrError as error:
            log.warning("Chaptarr request failed: %s", error.reason)
            await self._requests.save(user_id, work_id, RequestStatus.NOT_FOUND, None, language)
        finally:
            await client.aclose()
        await self._requests.commit()

    async def _titles(
        self, title: str, detail: WorkDetail, authors: tuple[str, ...]
    ) -> tuple[list[str], list[str]]:
        """(every title to try on Shelfmark, the Latin-script titles its search found for
        this volume). Empty second list when the server has no Shelfmark."""
        names = [volume_title(detail.localized("en")[0]), title]
        names += await self._works.other_titles(title, authors)
        names = list(dict.fromkeys(names))
        found: list[str] = []
        if self._shelfmark is not None:
            search = self._shelfmark()
            try:
                for hit in await search.search(title, authors):
                    text = str(hit.get("title", ""))
                    guess = guess_series(text)
                    if guess is not None and not CJK.search(text):
                        found.append(volume_title(text))
            except ShelfmarkError as error:
                log.warning("Shelfmark search failed: %s", error.reason)
            finally:
                await search.aclose()
        return names, [n for n in dict.fromkeys(found) if n not in names]

    async def _via_shelfmark(
        self, shelf: ShelfmarkClient, title: str, names: list[str], authors: tuple[str, ...]
    ) -> str | None:
        """Every book is downloaded through Shelfmark first (it understands titles best).
        Gives the id of the Shelfmark task, or None when it finds nothing or fails:
        Chaptarr then takes over."""
        try:
            log.info("Request %r: Shelfmark titles to try: %s", title, names)
            for name in names:
                task = await shelf.fetch(name, authors)
                if task is not None:
                    return task
        except ShelfmarkError as error:
            log.warning("Shelfmark request failed: %s", error.reason)
        finally:
            await shelf.aclose()
        return None

    @staticmethod
    async def _add_extra(client: ChaptarrClient, book: dict[str, Any]) -> int | None:
        """The second edition is a bonus: if Chaptarr refuses it (already there), the request
        still stands on the first."""
        try:
            return await client.add(book)
        except ChaptarrError as error:
            log.info("Chaptarr did not take the extra edition: %s", error.reason)
            return None

    @staticmethod
    async def _english(
        client: ChaptarrClient,
        detail: WorkDetail,
        title: str,
        found: dict[str, Any] | None,
    ) -> dict[str, Any] | None:
        """The English edition of a volume, when its title differs: release indexers know
        manga and light novels by their English (or romanized) title, and the reader need not.
        Best effort, never an error."""
        english = volume_title(detail.localized("en")[0])
        if guess_series(title) is None or english.casefold() == title.casefold():
            return None
        try:
            book = await client.lookup(english, detail.work.authors)
        except ChaptarrError:
            return None
        same = (
            found is not None
            and book is not None
            and found.get("foreignBookId") == (book.get("foreignBookId"))
        )
        return None if same else book

    async def users_waiting(self) -> list[UUID]:
        return await self._requests.users_waiting()

    @staticmethod
    def _with_progress(
        items: list[BookRequest], progress: dict[tuple[UUID, str], float]
    ) -> list[BookRequest]:
        return [
            replace(r, progress=progress[(r.work_id, r.language)])
            if (r.work_id, r.language) in progress
            else r
            for r in items
        ]

    async def _scan_if(self, arrived: bool) -> None:
        if not arrived:
            return
        try:
            await self._scan()
        except Exception:  # best effort: Kavita also scans on its own schedule
            log.warning("Could not ask Kavita to scan", exc_info=True)

    async def _follow_shelfmark(
        self, user_id: UUID, items: list[BookRequest]
    ) -> tuple[list[BookRequest], dict[tuple[UUID, str], float], bool]:
        """Requests sent to Shelfmark: how far each download is, and the ones that finished
        (available) or failed (not found). Shelfmark's queue is read once."""
        pending = [
            r
            for r in items
            if r.status is RequestStatus.REQUESTED
            and r.chaptarr_id == SHELFMARK_ID
            and r.shelfmark_ref
        ]
        shelf = await self._shelf_for(user_id) if pending else None
        if shelf is None:
            return items, {}, False
        try:
            queue = await shelf.queue_status()
        except ShelfmarkError as error:
            log.warning("Shelfmark did not answer while checking requests: %s", error.reason)
            return items, {}, False
        finally:
            await shelf.aclose()
        progress: dict[tuple[UUID, str], float] = {}
        arrived = False
        for request in pending:
            entry = queue.get(request.shelfmark_ref or "")
            if entry is None:
                continue
            state, percent = entry
            if state == "complete":
                status = RequestStatus.AVAILABLE
                arrived = True
            elif state in ("error", "cancelled"):
                status = RequestStatus.NOT_FOUND
            else:
                progress[(request.work_id, request.language)] = percent
                continue
            await self._requests.save(
                user_id, request.work_id, status, SHELFMARK_ID, request.language
            )
        if arrived or any(
            queue.get(r.shelfmark_ref or "", ("", 0))[0] in ("error", "cancelled") for r in pending
        ):
            await self._requests.commit()
            items = await self._requests.list_for(user_id)
        return items, progress, arrived

    async def list(self, user_id: UUID) -> list[BookRequest]:
        """The reader's requests; those still waiting are checked with Chaptarr first, and show
        how far their download has come."""
        items = await self._requests.list_for(user_id)
        items, shelf_progress, shelf_arrived = await self._follow_shelfmark(user_id, items)
        waiting = [
            r for r in items if r.status is RequestStatus.REQUESTED and (r.chaptarr_id or 0) > 0
        ]
        client = await self._client_for(user_id) if waiting else None
        if client is None:
            await self._scan_if(shelf_arrived)
            return self._with_progress(items, shelf_progress)
        arrived = shelf_arrived
        progress: dict[int, float] = {}
        try:
            for request in waiting:
                ids = [i for i in (request.chaptarr_id, request.alt_chaptarr_id) if i and i > 0]
                if any([await client.has_files(i) for i in ids]):
                    await self._requests.save(
                        user_id,
                        request.work_id,
                        RequestStatus.AVAILABLE,
                        request.chaptarr_id,
                        request.language,
                    )
                    arrived = True
            progress = await client.queue_progress()
        except ChaptarrError as error:
            log.warning("Chaptarr did not answer while checking requests: %s", error.reason)
        finally:
            await client.aclose()
        if arrived:
            await self._requests.commit()
            await self._scan_if(True)
            items = await self._requests.list_for(user_id)
        return self._with_progress(
            [
                replace(
                    r,
                    progress=progress.get(r.chaptarr_id or 0)
                    or progress.get(r.alt_chaptarr_id or 0),
                )
                if r.status is RequestStatus.REQUESTED and (r.chaptarr_id or 0) > 0
                else r
                for r in items
            ],
            shelf_progress,
        )

    async def cancel(self, user_id: UUID, work_id: UUID, language: str = "") -> None:
        """Forgets a request (what Chaptarr or Shelfmark already started is left alone)."""
        if await self._requests.get(user_id, work_id, language) is None:
            raise NotFoundError
        await self._requests.delete(user_id, work_id, language)
        await self._requests.commit()

    async def status_of(self, user_id: UUID, work_id: UUID, language: str = "") -> BookRequest:
        for request in await self.list(user_id):
            if request.work_id == work_id and request.language == language:
                return request
        raise NotFoundError
