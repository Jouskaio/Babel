"""Reading the text of a book cover from a photo, with Tesseract (a program of the image).

Experimental by nature: a cover is art, not a page. The words found are only used to search
the catalog, and the reader picks among the answers.
"""

import asyncio
import re
import shutil

LANGUAGES = "fra+eng"
TIMEOUT = 25.0


class OcrUnavailableError(RuntimeError):
    """Tesseract is not installed here, or did not answer."""


async def read_text(image: bytes) -> str:
    """The text Tesseract finds in a photo (any common format)."""
    if shutil.which("tesseract") is None:
        raise OcrUnavailableError
    process = await asyncio.create_subprocess_exec(
        "tesseract",
        "stdin",
        "stdout",
        "-l",
        LANGUAGES,
        "--psm",
        "11",  # sparse text: titles are scattered over a cover, not set in lines
        stdin=asyncio.subprocess.PIPE,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.DEVNULL,
    )
    try:
        out, _ = await asyncio.wait_for(process.communicate(image), TIMEOUT)
    except TimeoutError as error:
        process.kill()
        raise OcrUnavailableError from error
    return out.decode("utf-8", errors="replace")


def queries(text: str) -> list[str]:
    """Searches to try from the words found on a cover: all of them (the first ones), then the
    longest line alone. Noise (one or two letters, symbols) is dropped."""
    lines: list[list[str]] = []
    for raw in text.splitlines():
        words = [w for w in re.findall(r"[\w'’-]+", raw) if len(w) >= 3 or w.isdigit()]
        if len(" ".join(words)) >= 4:
            lines.append(words)
    if not lines:
        return []
    everything = " ".join(w for line in lines for w in line)
    longest = max(lines, key=lambda line: len(" ".join(line)))
    found = [" ".join(everything.split()[:8]), " ".join(longest[:8])]
    return list(dict.fromkeys(q for q in found if q))
