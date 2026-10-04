"""Open Library: trending works and cover images (https://openlibrary.org/developers/api)."""

import httpx

from babel_api.domain.catalog import CoverImage, TrendingWork
from babel_api.domain.ports import CoverSize

_USER_AGENT = "Babel/1.0 (https://babel.jouskaio.me)"


class OpenLibrarySource:
    """Reads Open Library over HTTP. Failures surface as ``httpx.HTTPError``."""

    def __init__(self, client: httpx.AsyncClient | None = None) -> None:
        self._client = client or httpx.AsyncClient(
            timeout=httpx.Timeout(10.0),
            headers={"User-Agent": _USER_AGENT},
            follow_redirects=True,
        )

    async def trending(self, limit: int) -> list[TrendingWork]:
        # Ask for more than needed: works without a cover are skipped.
        response = await self._client.get(
            "https://openlibrary.org/trending/weekly.json", params={"limit": limit * 2}
        )
        response.raise_for_status()
        works: list[TrendingWork] = []
        for doc in response.json().get("works", []):
            cover_id = doc.get("cover_i")
            if not isinstance(cover_id, int) or not doc.get("title"):
                continue
            works.append(
                TrendingWork(
                    work_id=str(doc["key"]).removeprefix("/works/"),
                    title=str(doc["title"]),
                    authors=tuple(str(a) for a in doc.get("author_name", [])[:3]),
                    cover_id=cover_id,
                    first_publish_year=doc.get("first_publish_year"),
                )
            )
            if len(works) == limit:
                break
        return works

    async def cover(self, cover_id: int, size: CoverSize) -> CoverImage | None:
        # default=false: a missing cover is a 404 instead of a blank placeholder image.
        response = await self._client.get(
            f"https://covers.openlibrary.org/b/id/{cover_id}-{size}.jpg",
            params={"default": "false"},
        )
        if response.status_code == 404:
            return None
        response.raise_for_status()
        return CoverImage(response.content, response.headers.get("content-type", "image/jpeg"))

    async def aclose(self) -> None:
        await self._client.aclose()
