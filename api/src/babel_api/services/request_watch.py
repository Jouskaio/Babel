"""Watches the requested books, so a finished download reaches Kavita at once.

Requests are checked when a reader opens their list; this does it every minute for everyone, so
that Kavita is asked to scan as soon as a download is done, whether or not anyone is looking.
"""

import asyncio
import logging
from collections.abc import Callable
from contextlib import AbstractAsyncContextManager
from typing import Any

from babel_api.services.requests import RequestService

logger = logging.getLogger(__name__)

EVERY = 60.0  # seconds


async def check_requests(
    services: Callable[[], AbstractAsyncContextManager[RequestService]],
) -> int:
    """Refreshes the requests of every reader with one waiting; returns how many readers."""
    async with services() as requests:
        users = await requests.users_waiting()
    for user_id in users:
        # One session per reader: a failing one does not spoil the others. Listing refreshes
        # the requests (progress, arrival) and asks Kavita to scan when a book has arrived.
        async with services() as requests:
            try:
                await requests.list(user_id)
            except Exception:
                logger.exception("Checking the requests of a reader failed")
    return len(users)


async def watch_forever(
    services: Callable[[], AbstractAsyncContextManager[RequestService]],
    *,
    first_delay: float = 45.0,
    sleep: Callable[[float], Any] = asyncio.sleep,
) -> None:
    await sleep(first_delay)  # let the API start first
    while True:
        try:
            await check_requests(services)
        except Exception:
            logger.exception("Request watch round failed")
        await sleep(EVERY)
