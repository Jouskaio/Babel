"""Progress sync with KOReader (the "kosync" protocol): read on an e-reader, resume anywhere.

KOReader asks a server for the position of a book by its own identifier of the file (see
[domain.koreader]); here that is found among the reader's library, the identifiers being worked
out once per file. What KOReader pushes becomes a reading position of an e-reader device named
"KOReader · <its name>", so it syncs like any other device. Only the percentage is shared across
apps: KOReader's own position (an XPointer) is kept to give back to KOReader itself.
"""

import asyncio
import hashlib
import secrets
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


PREFIX = "koreader:"
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
        latest = max(positions, key=lambda p: p.client_time)
        names = {d.id: d.name for d in await self._sync.devices(user_id)}
        progress = latest.locator[len(PREFIX) :] if latest.locator.startswith(PREFIX) else ""
        return latest, progress, names.get(latest.device_id, "")

    async def put_stats(
        self, user_id: UUID, books: list[dict[str, object]], days: list[tuple[str, date, int, int]]
    ) -> None:
        """Reading statistics sent by KOReader's Babel plugin."""
        seen = {row.md5 for row in await self._repo.stat_books(user_id)}
        await self._repo.save_stats(user_id, books, days)
        for md5 in {str(b["md5"]) for b in books} - seen:
            # A book the e-reader reports for the first time, and Babel has: it is on it.
            try:
                await self._sync.mark_ereader(user_id, await self._item_of(user_id, md5))
            except NotFoundError:
                continue
        await self._repo.mark(user_id)
        await self._repo.commit()

    async def orphan(self, user_id: UUID, document: str) -> OrphanProgress | None:
        """What KOReader last sent for a book Babel does not have."""
        return await self._repo.get_orphan(user_id, document)

    # ------------------------------------------------------------ what the reader can check
    async def status(self, user_id: UUID) -> "KoreaderStatus":
        """Whether KOReader has called, which books it synced last, and its devices."""
        devices = [d for d in await self._sync.devices(user_id) if d.name.startswith(DEVICE_PREFIX)]
        stats_at, stats_books, stats_seconds = await self._repo.stats_overview(user_id)
        return KoreaderStatus(
            stats_at=stats_at,
            stats_books=stats_books,
            stats_seconds=stats_seconds,
            contact=await self._repo.contact(user_id),
            devices=[(d.name[len(DEVICE_PREFIX) :], d.last_seen_at) for d in devices],
            recent=await self._repo.recent(user_id),
            unknown_books=await self._repo.orphan_count(user_id),
        )

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
                md5 = await asyncio.to_thread(partial_md5, path)
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
