"""GitHub repositories as sources of book files (read-only, via the REST API)."""

import re
from collections.abc import AsyncIterator
from typing import Any

import httpx

from babel_api.adapters.sources.http import book_format
from babel_api.domain.errors import SourceConnectionError, SourceRateLimitedError
from babel_api.domain.sources import RemoteEntry

_API = "https://api.github.com"
_REPOSITORY = re.compile(r"^[A-Za-z0-9-]{1,39}/[A-Za-z0-9._-]{1,100}$")
BOOK_EXTENSIONS = (".epub", ".pdf", ".cbz", ".cbr")


def _headers(token: str | None) -> dict[str, str]:
    headers = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
        "User-Agent": "Babel (https://babel.jouskaio.me)",
    }
    if token:
        headers["Authorization"] = f"Bearer {token}"
    return headers


def _refuse(response: httpx.Response, *refused: int) -> None:
    """Raises the domain error matching a GitHub refusal, if any."""
    # Rate limits come as 403 or 429 with no request left (60 per hour without a token).
    if response.status_code == 429 or (
        response.status_code == 403 and response.headers.get("x-ratelimit-remaining") == "0"
    ):
        raise SourceRateLimitedError
    if response.status_code in refused:
        raise SourceConnectionError(str(response.status_code))


def normalize_folder(folder: str | None) -> str:
    return (folder or "").strip().strip("/")


class GitHubConnector:
    def __init__(self, client: httpx.AsyncClient | None = None) -> None:
        self._client = client or httpx.AsyncClient(
            timeout=httpx.Timeout(30.0), follow_redirects=True
        )

    async def check(self, config: dict[str, Any], token: str | None) -> dict[str, Any]:
        repository = str(config.get("repository", "")).strip()
        if not _REPOSITORY.fullmatch(repository):
            raise SourceConnectionError("repository")
        try:
            response = await self._client.get(f"{_API}/repos/{repository}", headers=_headers(token))
        except httpx.HTTPError as error:
            raise SourceConnectionError("unreachable") from error
        # 404 also covers private repositories the token cannot see.
        _refuse(response, 401, 403, 404)
        response.raise_for_status()
        branch = config.get("branch") or response.json().get("default_branch", "main")
        return {
            "repository": repository,
            "folder": normalize_folder(config.get("folder")),
            "branch": str(branch),
        }

    async def list_entries(self, config: dict[str, Any], token: str | None) -> list[RemoteEntry]:
        repository, branch = config["repository"], config["branch"]
        folder = normalize_folder(config.get("folder"))
        try:
            response = await self._client.get(
                f"{_API}/repos/{repository}/git/trees/{branch}",
                params={"recursive": "1"},
                headers=_headers(token),
            )
        except httpx.HTTPError as error:
            raise SourceConnectionError("unreachable") from error
        _refuse(response, 401, 403, 404, 409)  # 409: empty repository
        response.raise_for_status()
        prefix = f"{folder}/" if folder else ""
        return [
            RemoteEntry(
                path=str(item["path"]),
                size=int(item.get("size", 0)),
                remote_id=str(item["sha"]),
                format=book_format(str(item["path"])),
            )
            for item in response.json().get("tree", [])
            if item.get("type") == "blob"
            and str(item["path"]).startswith(prefix)
            and str(item["path"]).lower().endswith(BOOK_EXTENSIONS)
        ]

    async def fetch(
        self, config: dict[str, Any], token: str | None, entry: RemoteEntry
    ) -> AsyncIterator[bytes]:
        # Git blobs are addressed by their SHA, so the content cannot change under us.
        headers = {**_headers(token), "Accept": "application/vnd.github.raw+json"}
        url = f"{_API}/repos/{config['repository']}/git/blobs/{entry.remote_id}"
        try:
            async with self._client.stream("GET", url, headers=headers) as response:
                _refuse(response)
                if response.status_code >= 400:
                    raise SourceConnectionError(str(response.status_code))
                async for chunk in response.aiter_bytes(1024 * 1024):
                    yield chunk
        except httpx.HTTPError as error:
            raise SourceConnectionError("unreachable") from error

    async def aclose(self) -> None:
        await self._client.aclose()
