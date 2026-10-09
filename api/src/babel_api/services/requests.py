"""Readers ask for a book that is in none of their sources.

The request goes to the reader's own Chaptarr when they linked one, else to the server's (for
premium readers). Chaptarr finds and downloads the book into the library Kavita reads; once it
has the file, Babel asks Kavita to scan so the book soon shows up in the reader's sources.
"""

import logging
from collections.abc import Awaitable, Callable
from dataclasses import replace
from datetime import UTC, datetime
from typing import Any, cast
from urllib.parse import urlsplit
from uuid import UUID

from babel_api.adapters.chaptarr import ChaptarrClient, ChaptarrError
from babel_api.adapters.db.request_repository import SqlRequestRepository
from babel_api.adapters.security.secrets import SecretBox
from babel_api.adapters.shelfmark import ShelfmarkClient, ShelfmarkError
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
    ) -> None:
        self._shelfmark = shelfmark
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
        user = await self._users.get_by_id(user_id)
        return self._server is not None and user is not None and user.has_premium

    # ------------------------------------------------------------ requests
    async def request(
        self, user_id: UUID, work_id: UUID, language: str = ""
    ) -> tuple[BookRequest, bool]:
        """Records the request at once (and whether it is new); [fulfill] then asks Chaptarr."""
        client = await self._client_for(user_id)
        if client is None:
            # No Chaptarr of their own: the server's is for premium readers.
            raise PremiumRequiredError if self._server is not None else RequestsUnavailableError
        await client.aclose()
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
        if client is None:
            return
        detail = await self._works.get(work_id)
        work = detail.work
        # The title the book bears in the language asked for ("Les Misérables", not "Les Mis...").
        title = detail.localized(language or None)[0]
        if await self._via_shelfmark(title, detail, work.authors):
            await self._requests.save(
                user_id, work_id, RequestStatus.REQUESTED, SHELFMARK_ID, language
            )
            await self._requests.commit()
            await client.aclose()
            return
        try:
            found = await client.lookup(title, work.authors)
            original = await self._english(client, detail, title, found)
            if found is None and original is None:
                await self._requests.save(user_id, work_id, RequestStatus.NOT_FOUND, None, language)
            else:
                # Indexers list manga under their English title: ask for that edition too.
                first = await client.add(found or cast(dict[str, Any], original))
                second = await client.add(original) if found and original else None
                await self._requests.save(
                    user_id, work_id, RequestStatus.REQUESTED, first, language, second
                )
        except ChaptarrError as error:
            log.warning("Chaptarr request failed: %s", error.reason)
            await self._requests.save(user_id, work_id, RequestStatus.NOT_FOUND, None, language)
        finally:
            await client.aclose()
        await self._requests.commit()

    async def _via_shelfmark(
        self, title: str, detail: WorkDetail, authors: tuple[str, ...]
    ) -> bool:
        """Manga and other numbered volumes go to Shelfmark first (English title preferred:
        indexers know them by it). False when it is not set, finds nothing or fails."""
        if self._shelfmark is None or guess_series(title) is None:
            return False
        shelf = self._shelfmark()
        try:
            for name in dict.fromkeys((detail.localized("en")[0], title)):
                if await shelf.fetch(name, authors):
                    return True
        except ShelfmarkError as error:
            log.warning("Shelfmark request failed: %s", error.reason)
        finally:
            await shelf.aclose()
        return False

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
        english = detail.localized("en")[0]
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

    async def list(self, user_id: UUID) -> list[BookRequest]:
        """The reader's requests; those still waiting are checked with Chaptarr first, and show
        how far their download has come."""
        items = await self._requests.list_for(user_id)
        waiting = [
            r for r in items if r.status is RequestStatus.REQUESTED and (r.chaptarr_id or 0) > 0
        ]
        client = await self._client_for(user_id) if waiting else None
        if client is None:
            return items
        arrived = False
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
        except ChaptarrError:
            log.warning("Chaptarr did not answer while checking requests")
        finally:
            await client.aclose()
        if arrived:
            await self._requests.commit()
            try:
                await self._scan()
            except Exception:  # best effort: Kavita also scans on its own schedule
                log.warning("Could not ask Kavita to scan", exc_info=True)
            items = await self._requests.list_for(user_id)
        return [
            replace(
                r,
                progress=progress.get(r.chaptarr_id or 0) or progress.get(r.alt_chaptarr_id or 0),
            )
            if r.status is RequestStatus.REQUESTED and (r.chaptarr_id or 0) > 0
            else r
            for r in items
        ]

    async def status_of(self, user_id: UUID, work_id: UUID, language: str = "") -> BookRequest:
        for request in await self.list(user_id):
            if request.work_id == work_id and request.language == language:
                return request
        raise NotFoundError
