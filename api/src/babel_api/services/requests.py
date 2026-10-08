"""Readers ask for a book that is in none of their sources.

The request goes to the reader's own Chaptarr when they linked one, else to the server's (for
premium readers). Chaptarr finds and downloads the book into the library Kavita reads; once it
has the file, Babel asks Kavita to scan so the book soon shows up in the reader's sources.
"""

import logging
from collections.abc import Awaitable, Callable
from datetime import UTC, datetime
from urllib.parse import urlsplit
from uuid import UUID

from babel_api.adapters.chaptarr import ChaptarrClient, ChaptarrError
from babel_api.adapters.db.request_repository import SqlRequestRepository
from babel_api.adapters.security.secrets import SecretBox
from babel_api.domain.errors import (
    NotFoundError,
    PremiumRequiredError,
    RequestsUnavailableError,
)
from babel_api.domain.ports import UserRepository
from babel_api.domain.requests import BookRequest, ChaptarrLink, RequestStatus
from babel_api.services.works import WorkService

log = logging.getLogger(__name__)

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
    ) -> None:
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
    async def request(self, user_id: UUID, work_id: UUID) -> tuple[BookRequest, bool]:
        """Records the request at once (and whether it is new); [fulfill] then asks Chaptarr."""
        client = await self._client_for(user_id)
        if client is None:
            # No Chaptarr of their own: the server's is for premium readers.
            raise PremiumRequiredError if self._server is not None else RequestsUnavailableError
        await client.aclose()
        existing = await self._requests.get(user_id, work_id)
        if existing is not None and existing.status is not RequestStatus.NOT_FOUND:
            return existing, False
        await self._works.get(work_id)  # unknown work: not found
        saved = await self._requests.save(user_id, work_id, RequestStatus.REQUESTED, None)
        await self._requests.commit()
        return saved, True

    async def fulfill(self, user_id: UUID, work_id: UUID) -> None:
        """Finds the book in Chaptarr and adds it; a miss or a failure reads as "not found"
        (the reader can ask again)."""
        client = await self._client_for(user_id)
        if client is None:
            return
        work = (await self._works.get(work_id)).work
        try:
            found = await client.lookup(work.title, work.authors)
            if found is None:
                await self._requests.save(user_id, work_id, RequestStatus.NOT_FOUND, None)
            else:
                await self._requests.save(
                    user_id, work_id, RequestStatus.REQUESTED, await client.add(found)
                )
        except ChaptarrError as error:
            log.warning("Chaptarr request failed: %s", error.reason)
            await self._requests.save(user_id, work_id, RequestStatus.NOT_FOUND, None)
        finally:
            await client.aclose()
        await self._requests.commit()

    async def list(self, user_id: UUID) -> list[BookRequest]:
        """The reader's requests; those still waiting are checked with Chaptarr first."""
        items = await self._requests.list_for(user_id)
        waiting = [
            r for r in items if r.status is RequestStatus.REQUESTED and r.chaptarr_id is not None
        ]
        client = await self._client_for(user_id) if waiting else None
        if client is None:
            return items
        arrived = False
        try:
            for request in waiting:
                if request.chaptarr_id is not None and await client.has_files(request.chaptarr_id):
                    await self._requests.save(
                        user_id, request.work_id, RequestStatus.AVAILABLE, request.chaptarr_id
                    )
                    arrived = True
        except ChaptarrError:
            log.warning("Chaptarr did not answer while checking requests")
        finally:
            await client.aclose()
        if not arrived:
            return items
        await self._requests.commit()
        try:
            await self._scan()
        except Exception:  # best effort: Kavita also scans on its own schedule
            log.warning("Could not ask Kavita to scan", exc_info=True)
        return await self._requests.list_for(user_id)

    async def status_of(self, user_id: UUID, work_id: UUID) -> BookRequest:
        for request in await self.list(user_id):
            if request.work_id == work_id:
                return request
        raise NotFoundError
