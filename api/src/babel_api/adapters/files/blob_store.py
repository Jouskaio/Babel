"""Content-addressed file store on a local (or NFS-mounted) directory."""

import asyncio
import hashlib
import os
from collections.abc import AsyncIterator
from pathlib import Path
from uuid import uuid4

from babel_api.domain.errors import FileTooLargeError


class LocalBlobStore:
    """Files live at ``<root>/<ab>/<cd>/<sha256>``; identical content is stored once."""

    def __init__(self, root: str | Path) -> None:
        self._root = Path(root)

    def _final(self, sha256: str) -> Path:
        return self._root / sha256[:2] / sha256[2:4] / sha256

    async def put(self, chunks: AsyncIterator[bytes], max_bytes: int) -> tuple[str, int, Path]:
        tmp_dir = self._root / "tmp"
        await asyncio.to_thread(tmp_dir.mkdir, parents=True, exist_ok=True)
        tmp = tmp_dir / f"{uuid4()}.part"
        digest, size = hashlib.sha256(), 0
        try:
            with tmp.open("wb") as out:
                async for chunk in chunks:
                    size += len(chunk)
                    if size > max_bytes:
                        raise FileTooLargeError
                    digest.update(chunk)
                    await asyncio.to_thread(out.write, chunk)
            sha256 = digest.hexdigest()
            final = self._final(sha256)
            if final.exists():
                tmp.unlink()
            else:
                await asyncio.to_thread(final.parent.mkdir, parents=True, exist_ok=True)
                os.replace(tmp, final)  # atomic: readers never see a partial file
            return sha256, size, final
        except BaseException:
            tmp.unlink(missing_ok=True)
            raise

    def path(self, sha256: str) -> Path | None:
        final = self._final(sha256)
        return final if final.is_file() else None

    async def delete(self, sha256: str) -> None:
        await asyncio.to_thread(self._final(sha256).unlink, missing_ok=True)
