"""Comic archives the readers cannot open themselves (CBR, RAR) turned into CBZ.

``bsdtar`` (libarchive) extracts RAR and RAR5; the pages are then written into a ZIP with
fixed dates and order, so the same CBR always gives the same CBZ. Converted copies are
cached next to the stored files; the original stays untouched (e-readers may want it).
"""

import asyncio
import re
import shutil
import tempfile
import zipfile
from pathlib import Path

from babel_api.domain.errors import UnsupportedFileError

IMAGES = {".jpg", ".jpeg", ".png", ".gif", ".webp", ".avif"}
TIMEOUT_SECONDS = 180
_DIGITS = re.compile(r"(\d+)")


def _natural(path: Path) -> list[object]:
    """ "page2" before "page10"."""
    return [int(p) if p.isdigit() else p.lower() for p in _DIGITS.split(path.as_posix())]


class ComicConverter:
    def __init__(self, root: str | Path, tool: str = "bsdtar") -> None:
        self._root = Path(root) / "converted"
        self._tool = tool
        self._locks: dict[str, asyncio.Lock] = {}

    def _target(self, sha256: str) -> Path:
        return self._root / sha256[:2] / f"{sha256}.cbz"

    async def cbz(self, sha256: str, source: Path) -> Path:
        """The CBZ version of ``source``, converted once."""
        target = self._target(sha256)
        if target.is_file():
            return target
        lock = self._locks.setdefault(sha256, asyncio.Lock())
        async with lock:
            if not target.is_file():
                await self._convert(source, target)
        return target

    async def _convert(self, source: Path, target: Path) -> None:
        tool = shutil.which(self._tool)
        if tool is None:
            raise UnsupportedFileError
        with tempfile.TemporaryDirectory() as folder:
            process = await asyncio.create_subprocess_exec(
                tool,
                # macOS resource forks are no pages, and bsdtar may stop on them.
                "--exclude",
                "__MACOSX",
                "-xf",
                str(source),
                "-C",
                folder,
                stdout=asyncio.subprocess.DEVNULL,
                stderr=asyncio.subprocess.DEVNULL,
            )
            try:
                # A damaged entry makes bsdtar fail at the end: keep the pages it got out.
                await asyncio.wait_for(process.wait(), TIMEOUT_SECONDS)
            except TimeoutError as error:
                process.kill()
                raise UnsupportedFileError from error
            await asyncio.to_thread(self._pack, Path(folder), target)

    @staticmethod
    def _pack(folder: Path, target: Path) -> None:
        pages = sorted(
            (
                p
                for p in folder.rglob("*")
                if p.is_file()
                and p.suffix.lower() in IMAGES
                and "__MACOSX" not in p.parts
                and not p.name.startswith(".")
            ),
            key=lambda p: _natural(p.relative_to(folder)),
        )
        if not pages:
            raise UnsupportedFileError
        target.parent.mkdir(parents=True, exist_ok=True)
        partial = target.with_suffix(".part")
        with zipfile.ZipFile(partial, "w", zipfile.ZIP_STORED) as cbz:
            for index, page in enumerate(pages, start=1):
                info = zipfile.ZipInfo(
                    f"{index:04d}{page.suffix.lower()}", date_time=(1980, 1, 1, 0, 0, 0)
                )
                cbz.writestr(info, page.read_bytes())
        partial.replace(target)

    def remove(self, sha256: str) -> None:
        self._target(sha256).unlink(missing_ok=True)
