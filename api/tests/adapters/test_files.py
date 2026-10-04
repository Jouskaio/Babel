import asyncio
from collections.abc import AsyncIterator
from pathlib import Path

import pytest

from babel_api.adapters.files.blob_store import LocalBlobStore
from babel_api.adapters.files.metadata import EbookMetadataReader
from babel_api.domain.errors import FileTooLargeError
from babel_api.domain.files import BookFormat
from tests.books import CBR, NOT_A_BOOK, PDF, cbz, epub


async def _chunks(data: bytes, size: int = 7) -> AsyncIterator[bytes]:
    for start in range(0, len(data), size):
        yield data[start : start + size]


def test_identical_content_is_stored_once(tmp_path: Path) -> None:
    store = LocalBlobStore(tmp_path)

    first = asyncio.run(store.put(_chunks(PDF), 10_000))
    second = asyncio.run(store.put(_chunks(PDF, 3), 10_000))

    assert first == second
    sha, size, path = first
    assert size == len(PDF)
    assert path == tmp_path / sha[:2] / sha[2:4] / sha
    assert [p for p in tmp_path.rglob("*") if p.is_file()] == [path]


def test_oversized_uploads_leave_nothing_behind(tmp_path: Path) -> None:
    store = LocalBlobStore(tmp_path)

    with pytest.raises(FileTooLargeError):
        asyncio.run(store.put(_chunks(PDF), 10))

    assert [p for p in tmp_path.rglob("*") if p.is_file()] == []


def test_deleted_files_are_gone(tmp_path: Path) -> None:
    store = LocalBlobStore(tmp_path)
    sha, _, _ = asyncio.run(store.put(_chunks(PDF), 10_000))

    asyncio.run(store.delete(sha))

    assert store.path(sha) is None


@pytest.mark.parametrize(
    ("content", "expected"),
    [
        (epub(), BookFormat.EPUB),
        (PDF, BookFormat.PDF),
        (cbz(), BookFormat.CBZ),
        (CBR, BookFormat.CBR),
        (NOT_A_BOOK, None),
    ],
)
def test_formats_are_detected_from_content(
    tmp_path: Path, content: bytes, expected: BookFormat | None
) -> None:
    path = tmp_path / "upload.bin"
    path.write_bytes(content)

    assert EbookMetadataReader().detect(path) == expected


def test_epub_metadata_is_read(tmp_path: Path) -> None:
    path = tmp_path / "book.epub"
    path.write_bytes(epub(isbn="2070360245"))

    metadata = EbookMetadataReader().metadata(path, BookFormat.EPUB)

    assert metadata.title == "Jane Eyre"
    assert metadata.authors == ("Charlotte Brontë",)
    assert metadata.isbn13 == "9782070360246"
    assert metadata.language == "fr"


def test_malicious_xml_is_ignored(tmp_path: Path) -> None:
    bomb = '<!DOCTYPE lolz [<!ENTITY lol "lol"><!ENTITY lol2 "&lol;&lol;&lol;&lol;&lol;">]>'
    path = tmp_path / "bomb.epub"
    path.write_bytes(epub(title="&lol2;", opf_extra=bomb))

    metadata = EbookMetadataReader().metadata(path, BookFormat.EPUB)

    assert metadata.title is None
