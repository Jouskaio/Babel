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
from uuid import UUID

from babel_api.adapters.db.koreader_repository import SqlKoreaderRepository
from babel_api.domain.errors import NotFoundError
from babel_api.domain.koreader import partial_md5
from babel_api.domain.ports import BlobStore, FileRepository, UserRepository
from babel_api.domain.sync import DeviceKind, ReadingPosition
from babel_api.services.sync import SyncService

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
        item_id = await self._item_of(user_id, document)
        devices = await self._sync.devices(user_id)
        name = f"{DEVICE_PREFIX}{device.strip() or 'e-reader'}"[:80]
        found = next((d for d in devices if d.name == name), None)
        device_id = (
            found.id
            if found
            else (await self._sync.register_device(user_id, name, DeviceKind.EREADER)).id
        )
        await self._sync.record_position(
            user_id,
            device_id,
            item_id,
            f"{PREFIX}{progress}"[:1000],
            round(max(0.0, min(1.0, percentage)) * 100, 2),
        )

    async def get(self, user_id: UUID, document: str) -> tuple[ReadingPosition, str, str] | None:
        """The latest position of the book on any device, with KOReader's own position string
        (empty when it did not come from KOReader) and the device's name."""
        item_id = await self._item_of(user_id, document)
        positions = await self._sync.positions(user_id, item_id)
        if not positions:
            return None
        latest = max(positions, key=lambda p: p.client_time)
        names = {d.id: d.name for d in await self._sync.devices(user_id)}
        progress = latest.locator[len(PREFIX) :] if latest.locator.startswith(PREFIX) else ""
        return latest, progress, names.get(latest.device_id, "")

    # ------------------------------------------------------------ KOReader's identifier of a file
    async def _item_of(self, user_id: UUID, document: str) -> UUID:
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
            raise NotFoundError
        return by_sha[sha].id
