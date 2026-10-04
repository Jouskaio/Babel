"""Format detection from magic bytes and EPUB metadata, safe for untrusted uploads."""

import zipfile
from pathlib import Path, PurePosixPath

from defusedxml import ElementTree

from babel_api.domain.files import BookFormat, BookMetadata
from babel_api.domain.isbn import try_normalize_isbn

_IMAGES = {".jpg", ".jpeg", ".png", ".gif", ".webp", ".avif"}
# Package files are small; anything bigger is refused (zip bombs).
_MAX_XML_BYTES = 2 * 1024 * 1024
_NS = {
    "c": "urn:oasis:names:tc:opendocument:xmlns:container",
    "opf": "http://www.idpf.org/2007/opf",
    "dc": "http://purl.org/dc/elements/1.1/",
}


def _read_small(archive: zipfile.ZipFile, name: str) -> bytes | None:
    try:
        info = archive.getinfo(name)
    except KeyError:
        return None
    if info.file_size > _MAX_XML_BYTES:
        return None
    return archive.read(info)


class EbookMetadataReader:
    def detect(self, path: Path) -> BookFormat | None:
        with path.open("rb") as file:
            head = file.read(8)
        if head.startswith(b"%PDF-"):
            return BookFormat.PDF
        if head.startswith(b"Rar!\x1a\x07"):
            return BookFormat.CBR
        if not head.startswith(b"PK\x03\x04"):
            return None
        try:
            with zipfile.ZipFile(path) as archive:
                if (_read_small(archive, "mimetype") or b"").strip() == b"application/epub+zip":
                    return BookFormat.EPUB
                names = archive.namelist()
        except zipfile.BadZipFile:
            return None
        if any(PurePosixPath(n).suffix.lower() in _IMAGES for n in names):
            return BookFormat.CBZ
        return None

    def metadata(self, path: Path, file_format: BookFormat) -> BookMetadata:
        if file_format is not BookFormat.EPUB:
            return BookMetadata()
        try:
            with zipfile.ZipFile(path) as archive:
                container = _read_small(archive, "META-INF/container.xml")
                if container is None:
                    return BookMetadata()
                rootfile = ElementTree.fromstring(container).find(".//c:rootfile", _NS)
                opf_path = rootfile.get("full-path") if rootfile is not None else None
                opf = _read_small(archive, opf_path) if opf_path else None
        except (zipfile.BadZipFile, ElementTree.ParseError, ValueError):
            return BookMetadata()
        if opf is None:
            return BookMetadata()
        try:
            package = ElementTree.fromstring(opf)
        except (ElementTree.ParseError, ValueError):  # ValueError: defused XML attack
            return BookMetadata()

        def texts(tag: str) -> list[str]:
            return [
                e.text.strip()
                for e in package.iterfind(f".//dc:{tag}", _NS)
                if e.text and e.text.strip()
            ]

        isbn = next(
            (
                i
                for i in (
                    try_normalize_isbn(t.removeprefix("urn:isbn:")) for t in texts("identifier")
                )
                if i
            ),
            None,
        )
        titles = texts("title")
        languages = texts("language")
        return BookMetadata(
            title=titles[0] if titles else None,
            authors=tuple(texts("creator")[:3]),
            isbn13=isbn,
            language=languages[0].split("-")[0].lower() if languages else None,
        )
