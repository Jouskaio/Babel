"""Covers extracted from stored files, cached next to them (one small image per file)."""

from pathlib import Path
from typing import Literal

from babel_api.domain.files import Cover

_EXTENSIONS = {
    "image/jpeg": ".jpg",
    "image/png": ".png",
    "image/gif": ".gif",
    "image/webp": ".webp",
    "image/avif": ".avif",
}
# Written when a file has no usable cover, so it is not opened again.
_NONE = ".none"


class LocalCoverCache:
    def __init__(self, root: str | Path) -> None:
        self._root = Path(root) / "covers"

    def _base(self, sha256: str) -> Path:
        return self._root / sha256[:2] / sha256

    def get(self, sha256: str) -> tuple[Path, str] | Literal[False] | None:
        base = self._base(sha256)
        if base.with_suffix(_NONE).exists():
            return False
        for media_type, extension in _EXTENSIONS.items():
            path = base.with_suffix(extension)
            if path.exists():
                return path, media_type
        return None

    def put(self, sha256: str, cover: Cover | None) -> tuple[Path, str] | None:
        base = self._base(sha256)
        base.parent.mkdir(parents=True, exist_ok=True)
        extension = _EXTENSIONS.get(cover.media_type) if cover else None
        if cover is None or extension is None:
            base.with_suffix(_NONE).touch()
            return None
        path = base.with_suffix(extension)
        partial = path.with_suffix(".part")
        partial.write_bytes(cover.content)
        partial.replace(path)
        return path, cover.media_type
