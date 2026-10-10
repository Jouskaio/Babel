"""How KOReader identifies a book file: the md5 of a few samples of its bytes.

KOReader (and kosync servers) never use the file's name or full hash: they hash 1 KiB read at
offset 0, then at 1 KiB, 4 KiB, 16 KiB… (each step four times further), until the file ends.
"""

import hashlib
from pathlib import Path

SAMPLE = 1024


def partial_md5(path: Path) -> str:
    """KOReader's identifier of the file at [path]."""
    digest = hashlib.md5(usedforsecurity=False)
    offsets = [0] + [SAMPLE << (2 * i) for i in range(11)]
    with path.open("rb") as file:
        for offset in offsets:
            file.seek(offset)
            sample = file.read(SAMPLE)
            if not sample:
                break
            digest.update(sample)
    return digest.hexdigest()
