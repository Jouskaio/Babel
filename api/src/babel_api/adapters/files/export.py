"""Clean copies of the library's files, readable by other tools (Kavita, Plex, a file manager).

The store keeps each file once under its hash. Here every book also appears under
``<kind>/<author>/<author - title>.<ext>``, as a hard link (no extra space) or, when the folders
are on different disks, a copy.
"""

import contextlib
import logging
import os
import shutil
from pathlib import Path, PurePosixPath

logger = logging.getLogger(__name__)


class LibraryExporter:
    def __init__(self, root: str | Path) -> None:
        self._root = Path(root)

    def export(self, source: Path, relative: PurePosixPath, tag: str) -> Path | None:
        """Puts [source] at [relative] under the export folder; [tag] tells two different
        files of one name apart. Returns where it is, None when it could not be done."""
        target = self._root / relative
        try:
            target.parent.mkdir(parents=True, exist_ok=True)
            if target.exists():
                if target.samefile(source):
                    return target
                target = target.with_name(f"{target.stem} ({tag[:6]}){target.suffix}")
                if target.exists():
                    return target
            try:
                os.link(source, target)
            except OSError:
                shutil.copy2(source, target)
        except OSError:
            logger.warning("Could not export %s to %s", source, relative, exc_info=True)
            return None
        return target

    def forget(self, source: Path) -> int:
        """Removes the exported links of a file that left the store (a copy that is not a link
        stays: it cannot be told from another file)."""
        try:
            stat = source.stat()
        except OSError:
            return 0
        removed = 0
        for folder, _dirs, names in os.walk(self._root):
            for name in names:
                path = Path(folder) / name
                try:
                    found = path.stat()
                    if found.st_ino == stat.st_ino and found.st_dev == stat.st_dev:
                        path.unlink()
                        removed += 1
                except OSError:
                    continue
        for folder, dirs, names in os.walk(self._root, topdown=False):
            if not dirs and not names and Path(folder) != self._root:
                with contextlib.suppress(OSError):
                    Path(folder).rmdir()
        return removed
