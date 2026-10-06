import asyncio
import hashlib
import io
import zipfile
from pathlib import Path

import pytest

from babel_api.adapters.files.comics import ComicConverter
from babel_api.domain.errors import UnsupportedFileError


def archive(tmp_path: Path, names: list[str]) -> Path:
    """A comic archive; bsdtar reads ZIP the same way it reads RAR."""
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, "w") as comic:
        for name in names:
            comic.writestr(name, f"image {name}".encode())
    path = tmp_path / "comic.cbr"
    path.write_bytes(buffer.getvalue())
    return path


def test_pages_are_repacked_in_reading_order(tmp_path: Path) -> None:
    source = archive(
        tmp_path,
        [
            "Vol 1/page10.jpg",
            "Vol 1/page2.jpg",
            "Vol 1/page1.PNG",
            "notes.txt",
        ],
    )
    converter = ComicConverter(tmp_path / "store")

    cbz = asyncio.run(converter.cbz("ab" + "0" * 62, source))

    with zipfile.ZipFile(cbz) as converted:
        assert converted.namelist() == ["0001.png", "0002.jpg", "0003.jpg"]
        assert converted.read("0003.jpg") == b"image Vol 1/page10.jpg"


def test_the_same_comic_always_gives_the_same_file(tmp_path: Path) -> None:
    source = archive(tmp_path, ["a.jpg", "b.jpg"])
    first = asyncio.run(ComicConverter(tmp_path / "one").cbz("cd" + "0" * 62, source))
    second = asyncio.run(ComicConverter(tmp_path / "two").cbz("cd" + "0" * 62, source))
    digest = [hashlib.sha256(p.read_bytes()).hexdigest() for p in (first, second)]
    assert digest[0] == digest[1]


def test_an_archive_without_pages_is_refused(tmp_path: Path) -> None:
    source = archive(tmp_path, ["readme.txt"])
    with pytest.raises(UnsupportedFileError):
        asyncio.run(ComicConverter(tmp_path / "store").cbz("ef" + "0" * 62, source))


def test_without_bsdtar_comics_cannot_be_converted(tmp_path: Path) -> None:
    source = archive(tmp_path, ["a.jpg"])
    converter = ComicConverter(tmp_path / "store", tool="no-such-tool")
    with pytest.raises(UnsupportedFileError):
        asyncio.run(converter.cbz("12" + "0" * 62, source))
