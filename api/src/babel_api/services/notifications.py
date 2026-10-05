"""Notifications sent to the reader's devices (new chapters of a followed work)."""

import logging
from uuid import UUID

from babel_api.domain.ports import Pusher, SyncRepository, UserRepository

logger = logging.getLogger(__name__)

_NEW_CHAPTERS = {
    "fr": ("Nouveau chapitre", "{title} · {chapters} chapitres"),
    "en": ("New chapter", "{title} · {chapters} chapters"),
}


class Notifier:
    def __init__(self, sync: SyncRepository, users: UserRepository, pusher: Pusher) -> None:
        self._sync = sync
        self._users = users
        self._pusher = pusher

    async def new_chapters(
        self, user_id: UUID, item_id: UUID, title: str, chapters: str | None
    ) -> int:
        """Tells every device of the reader; returns how many were reached."""
        user = await self._users.get_by_id(user_id)
        heading, body = _NEW_CHAPTERS.get(user.locale if user else "fr", _NEW_CHAPTERS["fr"])
        text = body.format(title=title, chapters=chapters or "?")
        data = {"kind": "new_chapters", "item_id": str(item_id)}
        sent = 0
        for device in await self._sync.list_devices(user_id):
            if not device.push_token:
                continue
            try:
                if await self._pusher.send(device.push_token, heading, text, data):
                    sent += 1
                else:
                    await self._sync.set_push_token(device.id, None)
            except Exception:  # a notification must never break the follow-up
                logger.warning("Push to device %s failed", device.id, exc_info=True)
        await self._sync.commit()
        return sent
