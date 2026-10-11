"""Daily refresh of what comes from outside: Pagebound readers, playlists and prize lists.

Everything else (ratings, adaptations) is read when a book is opened and kept a day. These need
a nudge: a Pagebound reader's new books arrive without them asking, and the playlists and prize
lists the challenges rely on are read again, so the first reader of the day does not wait.
"""

import asyncio
import logging
from collections.abc import Callable
from typing import Any

from babel_api.api.dependencies import (
    Container,
    link_covers,
    make_pagebound_service,
)
from babel_api.domain.challenges import PRIZES
from babel_api.domain.playlists import PLAYLISTS
from babel_api.services.works import WorkService

logger = logging.getLogger(__name__)

EVERY = 24 * 3600.0


async def refresh_pagebound(container: Container) -> int:
    """Imports again the books and reviews of every linked Pagebound reader (the ones the
    library already has are skipped); returns how many readers were looked at."""
    async with container.sessions() as session:
        readers = await make_pagebound_service(container, session).linked_readers()
    for user_id in readers:
        try:
            async with container.sessions() as session:
                result = await make_pagebound_service(container, session).import_reviews(user_id)
            if result.imported:
                await link_covers(container, user_id)
        except Exception:  # one reader's failure must not spoil the others
            logger.warning("Pagebound refresh failed for %s", user_id, exc_info=True)
    return len(readers)


async def refresh_catalogs(container: Container, works: Callable[[Any], WorkService]) -> None:
    """Reads the playlists and the prize lists again."""
    async with container.sessions() as session:
        service = works(session)
        for key in PLAYLISTS:
            try:
                await service.playlist(key, refresh=True)
            except Exception:
                logger.info("Playlist %s not refreshed", key)
    if container.wikidata is not None:
        for qid in PRIZES.values():
            await container.wikidata.laureates(qid, refresh=True)


async def refresh_forever(
    container: Container,
    works: Callable[[Any], WorkService],
    *,
    first_delay: float = 300.0,
    sleep: Callable[[float], Any] = asyncio.sleep,
) -> None:
    await sleep(first_delay)  # let the API start first
    while True:
        try:
            await refresh_catalogs(container, works)
            await refresh_pagebound(container)
        except Exception:
            logger.exception("Daily refresh failed")
        await sleep(EVERY)
