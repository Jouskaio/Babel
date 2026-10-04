import asyncio

from babel_api.domain.catalog import CoverImage, TrendingWork
from babel_api.domain.ports import CoverSize
from babel_api.services.catalog import CatalogService


def work(n: int) -> TrendingWork:
    return TrendingWork(work_id=f"OL{n}W", title=f"Book {n}", authors=("A",), cover_id=n)


class FakeSource:
    def __init__(self) -> None:
        self.trending_calls = 0
        self.cover_calls = 0
        self.fail = False

    async def trending(self, limit: int) -> list[TrendingWork]:
        self.trending_calls += 1
        if self.fail:
            raise RuntimeError("source down")
        return [work(n) for n in range(1, limit + 1)]

    async def cover(self, cover_id: int, size: CoverSize) -> CoverImage | None:
        self.cover_calls += 1
        return None if cover_id == 404 else CoverImage(f"{cover_id}{size}".encode(), "image/jpeg")


def test_trending_is_cached() -> None:
    source = FakeSource()
    service = CatalogService(source)

    first = asyncio.run(service.trending(12))
    second = asyncio.run(service.trending(6))

    assert len(first) == 12
    assert second == first[:6]
    assert source.trending_calls == 1


def test_the_last_known_list_is_served_when_the_source_fails() -> None:
    source = FakeSource()
    service = CatalogService(source, trending_ttl=0)
    known = asyncio.run(service.trending(5))

    source.fail = True

    assert asyncio.run(service.trending(5)) == known


def test_trending_is_empty_when_the_source_never_answered() -> None:
    source = FakeSource()
    source.fail = True
    assert asyncio.run(CatalogService(source).trending(5)) == []


def test_covers_are_cached_with_a_bounded_size() -> None:
    source = FakeSource()
    service = CatalogService(source, max_cached_covers=2)

    async def scenario() -> None:
        await service.cover(1, "M")
        await service.cover(1, "M")
        await service.cover(2, "M")
        await service.cover(3, "M")  # evicts cover 1
        await service.cover(1, "M")

    asyncio.run(scenario())

    assert source.cover_calls == 4


def test_missing_covers_are_not_cached() -> None:
    source = FakeSource()
    service = CatalogService(source)

    assert asyncio.run(service.cover(404, "M")) is None
    assert asyncio.run(service.cover(404, "M")) is None
    assert source.cover_calls == 2
