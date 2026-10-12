"""Free machine translation (MyMemory), for a summary the reader cannot read.

MyMemory is a public service with a daily free quota and no key: short texts only, a few at a
time. Anything that goes wrong reads as "no translation": the original text stays on screen.
"""

import hashlib
import logging
import re
import time
from typing import Any, cast

import httpx

from babel_api.domain.language import guess_language

log = logging.getLogger(__name__)

MYMEMORY = "https://api.mymemory.translated.net/get"
CACHE_SECONDS = 24 * 3600
MAX_CHARS = 2500
CHUNK = 450  # MyMemory takes about 500 bytes per request
USER_AGENT = "Babel/1.0 (https://babel.jouskaio.me; reading app)"


def chunks(text: str, size: int = CHUNK) -> list[str]:
    """The text cut at sentence ends (or spaces) into pieces of [size] characters at most."""
    pieces: list[str] = []
    current = ""
    for sentence in re.split(r"(?<=[.!?…])\s+|\n+", text.strip()):
        while len(sentence) > size:
            cut = sentence.rfind(" ", 0, size)
            cut = cut if cut > 0 else size
            head, sentence = sentence[:cut], sentence[cut:].lstrip()
            if current:
                pieces.append(current)
                current = ""
            pieces.append(head)
        if current and len(current) + 1 + len(sentence) > size:
            pieces.append(current)
            current = ""
        current = f"{current} {sentence}".strip()
    if current:
        pieces.append(current)
    return pieces


class Translator:
    def __init__(self, client: httpx.AsyncClient | None = None) -> None:
        self._client = client or httpx.AsyncClient(timeout=15, headers={"User-Agent": USER_AGENT})
        self._cache: dict[str, tuple[float, str]] = {}

    async def translate(self, text: str, target: str) -> str | None:
        """The text in [target] (a two-letter code): as it is when it already reads in that
        language, None when it cannot be translated now (quota reached, service down)."""
        text = text.strip()[:MAX_CHARS]
        source = guess_language(text)
        if not text:
            return None
        if source == target:
            return text
        key = hashlib.sha256(f"{target}:{text}".encode()).hexdigest()
        cached = self._cache.get(key)
        if cached is not None and time.monotonic() - cached[0] < CACHE_SECONDS:
            return cached[1]
        pair = f"{source or 'Autodetect'}|{target}"
        out: list[str] = []
        for piece in chunks(text):
            try:
                response = await self._client.get(MYMEMORY, params={"q": piece, "langpair": pair})
                response.raise_for_status()
                data = cast(dict[str, Any], response.json())
            except (httpx.HTTPError, ValueError) as error:
                log.info("Translation unavailable: %s", error)
                return None
            translated = str(
                cast(dict[str, Any], data.get("responseData") or {}).get("translatedText", "")
            )
            if (
                str(data.get("responseStatus")) != "200"
                or not translated
                or "MYMEMORY" in translated
            ):
                return None  # a quota warning arrives as the "translation"
            out.append(translated)
        result = "\n\n".join(out) if "\n" in text else " ".join(out)
        self._cache[key] = (time.monotonic(), result)
        return result

    async def aclose(self) -> None:
        await self._client.aclose()
