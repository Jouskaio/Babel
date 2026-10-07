"""Audiobooks from the reader's Audiobookshelf (ADR 0013).

The reader links their Audiobookshelf once (an API key, or their password used once).
Babel lists its audiobooks, adds the chosen ones to the library (status, progress,
shelves, reviews, statistics like any book), streams them to the app, and keeps
Audiobookshelf's own progress in step. The app only ever talks to Babel.
"""

import hashlib
from collections.abc import AsyncIterator, Awaitable, Callable
from dataclasses import dataclass, replace
from datetime import UTC, datetime
from typing import TypeVar
from uuid import UUID

from babel_api.adapters.audiobookshelf import (
    AbsBook,
    AbsBookDetail,
    AbsClient,
    AbsError,
    AbsLibrary,
    AbsProgress,
    AbsTokens,
    AbsUnauthorizedError,
)
from babel_api.adapters.db.abs_repository import SqlAbsRepository
from babel_api.adapters.security.secrets import SecretBox
from babel_api.domain.audiobooks import AbsLink
from babel_api.domain.errors import NotFoundError
from babel_api.domain.files import AudioRef, Cover, LibraryItem
from babel_api.domain.ports import ChangeLog, CoverCache, FileRepository
from babel_api.domain.series import guess_series
from babel_api.domain.sync import ChangeOp, EntityKind
from babel_api.services.files import item_data

ClientFactory = Callable[[str], AbsClient]
T = TypeVar("T")


@dataclass(frozen=True, slots=True)
class BrowsedBook:
    book: AbsBook
    item_id: UUID | None  # in the reader's library already


@dataclass(frozen=True, slots=True)
class Playback:
    item: LibraryItem
    detail: AbsBookDetail
    remote: AbsProgress | None  # Audiobookshelf's own progress (other apps)


class AbsService:
    def __init__(
        self,
        links: SqlAbsRepository,
        files: FileRepository,
        changes: ChangeLog,
        secrets: SecretBox,
        covers: CoverCache,
        client: ClientFactory,
    ) -> None:
        self._links = links
        self._files = files
        self._changes = changes
        self._secrets = secrets
        self._covers = covers
        self._client = client

    # ------------------------------------------------------------ the link
    async def status(self, user_id: UUID) -> AbsLink | None:
        return await self._links.get(user_id)

    async def link(
        self,
        user_id: UUID,
        url: str,
        *,
        api_key: str | None = None,
        username: str | None = None,
        password: str | None = None,
    ) -> AbsLink:
        """Checks the server and the credentials, then keeps an API key or session tokens
        (never the password)."""
        client = self._client(url)
        try:
            await client.check()
            if api_key:
                tokens = AbsTokens(api_key.strip(), None, await client.me(api_key.strip()))
            elif username and password:
                tokens = await client.login(username.strip(), password)
            else:
                raise AbsError("credentials")
        finally:
            await client.aclose()
        link = AbsLink(
            user_id=user_id,
            base_url=client.base_url,
            username=tokens.username or (username or "").strip() or None,
            api_key=tokens.refresh is None,
            secret=self._seal(tokens),
            expired=False,
            updated_at=datetime.now(UTC),
        )
        await self._links.save(link)
        await self._links.commit()
        return link

    async def unlink(self, user_id: UUID) -> None:
        """Forgets the account; audiobooks already added stay in the library (data kept)."""
        await self._links.delete(user_id)
        await self._links.commit()

    def _seal(self, tokens: AbsTokens) -> str:
        return self._secrets.encrypt(
            tokens.access if tokens.refresh is None else f"{tokens.access}\n{tokens.refresh}"
        )

    async def _authed(self, user_id: UUID, call: Callable[[AbsClient, str], Awaitable[T]]) -> T:
        """Runs [call] with a valid token, refreshing the session once if it expired."""
        link = await self._links.get(user_id)
        if link is None:
            raise NotFoundError
        if link.expired:
            raise AbsError("expired")
        secret = self._secrets.decrypt(link.secret)
        access, _, refresh = secret.partition("\n")
        client = self._client(link.base_url)
        try:
            try:
                return await call(client, access)
            except AbsUnauthorizedError:
                if link.api_key or not refresh:
                    await self._expire(link)
                    raise AbsError("expired") from None
                try:
                    tokens = await client.refresh(refresh)
                except AbsUnauthorizedError:
                    await self._expire(link)
                    raise AbsError("expired") from None
                await self._links.save(
                    replace(link, secret=self._seal(tokens), updated_at=datetime.now(UTC))
                )
                await self._links.commit()
                return await call(client, tokens.access)
        finally:
            await client.aclose()

    async def _expire(self, link: AbsLink) -> None:
        await self._links.save(replace(link, expired=True, updated_at=datetime.now(UTC)))
        await self._links.commit()

    # ------------------------------------------------------------ browsing and adding
    async def libraries(self, user_id: UUID) -> list[AbsLibrary]:
        return await self._authed(user_id, lambda c, t: c.libraries(t))

    async def browse(
        self, user_id: UUID, library_id: str, query: str | None, page: int
    ) -> list[BrowsedBook]:
        books = await self._authed(user_id, lambda c, t: c.books(t, library_id, query, page, 50))
        found: list[BrowsedBook] = []
        for book in books:
            item = await self._files.find_audio_item(user_id, book.id)
            kept = item is not None and item.removed_at is None
            found.append(BrowsedBook(book, item.id if item and kept else None))
        return found

    async def add(
        self, user_id: UUID, remote_id: str, device_id: UUID | None = None
    ) -> LibraryItem:
        """Adds an audiobook to the library (or brings it back, with its data)."""
        existing = await self._files.find_audio_item(user_id, remote_id)
        if existing is not None:
            if existing.removed_at is None:
                return existing
            item = await self._files.restore_item(existing.id, datetime.now(UTC))
        else:
            detail = await self._authed(user_id, lambda c, t: c.book(t, remote_id))
            cover = await self._authed(user_id, lambda c, t: c.cover(t, remote_id))
            key = self._keep_cover(user_id, remote_id, cover)
            book = detail.book
            work = await self._files.guess_work(None, book.title, book.authors)
            guess = guess_series(book.title)
            item = await self._files.add_audio_item(
                user_id,
                book.title,
                book.authors,
                AudioRef(remote_id, book.duration, key),
                work,
                series=book.series or (guess.series if guess else None),
                series_index=guess.number if guess else None,
            )
        await self._changes.record(
            user_id,
            EntityKind.LIBRARY_ITEM,
            str(item.id),
            ChangeOp.UPSERT,
            item_data(item),
            device_id,
        )
        await self._files.commit()
        return item

    def _keep_cover(
        self, user_id: UUID, remote_id: str, cover: tuple[bytes, str] | None
    ) -> str | None:
        if cover is None:
            return None
        # Served without signing in, like file covers: the name cannot be guessed.
        key = hashlib.sha256(f"abs:{user_id}:{remote_id}".encode()).hexdigest()
        self._covers.put(key, Cover(cover[0], cover[1]))
        return key

    # ------------------------------------------------------------ listening
    async def _own_audio(self, user_id: UUID, item_id: UUID) -> tuple[LibraryItem, AudioRef]:
        item = await self._files.get_item(item_id)
        if item is None or item.user_id != user_id or item.audio is None:
            raise NotFoundError
        return item, item.audio

    async def playback(self, user_id: UUID, item_id: UUID) -> Playback:
        item, audio = await self._own_audio(user_id, item_id)
        detail = await self._authed(user_id, lambda c, t: c.book(t, audio.remote_id))
        remote = await self._authed(user_id, lambda c, t: c.progress(t, audio.remote_id))
        return Playback(item, detail, remote)

    async def stream(
        self, user_id: UUID, item_id: UUID, index: int, range_header: str | None
    ) -> tuple[int, dict[str, str], AsyncIterator[bytes]]:
        _, audio = await self._own_audio(user_id, item_id)
        detail = await self._authed(user_id, lambda c, t: c.book(t, audio.remote_id))
        if not 0 <= index < len(detail.tracks):
            raise NotFoundError
        track = detail.tracks[index]
        link = await self._links.get(user_id)
        if link is None:
            raise NotFoundError
        # The stream outlives this call: its own client, closed with the response.
        client = self._client(link.base_url)
        access = self._secrets.decrypt(link.secret).partition("\n")[0]
        status, headers, body = await client.stream(
            access, audio.remote_id, track.file_id, range_header
        )

        async def closing() -> AsyncIterator[bytes]:
            try:
                async for chunk in body:
                    yield chunk
            finally:
                await client.aclose()

        return status, headers, closing()

    async def save_progress(
        self, user_id: UUID, item_id: UUID, current_time: float, finished: bool
    ) -> None:
        """Keeps Audiobookshelf's own progress in step (for its other apps)."""
        _, audio = await self._own_audio(user_id, item_id)
        await self._authed(
            user_id,
            lambda c, t: c.save_progress(
                t, audio.remote_id, current_time, audio.duration, finished
            ),
        )
