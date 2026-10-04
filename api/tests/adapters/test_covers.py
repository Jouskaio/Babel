from pathlib import Path

import pytest

from babel_api.adapters.files.covers import LocalCoverCache
from babel_api.adapters.files.metadata import EbookMetadataReader
from babel_api.domain.files import BookFormat, Cover
from tests.books import JPEG, PDF, cbz, epub


def write(tmp_path: Path, content: bytes) -> Path:
    path = tmp_path / "book"
    path.write_bytes(content)
    return path


@pytest.mark.parametrize("style", ["epub3", "epub2"])
def test_epub_covers_are_found(tmp_path: Path, style: str) -> None:
    path = write(tmp_path, epub(cover=JPEG, cover_style=style))
    assert EbookMetadataReader().cover(path, BookFormat.EPUB) == Cover(JPEG, "image/jpeg")


def test_books_without_cover(tmp_path: Path) -> None:
    reader = EbookMetadataReader()
    assert reader.cover(write(tmp_path, epub()), BookFormat.EPUB) is None
    assert reader.cover(write(tmp_path, PDF), BookFormat.PDF) is None


def test_comics_use_their_first_page(tmp_path: Path) -> None:
    cover = EbookMetadataReader().cover(write(tmp_path, cbz()), BookFormat.CBZ)
    assert cover is not None
    assert cover.media_type == "image/jpeg"


def test_the_cache_remembers_covers_and_their_absence(tmp_path: Path) -> None:
    cache = LocalCoverCache(tmp_path)
    assert cache.get("a" * 64) is None
    stored = cache.put("a" * 64, Cover(JPEG, "image/jpeg"))
    assert stored is not None
    path, media_type = stored
    assert media_type == "image/jpeg"
    assert path.read_bytes() == JPEG
    assert cache.get("a" * 64) == (path, "image/jpeg")
    assert cache.put("b" * 64, None) is None
    assert cache.get("b" * 64) is False
