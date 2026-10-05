"""Following unfinished AO3 works: new chapters land in the library by themselves.

Once a day each followed work's page is read (one request, at AO3's pace). When its
chapters or update date changed, the new EPUB replaces the file of the same library item:
reading positions and annotations stay with the book, and every device gets the new
version through sync. A finished work stops being followed.
"""

import logging
from dataclasses import replace
from datetime import UTC, datetime, timedelta
from typing import Protocol
from uuid import UUID, uuid4

from babel_api.adapters.sources.ao3 import Ao3Connector
from babel_api.domain.errors import NotFoundError, SourceConnectionError, SourceRateLimitedError
from babel_api.domain.files import LibraryItem
from babel_api.domain.follows import Follow, is_complete
from babel_api.domain.ports import FileRepository, SyncRepository
from babel_api.domain.sources import RemoteEntry
from babel_api.domain.sync import ChangeOp, EntityKind
from babel_api.services.files import FileService
from babel_api.services.notifications import Notifier

logger = logging.getLogger(__name__)


class FollowRepository(Protocol):
    async def save(self, follow: Follow) -> Follow: ...
    async def get(self, follow_id: UUID) -> Follow | None: ...
    async def list_follows(self, user_id: UUID) -> list[Follow]: ...
    async def due(self, checked_before: datetime, limit: int) -> list[Follow]: ...
    async def delete(self, follow_id: UUID) -> None: ...
    async def commit(self) -> None: ...


def ao3_chapters(entry: RemoteEntry) -> str | None:
    """The chapter count in an AO3 version id ("<work>:<chapters>|<date>")."""
    if ":" not in entry.remote_id:
        return None
    return entry.remote_id.split(":", 1)[1].split("|", 1)[0] or None


class FollowService:
    def __init__(
        self,
        follows: FollowRepository,
        files: FileRepository,
        library: FileService,
        sync: SyncRepository,
        ao3: Ao3Connector,
        notifier: Notifier | None = None,
    ) -> None:
        self._follows = follows
        self._files = files
        self._library = library
        self._sync = sync
        self._ao3 = ao3
        self._notifier = notifier

    async def follow_ao3(
        self, item: LibraryItem, work_id: str, url: str, entry: RemoteEntry
    ) -> Follow | None:
        """Follows a work just imported by link, unless it is finished."""
        chapters = ao3_chapters(entry)
        if is_complete(chapters):
            return None
        return await self._follows.save(
            Follow(
                id=uuid4(),
                user_id=item.user_id,
                item_id=item.id,
                kind="ao3",
                ref=work_id,
                url=url,
                version=entry.remote_id,
                chapters=chapters,
                complete=False,
                created_at=datetime.now(UTC),
                last_checked_at=datetime.now(UTC),
            )
        )

    async def list_follows(self, user_id: UUID) -> list[Follow]:
        return await self._follows.list_follows(user_id)

    async def stop(self, user_id: UUID, follow_id: UUID) -> None:
        await self._own(user_id, follow_id)
        await self._follows.delete(follow_id)
        await self._follows.commit()

    async def check_now(self, user_id: UUID, follow_id: UUID) -> Follow:
        return await self.check(await self._own(user_id, follow_id))

    async def check(self, follow: Follow) -> Follow:
        """Looks for new chapters and imports them. A rate limit is raised to the caller."""
        now = datetime.now(UTC)
        try:
            entry = await self._ao3.work(follow.ref)
        except SourceRateLimitedError:
            raise
        except SourceConnectionError as error:
            return await self._saved(follow, last_checked_at=now, last_error=str(error)[:200])
        chapters = ao3_chapters(entry)
        updated: LibraryItem | None = None
        if entry.remote_id != follow.version:
            item = await self._files.get_item(follow.item_id)
            if item is None:  # removed from the library meanwhile
                await self._follows.delete(follow.id)
                await self._follows.commit()
                return follow
            if await self._update_book(item, entry):
                updated = item
            logger.info("New version of AO3 work %s (%s)", follow.ref, chapters)
        saved = await self._saved(
            follow,
            version=entry.remote_id,
            chapters=chapters,
            complete=is_complete(chapters),
            last_checked_at=now,
            last_error=None,
            updated_at=now if updated else None,
        )
        if updated is not None and self._notifier is not None:
            await self._notifier.new_chapters(
                updated.user_id, updated.id, entry.title or updated.title, chapters
            )
        return saved

    async def _update_book(self, item: LibraryItem, entry: RemoteEntry) -> bool:
        """Brings the new version into the library; False when the file did not change."""
        chunks = self._ao3.fetch({"username": ""}, None, entry)
        name = f"{entry.title}.epub" if entry.title else "work.epub"
        stored, path, _ = await self._library.store(item.user_id, chunks, name)
        old_sha256 = item.file.sha256
        if stored.sha256 == old_sha256:
            return False
        await self._library.replace_file(item, stored, path)
        # Annotations follow the book to its new file (devices learn it through sync).
        for annotation in await self._sync.move_annotations(
            item.user_id, old_sha256, stored.sha256, item.id
        ):
            await self._sync.record(
                item.user_id,
                EntityKind.ANNOTATION,
                str(annotation.id),
                ChangeOp.UPSERT,
                annotation.as_data(),
            )
        return True

    async def _saved(
        self,
        follow: Follow,
        *,
        last_checked_at: datetime,
        last_error: str | None,
        version: str | None = None,
        chapters: str | None = None,
        complete: bool | None = None,
        updated_at: datetime | None = None,
    ) -> Follow:
        saved = await self._follows.save(
            replace(
                follow,
                version=version or follow.version,
                chapters=chapters or follow.chapters,
                complete=follow.complete if complete is None else complete,
                last_checked_at=last_checked_at,
                last_error=last_error,
                updated_at=updated_at or follow.updated_at,
            )
        )
        await self._follows.commit()
        return saved

    async def _own(self, user_id: UUID, follow_id: UUID) -> Follow:
        follow = await self._follows.get(follow_id)
        if follow is None or follow.user_id != user_id:
            raise NotFoundError
        return follow

    async def due(self, interval: timedelta, limit: int) -> list[Follow]:
        return await self._follows.due(datetime.now(UTC) - interval, limit)
