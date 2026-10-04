"""Catalog use cases, with in-memory caching of external data."""

import logging
import time
from collections import OrderedDict

from babel_api.domain.catalog import CoverImage, TrendingWork
from babel_api.domain.ports import CatalogSource, CoverSize

logger = logging.getLogger(__name__)


class CatalogService:
    """Trending works and covers. One instance is shared by every request.

    Trending data is refreshed at most every ``trending_ttl`` seconds; when the source is
    down, the last known list is served. Covers never change for a given id, so they are
    kept in a bounded LRU cache.
    """

    def __init__(
        self,
        source: CatalogSource,
        *,
        trending_ttl: float = 6 * 3600,
        max_cached_covers: int = 300,
    ) -> None:
        self._source = source
        self._trending_ttl = trending_ttl
        self._trending: list[TrendingWork] = []
        self._trending_at = float("-inf")
        self._covers: OrderedDict[tuple[int, str], CoverImage] = OrderedDict()
        self._max_covers = max_cached_covers

    async def trending(self, limit: int) -> list[TrendingWork]:
        now = time.monotonic()
        if now - self._trending_at > self._trending_ttl or len(self._trending) < limit:
            try:
                self._trending = await self._source.trending(max(limit, 24))
                self._trending_at = now
            except Exception:
                logger.warning("Trending works unavailable; serving the cached list", exc_info=True)
        return self._trending[:limit]

    async def cover(self, cover_id: int, size: CoverSize) -> CoverImage | None:
        key = (cover_id, size)
        if key in self._covers:
            self._covers.move_to_end(key)
            return self._covers[key]
        image = await self._source.cover(cover_id, size)
        if image is not None:
            self._covers[key] = image
            if len(self._covers) > self._max_covers:
                self._covers.popitem(last=False)
        return image
