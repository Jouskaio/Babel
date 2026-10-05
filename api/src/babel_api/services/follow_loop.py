"""The daily follow-up of unfinished works, run inside the API process."""

import asyncio
import logging
from collections.abc import Callable
from contextlib import AbstractAsyncContextManager
from datetime import timedelta
from typing import Any

from babel_api.domain.errors import SourceRateLimitedError
from babel_api.services.follows import FollowService

logger = logging.getLogger(__name__)

# Works checked per round; rounds run every hour, each work once per interval.
BATCH = 50
ROUND = timedelta(hours=1)


async def check_due_follows(
    services: Callable[[], AbstractAsyncContextManager[FollowService]], interval: timedelta
) -> int:
    """Checks the works not checked for ``interval``; returns how many were checked."""
    async with services() as follows:
        due = await follows.due(interval, BATCH)
    checked = 0
    for follow in due:
        # One session per work: a failing one does not spoil the others.
        async with services() as follows:
            try:
                await follows.check(follow)
            except SourceRateLimitedError:
                logger.info("AO3 asked for a pause: follow-up resumes next round")
                break
            except Exception:
                logger.exception("Follow-up of work %s failed", follow.ref)
        checked += 1
    return checked


async def follow_forever(
    services: Callable[[], AbstractAsyncContextManager[FollowService]],
    interval: timedelta,
    *,
    first_delay: float = 60.0,
    sleep: Callable[[float], Any] = asyncio.sleep,
) -> None:
    await sleep(first_delay)  # let the API start first
    while True:
        try:
            checked = await check_due_follows(services, interval)
            if checked:
                logger.info("Follow-up: %s work(s) checked", checked)
        except Exception:
            logger.exception("Follow-up round failed")
        await sleep(ROUND.total_seconds())
