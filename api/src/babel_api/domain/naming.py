"""The name a book's file is given when it leaves Babel (downloads, the e-reader's cloud)."""

import re

from babel_api.domain.files import LibraryItem

_FORBIDDEN = re.compile(r'[\\/:*?"<>|\x00-\x1f]')
_SPACES = re.compile(r"\s+")
MAX_STEM = 120


def _clean(text: str) -> str:
    return _SPACES.sub(" ", _FORBIDDEN.sub(" ", text)).strip(" .")


def _volume(index: float) -> str:
    return f"{int(index):02d}" if index == int(index) else f"{index:g}"


def book_filename(item: LibraryItem) -> str:
    """ "Author - Title.epub", "Author - Series 02 - Title.epub", "(AO3)" after a fanfiction.

    Falls back to the file's own name when the book has no usable title."""
    if item.file is None:
        raise ValueError("a paper book has no file")
    extension = item.file.format.value
    title = _clean(item.title)
    if not title:
        return item.file.original_name
    authors = [a for a in (_clean(a) for a in item.authors) if a]
    parts = [", ".join(authors[:2]) + (" et al." if len(authors) > 2 else "")] if authors else []
    if item.series and (series := _clean(item.series)):
        parts.append(
            f"{series} {_volume(item.series_index)}" if item.series_index is not None else series
        )
    parts.append(title + (" (AO3)" if item.origin == "ao3" else ""))
    stem = " - ".join(p for p in parts if p)
    if len(stem) > MAX_STEM:
        stem = stem[:MAX_STEM].rsplit(" ", 1)[0].rstrip(" -,.") or stem[:MAX_STEM]
    return f"{stem}.{extension}"
