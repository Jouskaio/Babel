"""Progress sync with KOReader (the "kosync" protocol): read on an e-reader, resume anywhere.

KOReader asks a server for the position of a book by its own identifier of the file (see
[domain.koreader]); here that is found among the reader's library, the identifiers being worked
out once per file. What KOReader pushes becomes a reading position of an e-reader device named
"KOReader · <its name>", so it syncs like any other device. Only the percentage is shared across
apps: KOReader's own position (an XPointer) is kept to give back to KOReader itself.
"""

import asyncio
import hashlib
import logging
import secrets
from collections.abc import Awaitable, Callable
from dataclasses import dataclass
from datetime import UTC, date, datetime
from pathlib import PurePosixPath
from typing import Any
from uuid import NAMESPACE_URL, UUID, uuid5

from babel_api.adapters.db.koreader_repository import (
    KoreaderContact,
    OrphanProgress,
    RecentSync,
    SqlKoreaderRepository,
    UnknownBook,
)
from babel_api.domain.errors import NotFoundError
from babel_api.domain.koreader import partial_md5
from babel_api.domain.naming import book_filename
from babel_api.domain.ports import BlobStore, FileRepository, UserRepository
from babel_api.domain.sync import ChangeOp, DeviceKind, EntityKind, ReadingPosition
from babel_api.services.sync import Operation, OpOutcome, SyncService


@dataclass(frozen=True, slots=True)
class KoreaderStatus:
    contact: KoreaderContact
    devices: list[tuple[str, datetime]]
    recent: list[RecentSync]
    unknown_books: int = 0
    stats_at: datetime | None = None
    stats_books: int = 0
    stats_seconds: int = 0
    ereader_books: int = 0
    # The parts of this state that could not be worked out (and why), instead of no state at all.
    problems: tuple[str, ...] = ()


logger = logging.getLogger(__name__)

PREFIX = "koreader:"
STATS_PREFIX = "koreader-stats:"
DEVICE_PREFIX = "KOReader · "


class KoreaderService:
    def __init__(
        self,
        repo: SqlKoreaderRepository,
        users: UserRepository,
        files: FileRepository,
        store: BlobStore,
        sync: SyncService,
    ) -> None:
        self._repo = repo
        self._users = users
        self._files = files
        self._store = store
        self._sync = sync

    # ------------------------------------------------------------ the reader's key
    async def new_password(self, user_id: UUID) -> str:
        """A password for KOReader, shown once; only its md5 (what KOReader sends) is kept."""
        password = secrets.token_urlsafe(9)
        await self._repo.set_key(
            user_id, hashlib.md5(password.encode(), usedforsecurity=False).hexdigest()
        )
        await self._repo.commit()
        return password

    async def username(self, user_id: UUID) -> str:
        user = await self._users.get_by_id(user_id)
        if user is None:
            raise NotFoundError
        return user.email

    async def has_password(self, user_id: UUID) -> bool:
        return await self._repo.key(user_id) is not None

    async def authenticate(self, username: str, key: str) -> UUID | None:
        """The reader whose e-mail and KOReader password these are, if any."""
        user = await self._users.get_by_email(username.strip().lower())
        stored = await self._repo.key(user.id) if user else None
        if (
            user is None
            or stored is None
            or not secrets.compare_digest(stored, key.strip().lower())
        ):
            return None
        await self._repo.mark(user.id)
        await self._repo.commit()
        return user.id

    # ------------------------------------------------------------ progress
    async def put(
        self,
        user_id: UUID,
        document: str,
        progress: str,
        percentage: float,
        device: str,
    ) -> None:
        try:
            item_id = await self._item_of_marked(user_id, document)
        except NotFoundError:
            # Not a book of this library (yet): kept anyway, so KOReader sees no error and a
            # second e-reader can get the position back.
            await self._repo.put_orphan(user_id, document, progress, percentage, device, "")
            await self._repo.commit()
            return
        device_id = await self._device_id(user_id, device)
        # The first time the e-reader reports this book, it is on the e-reader.
        before = await self._sync.positions(user_id, item_id)
        if not any(p.locator.startswith(PREFIX) for p in before):
            await self._sync.mark_ereader(user_id, item_id)
        await self._sync.record_position(
            user_id,
            device_id,
            item_id,
            f"{PREFIX}{progress}"[:1000],
            round(max(0.0, min(1.0, percentage)) * 100, 2),
        )

    async def _device_id(self, user_id: UUID, device: str) -> UUID:
        """The e-reader as a device of the reader, made the first time it is seen."""
        name = f"{DEVICE_PREFIX}{device.strip() or 'e-reader'}"[:80]
        found = next((d for d in await self._sync.devices(user_id) if d.name == name), None)
        if found:
            return found.id
        return (await self._sync.register_device(user_id, name, DeviceKind.EREADER)).id

    async def seen(self, user_id: UUID, device: str) -> None:
        """Anything the plugin does counts as the e-reader being connected."""
        if device.strip():
            await self._sync.touch_device(user_id, await self._device_id(user_id, device))

    async def finished(self, user_id: UUID, document: str, device: str) -> bool:
        """The reader finished the book on the e-reader: it is finished in Babel too."""
        try:
            item_id = await self._item_of(user_id, document)
        except NotFoundError:
            return False
        now = datetime.now(UTC)
        results, _ = await self._sync.push(
            user_id,
            await self._device_id(user_id, device),
            [
                Operation(
                    key=f"koreader-finished:{item_id}:{now.date()}",
                    entity=EntityKind.READING_STATE,
                    entity_id=str(item_id),
                    op=ChangeOp.UPSERT,
                    data={"status": "finished", "client_time": now.isoformat()},
                )
            ],
        )
        return any(r.outcome is OpOutcome.APPLIED for r in results)

    async def annotations(
        self, user_id: UUID, document: str, device: str, found: list[dict[str, Any]]
    ) -> int:
        """Highlights and notes made in KOReader become the reader's annotations in Babel."""
        try:
            item_id = await self._item_of(user_id, document)
        except NotFoundError:
            return 0
        item = await self._files.get_item(item_id)
        if item is None or item.sha256 is None:
            return 0
        operations: list[Operation] = []
        for note in found:
            quote = str(note.get("text") or "").strip()
            if not quote:
                continue
            when = str(note.get("datetime") or "")
            made = datetime.fromisoformat(when.replace(" ", "T")) if when else datetime.now(UTC)
            if made.tzinfo is None:
                made = made.replace(tzinfo=UTC)
            percent = note.get("percent")
            annotation_id = uuid5(NAMESPACE_URL, f"koreader:{user_id}:{item.sha256}:{quote}")
            operations.append(
                Operation(
                    key=f"koreader-annotation:{annotation_id}:{made.isoformat()}",
                    entity=EntityKind.ANNOTATION,
                    entity_id=str(annotation_id),
                    op=ChangeOp.UPSERT,
                    data={
                        "item_id": str(item_id),
                        "chapter": 0,
                        "quote": quote,
                        "note": str(note.get("note") or "").strip() or None,
                        "color": "gold",
                        "visibility": "private",
                        "client_time": made.isoformat(),
                        "percent": percent if isinstance(percent, int | float) else None,
                    },
                )
            )
        if not operations:
            return 0
        results, _ = await self._sync.push(
            user_id, await self._device_id(user_id, device), operations
        )
        return sum(1 for r in results if r.outcome is OpOutcome.APPLIED)

    async def get(self, user_id: UUID, document: str) -> tuple[ReadingPosition, str, str] | None:
        """The latest position of the book on any device, with KOReader's own position string
        (empty when it did not come from KOReader) and the device's name."""
        item_id = await self._item_of_marked(user_id, document)
        positions = await self._sync.positions(user_id, item_id)
        if not positions:
            return None
        # What the e-reader itself sent: a position worked out from statistics means nothing to it.
        positions = [p for p in positions if not p.locator.startswith(STATS_PREFIX)]
        if not positions:
            return None
        latest = max(positions, key=lambda p: p.client_time)
        names = {d.id: d.name for d in await self._sync.devices(user_id)}
        progress = latest.locator[len(PREFIX) :] if latest.locator.startswith(PREFIX) else ""
        return latest, progress, names.get(latest.device_id, "")

    async def put_stats(
        self,
        user_id: UUID,
        books: list[dict[str, object]],
        days: list[tuple[str, date, int, int]],
        device: str = "",
    ) -> None:
        """Reading statistics sent by KOReader's Babel plugin."""
        seen = {row.md5 for row in await self._repo.stat_books(user_id)}
        await self._repo.save_stats(user_id, books, days)
        for book in books:
            md5 = str(book["md5"])
            try:
                item_id = await self._item_of(user_id, md5)
            except NotFoundError:
                continue
            if md5 not in seen:
                # A book the e-reader reports for the first time, and Babel has: it is on it.
                await self._sync.mark_ereader(user_id, item_id)
            if int(str(book.get("total_read_time") or 0)) > 0:
                await self._sync.start_reading(user_id, item_id)
            reached = book.get("progress")
            if isinstance(reached, int | float) and reached > 0 and device.strip():
                await self._position_from_stats(user_id, item_id, device, float(reached) * 100)
        await self._repo.mark(user_id)
        await self._repo.commit()
        await self.adopt_quietly(user_id)

    async def orphan(self, user_id: UUID, document: str) -> OrphanProgress | None:
        """What KOReader last sent for a book Babel does not have."""
        return await self._repo.get_orphan(user_id, document)

    # ------------------------------------------------------------ what the reader can check
    async def status(self, user_id: UUID) -> "KoreaderStatus":
        """Whether KOReader has called, which books it synced last, and its devices. Each part
        is worked out on its own: one that fails is reported in ``problems`` and the rest still
        answer."""
        problems: list[str] = []

        async def part[T](name: str, work: Callable[[], Awaitable[T]], fallback: T) -> T:
            try:
                return await work()
            except Exception as error:
                logger.exception("KOReader status: %s failed", name)
                problems.append(f"{name}: {type(error).__name__}")
                await self._repo.rollback()
                return fallback

        async def devices() -> list[tuple[str, datetime]]:
            return [
                (d.name[len(DEVICE_PREFIX) :], d.last_seen_at)
                for d in await self._sync.devices(user_id)
                if d.name.startswith(DEVICE_PREFIX)
            ]

        async def on_ereader() -> int:
            return sum(
                1 for i in await self._files.list_items(user_id) if i.file is not None and i.ereader
            )

        stats = await part("statistics", lambda: self._repo.stats_overview(user_id), (None, 0, 0))
        return KoreaderStatus(
            stats_at=stats[0],
            stats_books=stats[1],
            stats_seconds=stats[2],
            contact=await part(
                "contact", lambda: self._repo.contact(user_id), KoreaderContact(None, None)
            ),
            devices=await part("devices", devices, []),
            recent=await part("recent", lambda: self._repo.recent(user_id), []),
            unknown_books=await part("unknown", lambda: self._unknown_count(user_id), 0),
            ereader_books=await part("ereader", on_ereader, 0),
            problems=tuple(problems),
        )

    async def _unknown_count(self, user_id: UUID) -> int:
        try:
            return len(await self.unknown(user_id))
        except Exception:
            logger.exception("KOReader: could not list the unknown books")
            return await self._repo.orphan_count(user_id)

    async def identifiers(self, shas: list[str]) -> dict[str, str]:
        """KOReader's identifier (partial md5) of each stored file, worked out once and kept."""
        by_sha = {sha: md5 for md5, sha in (await self._repo.hashes(shas)).items()}
        for sha in set(shas) - set(by_sha):
            path = self._store.path(sha)
            if path is None:
                continue
            try:
                md5 = await asyncio.to_thread(partial_md5, path)
            except OSError:
                continue
            await self._repo.save_hash(sha, md5)
            by_sha[sha] = md5
        await self._repo.commit()
        return by_sha

    async def _position_from_stats(
        self, user_id: UUID, item_id: UUID, device: str, percent: float
    ) -> None:
        """Where the last reading session ended is where the reader is, when the e-reader sent
        no position of its own: Babel shows the progress and opens the book there."""
        device_id = await self._device_id(user_id, device)
        mine = [p for p in await self._sync.positions(user_id, item_id) if p.device_id == device_id]
        if any(p.locator.startswith(PREFIX) for p in mine):
            return  # the e-reader's own position is better
        if mine and abs(mine[0].percent - percent) < 0.5:
            return
        await self._sync.record_position(
            user_id, device_id, item_id, STATS_PREFIX, round(max(0.0, min(100.0, percent)), 2)
        )

    async def book_stats(self, user_id: UUID, item_id: UUID) -> tuple[int, int, datetime | None]:
        """What the e-reader's statistics say about a library book: seconds, pages, last opened."""
        item = await self._files.get_item(item_id)
        if item is None or item.user_id != user_id:
            raise NotFoundError
        if item.sha256 is None:
            return 0, 0, None
        return await self._repo.book_totals(user_id, list(await self._repo.hashes([item.sha256])))

    async def adopt_quietly(self, user_id: UUID) -> None:
        """[adopt], where a failure must not break what the plugin was doing."""
        try:
            await self.adopt(user_id)
        except Exception:
            logger.exception("KOReader: could not adopt the kept positions")
            await self._repo.rollback()

    async def adopt(self, user_id: UUID) -> int:
        """Positions kept for books Babel did not have, whose book has come since (sent from the
        e-reader, imported…): they become reading positions of that book."""
        adopted = 0
        for orphan in await self._repo.orphans(user_id):
            try:
                await self._item_of(user_id, orphan.document)
            except NotFoundError:
                continue
            await self.put(
                user_id,
                orphan.document,
                orphan.progress,
                orphan.percentage,
                orphan.device,
            )
            await self._repo.drop_orphan(user_id, orphan.document)
            adopted += 1
        if adopted:
            await self._repo.commit()
        return adopted

    async def missing(self, user_id: UUID, documents: list[str]) -> list[str]:
        """Which of the e-reader's books (by KOReader's identifier) the library does not have."""
        lost: list[str] = []
        ignored = await self._repo.ignored(user_id)
        for document in dict.fromkeys(documents):
            if document in ignored:
                continue
            try:
                await self._item_of(user_id, document)
            except NotFoundError:
                lost.append(document)
        return lost

    async def unknown(self, user_id: UUID) -> list[UnknownBook]:
        """The books KOReader reported (position or statistics) that match no library book."""
        found: dict[str, UnknownBook] = {}
        for stat in await self._repo.stat_books(user_id):
            found[stat.md5] = UnknownBook(stat.md5, stat.title, stat.authors, None, "", None)
        for row in await self._repo.orphans(user_id):
            before = found.get(row.document)
            found[row.document] = UnknownBook(
                row.document,
                before.title if before else "",
                before.authors if before else "",
                row.percentage,
                row.device,
                row.updated_at,
            )
        missing: list[UnknownBook] = []
        for book in found.values():
            try:
                await self._item_of(user_id, book.md5)
            except NotFoundError:
                missing.append(book)
        return sorted(missing, key=lambda b: (b.title or "~", b.md5))

    async def forget(self, user_id: UUID, document: str) -> None:
        """Drops a book of the e-reader Babel could not match: its position and statistics go,
        and what KOReader sends of it later is ignored."""
        await self._repo.ignore(user_id, document)
        await self._repo.commit()

    async def link(self, user_id: UUID, document: str, item_id: UUID) -> None:
        """Ties a KOReader book to a library book; a position already sent is carried over."""
        if not any(
            i.id == item_id and i.removed_at is None for i in await self._files.list_items(user_id)
        ):
            raise NotFoundError
        await self._repo.link(user_id, document, item_id)
        orphan = await self._repo.get_orphan(user_id, document)
        await self._repo.drop_orphan(user_id, document)
        await self._repo.commit()
        if orphan is not None:
            await self.put(user_id, document, orphan.progress, orphan.percentage, orphan.device)

    async def _item_of_marked(self, user_id: UUID, document: str) -> UUID:
        try:
            return await self._item_of(user_id, document)
        except NotFoundError:
            # KOReader asked for a book Babel does not have: remembered, so the reader can be told.
            await self._repo.mark(user_id, unmatched=True)
            await self._repo.commit()
            raise

    # ------------------------------------------------------------ KOReader's identifier of a file
    async def _item_of(self, user_id: UUID, document: str) -> UUID:
        if (tied := await self._repo.linked(user_id, document)) is not None:
            return tied
        items = [
            i for i in await self._files.list_items(user_id) if i.sha256 and i.removed_at is None
        ]
        by_sha = {i.sha256: i for i in items if i.sha256}
        known = await self._repo.hashes(list(by_sha))
        if document not in known:
            for sha in by_sha.keys() - set(known.values()):
                path = self._store.path(sha)
                if path is None:
                    continue
                try:
                    md5 = await asyncio.to_thread(partial_md5, path)
                except OSError:
                    continue  # a file the store lost: the others still match
                await self._repo.save_hash(sha, md5)
                known[md5] = sha
            await self._repo.commit()
        sha = known.get(document)
        if sha is None or sha not in by_sha:
            # KOReader can also name a book by the md5 of its file name ("Filename" matching).
            for item in items:
                names = (
                    {PurePosixPath(item.file.original_name).name, book_filename(item)}
                    if item.file
                    else set[str]()
                )
                if any(
                    hashlib.md5(name.encode(), usedforsecurity=False).hexdigest() == document
                    for name in names
                    if name
                ):
                    return item.id
            raise NotFoundError
        return by_sha[sha].id
