"""Open Library: trending works and cover images (https://openlibrary.org/developers/api)."""

import asyncio
import html
import re
from typing import Any

import httpx

from babel_api.domain.catalog import CoverImage, SourceEdition, SourceWork, TrendingWork
from babel_api.domain.isbn import try_normalize_isbn
from babel_api.domain.ports import CoverSize

_BASE = "https://openlibrary.org"

# Open Library uses MARC language codes; the app works with ISO 639-1 when one exists.
_LANGUAGES = {
    "fre": "fr", "eng": "en", "ger": "de", "spa": "es", "ita": "it", "por": "pt", "rus": "ru",
    "jpn": "ja", "chi": "zh", "dut": "nl", "pol": "pl", "swe": "sv", "dan": "da", "nor": "no",
    "fin": "fi", "gre": "el", "tur": "tr", "ara": "ar", "heb": "he", "kor": "ko", "cze": "cs",
    "hun": "hu", "rum": "ro", "ukr": "uk", "cat": "ca", "lat": "la",
}  # fmt: skip


def _key(value: Any, prefix: str) -> str:
    return str(value).removeprefix(prefix)


def _text(value: Any) -> str | None:
    """Descriptions are either a string or ``{"type": "/type/text", "value": "..."}``."""
    if isinstance(value, dict):
        value = value.get("value")  # type: ignore[union-attr]
    return value.strip() if isinstance(value, str) and value.strip() else None


def _items(value: Any) -> list[Any]:
    """A JSON list, or an empty one when the field is missing or not a list."""
    return list(value) if isinstance(value, list) else []  # type: ignore[arg-type]


def _dicts(value: Any) -> list[dict[str, Any]]:
    return [item for item in _items(value) if isinstance(item, dict)]


def _first_int(values: Any) -> int | None:
    if isinstance(values, list):
        for item in values:  # type: ignore[union-attr]
            if isinstance(item, int) and item > 0:
                return item
    return None


_GOOGLE_BOOKS = "https://www.googleapis.com/books/v1/volumes"
_TAGS = re.compile(r"<[^>]+>")


_VOLUME_WORDS = {"vol", "volume", "tome", "band", "no", "n"}


def _words(text: str) -> list[str]:
    """Lower-case words and numbers; "03" and "3" are the same number."""
    found = re.findall(r"\w+", text.lower())
    return [str(int(w)) if w.isdigit() else w for w in found]


def _best_blurb(
    volumes: list[dict[str, Any]], wanted: set[str], language: str | None
) -> str | None:
    """The fullest description among [volumes], for the right volume and language."""
    best: tuple[int, str] | None = None
    for volume in volumes:
        text = _clean_blurb(volume.get("description"))
        if not text:
            continue
        numbers = {w for w in _words(str(volume.get("title", ""))) if w.isdigit()}
        if wanted and numbers and wanted.isdisjoint(numbers):
            continue  # another volume of the series: its story is not this one's
        score = len(text) + (500 if wanted and wanted & numbers else 0)
        score += 1000 if language and volume.get("language") == language else 0
        if best is None or score > best[0]:
            best = (score, text)
    return best[1] if best else None


def _clean_blurb(value: Any) -> str | None:
    """Google Books descriptions carry HTML: paragraphs and line breaks become blank lines."""
    if not isinstance(value, str):
        return None
    text = re.sub(r"(?i)</p>|<br\s*/?>", "\n\n", value)
    text = html.unescape(_TAGS.sub("", text))
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\n{3,}", "\n\n", text).strip()
    return text or None


def _ints(values: Any) -> tuple[int, ...]:
    """The positive integers of a JSON list, in order, without repeats (Open Library marks
    removed covers with negative numbers)."""
    return tuple(dict.fromkeys(i for i in _items(values) if isinstance(i, int) and i > 0))[:12]


def _year(value: Any) -> int | None:
    digits = "".join(c for c in str(value or "") if c.isdigit())
    return int(digits[-4:]) if len(digits) >= 4 else None


_USER_AGENT = "Babel/1.0 (https://babel.jouskaio.me)"


def _subjects(value: object) -> tuple[str, ...]:
    """The first subjects of a work (Open Library lists up to hundreds)."""
    return tuple(str(s)[:120] for s in _items(value)[:40] if str(s).strip())


class OpenLibrarySource:
    """Reads Open Library over HTTP. Failures surface as ``httpx.HTTPError``."""

    def __init__(self, client: httpx.AsyncClient | None = None, google_books_key: str = "") -> None:
        self._google_key = google_books_key
        self._client = client or httpx.AsyncClient(
            timeout=httpx.Timeout(10.0),
            headers={"User-Agent": _USER_AGENT},
            follow_redirects=True,
        )

    async def trending(self, limit: int) -> list[TrendingWork]:
        # Ask for more than needed: works without a cover are skipped.
        response = await self._client.get(
            f"{_BASE}/trending/weekly.json", params={"limit": limit * 2}
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

    async def search(self, query: str, limit: int, language: str | None = None) -> list[SourceWork]:
        fields = "key,title,author_name,first_publish_year,cover_i,edition_count,subject"
        params: dict[str, str | int] = {"q": query, "limit": limit, "fields": fields}
        if language:
            # Open Library then returns, per work, its best edition in that language.
            params["lang"] = language
            params["fields"] = f"{fields},editions,editions.title,editions.cover_i"
        response = await self._client.get(f"{_BASE}/search.json", params=params)
        response.raise_for_status()
        works: list[SourceWork] = []
        for doc in _dicts(response.json().get("docs")):
            if not doc.get("title") or not str(doc.get("key", "")).startswith("/works/"):
                continue
            editions: dict[str, Any] = doc.get("editions") or {}
            best = _dicts(editions.get("docs"))[:1]
            works.append(
                SourceWork(
                    open_library_id=_key(doc["key"], "/works/"),
                    title=str(doc["title"]),
                    authors=tuple(str(a) for a in _items(doc.get("author_name"))[:3]),
                    first_publish_year=doc.get("first_publish_year"),
                    cover_id=doc.get("cover_i"),
                    edition_count=doc.get("edition_count"),
                    localized_title=str(best[0]["title"])
                    if best and best[0].get("title")
                    else None,
                    localized_cover_id=best[0].get("cover_i") if best else None,
                    subjects=_subjects(doc.get("subject")),
                )
            )
        return works

    async def work(self, open_library_id: str) -> SourceWork | None:
        response = await self._client.get(f"{_BASE}/works/{open_library_id}.json")
        if response.status_code == 404:
            return None
        response.raise_for_status()
        doc: dict[str, Any] = response.json()
        author_keys = [
            _key(a["author"].get("key", ""), "/authors/")
            for a in _dicts(doc.get("authors"))[:3]
            if isinstance(a.get("author"), dict)
        ]
        names = await asyncio.gather(*(self._author_name(k) for k in author_keys))
        return SourceWork(
            open_library_id=open_library_id,
            title=str(doc.get("title", "")),
            authors=tuple(n for n in names if n),
            first_publish_year=_year(doc.get("first_publish_date")),
            cover_id=_first_int(doc.get("covers")),
            description=_text(doc.get("description")),
            subjects=_subjects(doc.get("subjects")),
        )

    async def editions(self, work_open_library_id: str, limit: int) -> list[SourceEdition]:
        response = await self._client.get(
            f"{_BASE}/works/{work_open_library_id}/editions.json", params={"limit": limit}
        )
        response.raise_for_status()
        return [
            self._edition(doc, work_open_library_id) for doc in response.json().get("entries", [])
        ]

    async def edition_by_isbn(self, isbn13: str) -> SourceEdition | None:
        response = await self._client.get(f"{_BASE}/isbn/{isbn13}.json")
        if response.status_code == 404:
            return None
        response.raise_for_status()
        doc: dict[str, Any] = response.json()
        works = _dicts(doc.get("works"))
        if not works:
            return None
        return self._edition(doc, _key(works[0].get("key", ""), "/works/"))

    async def _author_name(self, key: str) -> str | None:
        try:
            response = await self._client.get(f"{_BASE}/authors/{key}.json")
            response.raise_for_status()
        except httpx.HTTPError:
            return None
        name = response.json().get("name")
        return str(name) if name else None

    @staticmethod
    def _edition(doc: dict[str, Any], work_id: str) -> SourceEdition:
        languages = [
            _key(lang.get("key", ""), "/languages/") for lang in _dicts(doc.get("languages"))
        ]
        language = _LANGUAGES.get(languages[0], languages[0]) if languages else None
        isbn13 = {try_normalize_isbn(str(i)) for i in _items(doc.get("isbn_13"))}
        isbn13 |= {try_normalize_isbn(str(i)) for i in _items(doc.get("isbn_10"))}
        publishers = _items(doc.get("publishers"))
        pages = doc.get("number_of_pages")
        return SourceEdition(
            open_library_id=_key(doc["key"], "/books/"),
            work_open_library_id=work_id,
            title=str(doc.get("title", "")),
            language=language,
            publisher=str(publishers[0]) if publishers else None,
            published=str(doc["publish_date"]) if doc.get("publish_date") else None,
            page_count=pages if isinstance(pages, int) and pages > 0 else None,
            format=str(doc["physical_format"]) if doc.get("physical_format") else None,
            cover_id=_first_int(doc.get("covers")),
            isbn13=tuple(sorted(i for i in isbn13 if i)),
            isbn10=tuple(str(i) for i in _items(doc.get("isbn_10"))),
            cover_ids=_ints(doc.get("covers")),
            description=_text(doc.get("description")) or _text(doc.get("first_sentence")),
        )

    async def blurb(
        self, isbn13: str | None, title: str, authors: tuple[str, ...], language: str | None
    ) -> str | None:
        """The description Google Books has for this book: by ISBN, else by title and author,
        else (for a volume of a series) by the series. Open Library often has one line."""
        words = _words(title)
        volume = {w for w in words if w.isdigit()}
        core = [w for w in words if not w.isdigit() and w not in _VOLUME_WORDS]
        author = authors[0] if authors else ""
        attempts: list[tuple[str, set[str]]] = []
        if isbn13:
            attempts.append((f"isbn:{isbn13}", set()))
        if title:
            attempts.append((f"{title} {author}".strip(), volume))
        if volume and core:
            # "Homunculus 3": the series is described even when the volume is not.
            attempts.append((f"{' '.join(core)} {author}".strip(), set()))
        for query, wanted in attempts:
            # An ISBN names one book: no need to try other languages.
            langs = [None] if query.startswith("isbn:") or not language else [language, None]
            for lang in langs:
                found = await self._google(query, lang, None if query.startswith("isbn:") else core)
                text = _best_blurb(found, wanted, lang)
                if text:
                    return text
        return None

    async def _google(
        self, query: str, language: str | None, core: list[str] | None
    ) -> list[dict[str, Any]]:
        params: dict[str, str | int] = {"q": query, "maxResults": 10, "printType": "books"}
        if self._google_key:
            params["key"] = self._google_key
        if language and core is not None:
            params["langRestrict"] = language
        try:
            response = await self._client.get(_GOOGLE_BOOKS, params=params)
            response.raise_for_status()
        except httpx.HTTPError:
            return []
        payload: dict[str, Any] = response.json()
        volumes = [
            dict(info[0])
            for item in _dicts(payload.get("items"))
            if (info := _dicts([item.get("volumeInfo")]))
        ]
        if core:
            # A search finds neighbours too: the title must hold the title's words.
            volumes = [v for v in volumes if set(core) <= set(_words(str(v.get("title", ""))))]
        return volumes

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
