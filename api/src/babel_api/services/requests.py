"""Premium readers ask for a book that is in none of their sources.

Chaptarr finds and downloads it into the library folder Kavita reads; once it has the
file, Babel asks Kavita to scan so the book soon shows up in the reader's sources.
"""

import logging
from collections.abc import Awaitable, Callable
from uuid import UUID

from babel_api.adapters.chaptarr import ChaptarrClient, ChaptarrError
from babel_api.adapters.db.request_repository import SqlRequestRepository
from babel_api.domain.errors import (
    NotFoundError,
    PremiumRequiredError,
    RequestsUnavailableError,
)
from babel_api.domain.ports import UserRepository
from babel_api.domain.requests import BookRequest, RequestStatus
from babel_api.services.works import WorkService

log = logging.getLogger(__name__)


class RequestService:
    def __init__(
        self,
        requests: SqlRequestRepository,
        users: UserRepository,
        works: WorkService,
        chaptarr: Callable[[], ChaptarrClient] | None,
        scan_library: Callable[[], Awaitable[None]],
    ) -> None:
        self._requests = requests
        self._users = users
        self._works = works
        self._chaptarr = chaptarr
        self._scan = scan_library

    @property
    def enabled(self) -> bool:
        return self._chaptarr is not None

    async def _premium(self, user_id: UUID) -> None:
        user = await self._users.get_by_id(user_id)
        if user is None or not user.has_premium:
            raise PremiumRequiredError

    async def request(self, user_id: UUID, work_id: UUID) -> tuple[BookRequest, bool]:
        """Records the request at once (and whether it is new); [fulfill] then asks Chaptarr."""
        await self._premium(user_id)
        if self._chaptarr is None:
            raise RequestsUnavailableError
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
        if self._chaptarr is None:
            return
        work = (await self._works.get(work_id)).work
        client = self._chaptarr()
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
        if not waiting or self._chaptarr is None:
            return items
        client = self._chaptarr()
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
