"""Machine translation: a self-hosted LibreTranslate (long texts, whole books) and, for a short
excerpt when there is none, the free MyMemory service.

MyMemory is public with a daily quota and no key: a few paragraphs only. LibreTranslate runs on
the reader's own server and has no limit but its speed. Anything that goes wrong reads as "no
translation": the original text stays on screen.
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
MAX_CHARS = 2500  # an excerpt through MyMemory
LIBRE_MAX_CHARS = 20000  # an excerpt through LibreTranslate
CHUNK = 450  # MyMemory takes about 500 bytes per request
USER_AGENT = "Babel/1.0 (https://babel.jouskaio.me; reading app)"


class TranslationUnavailableError(Exception):
    """No engine can do this now (not configured, down, quota reached)."""


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
    def __init__(
        self,
        client: httpx.AsyncClient | None = None,
        libre_url: str = "",
        libre_key: str = "",
    ) -> None:
        self._client = client or httpx.AsyncClient(
            timeout=httpx.Timeout(120, connect=10), headers={"User-Agent": USER_AGENT}
        )
        self._libre = libre_url.strip().rstrip("/")
        self._libre_key = libre_key.strip()
        self._cache: dict[str, tuple[float, str]] = {}
        self._languages: tuple[float, list[dict[str, Any]]] | None = None

    @property
    def books(self) -> bool:
        """Whether whole books can be translated (a LibreTranslate is configured)."""
        return bool(self._libre)

    # ------------------------------------------------------------ LibreTranslate
    async def _libre_translate(
        self, texts: list[str], target: str, source: str | None, html: bool
    ) -> list[str]:
        payload: dict[str, Any] = {
            "q": texts,
            "source": source or "auto",
            "target": target,
            "format": "html" if html else "text",
        }
        if self._libre_key:
            payload["api_key"] = self._libre_key
        try:
            response = await self._client.post(f"{self._libre}/translate", json=payload)
            response.raise_for_status()
            data = cast(dict[str, Any], response.json())
        except (httpx.HTTPError, ValueError) as error:
            raise TranslationUnavailableError(str(error)) from error
        out = data.get("translatedText")
        if not isinstance(out, list) or len(cast(list[Any], out)) != len(texts):
            raise TranslationUnavailableError("unexpected answer")
        return [str(t) for t in cast(list[Any], out)]

    async def translate_blocks(
        self, blocks: list[str], target: str, source: str | None = None, html: bool = True
    ) -> list[str]:
        """Many pieces of text (or HTML) at once, through LibreTranslate only."""
        if not self._libre:
            raise TranslationUnavailableError("no LibreTranslate")
        return await self._libre_translate(blocks, target, source, html)

    async def languages(self) -> list[dict[str, str]]:
        """The languages the translation server knows ({code, name}); a default few without one."""
        if not self._libre:
            return []
        cached = self._languages
        if cached is not None and time.monotonic() - cached[0] < CACHE_SECONDS:
            found = cached[1]
        else:
            try:
                response = await self._client.get(f"{self._libre}/languages")
                response.raise_for_status()
                found = cast(list[dict[str, Any]], response.json())
            except (httpx.HTTPError, ValueError):
                return []
            self._languages = (time.monotonic(), found)
        return [{"code": str(x["code"]), "name": str(x.get("name", x["code"]))} for x in found]

    # ------------------------------------------------------------ an excerpt
    async def translate(self, text: str, target: str) -> str | None:
        """The text in [target] (a two-letter code): as it is when it already reads in that
        language, None when it cannot be translated now (quota reached, service down)."""
        text = text.strip()[: LIBRE_MAX_CHARS if self._libre else MAX_CHARS]
        source = guess_language(text)
        if not text:
            return None
        if source == target:
            return text
        key = hashlib.sha256(f"{target}:{text}".encode()).hexdigest()
        cached = self._cache.get(key)
        if cached is not None and time.monotonic() - cached[0] < CACHE_SECONDS:
            return cached[1]
        result = await self._excerpt(text, target, source)
        if result is not None:
            self._cache[key] = (time.monotonic(), result)
        return result

    async def _excerpt(self, text: str, target: str, source: str | None) -> str | None:
        if self._libre:
            try:
                paragraphs = [p for p in text.split("\n") if p.strip()]
                out = await self._libre_translate(paragraphs, target, source, html=False)
                return "\n\n".join(out)
            except TranslationUnavailableError as error:
                log.info("LibreTranslate unavailable, trying MyMemory: %s", error)
        pair = f"{source or 'Autodetect'}|{target}"
        out_pieces: list[str] = []
        for piece in chunks(text[:MAX_CHARS]):
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
            out_pieces.append(translated)
        return "\n\n".join(out_pieces) if "\n" in text else " ".join(out_pieces)

    async def aclose(self) -> None:
        await self._client.aclose()
