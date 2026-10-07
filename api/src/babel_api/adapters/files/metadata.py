"""Format detection from magic bytes and EPUB metadata, safe for untrusted uploads."""

import posixpath
import zipfile
from pathlib import Path, PurePosixPath
from typing import Any
from urllib.parse import unquote

from defusedxml import ElementTree

from babel_api.domain.files import BookFormat, BookMetadata, Cover
from babel_api.domain.isbn import try_normalize_isbn
from babel_api.domain.series import parse_number

_IMAGES = {".jpg", ".jpeg", ".png", ".gif", ".webp", ".avif"}
# Package files are small; anything bigger is refused (zip bombs).
_MAX_XML_BYTES = 2 * 1024 * 1024
_MAX_COVER_BYTES = 5 * 1024 * 1024
_MEDIA_TYPES = {
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".png": "image/png",
    ".gif": "image/gif",
    ".webp": "image/webp",
    ".avif": "image/avif",
}
_NS = {
    "c": "urn:oasis:names:tc:opendocument:xmlns:container",
    "opf": "http://www.idpf.org/2007/opf",
    "dc": "http://purl.org/dc/elements/1.1/",
}


def _read_small(archive: zipfile.ZipFile, name: str, limit: int = _MAX_XML_BYTES) -> bytes | None:
    try:
        info = archive.getinfo(name)
    except KeyError:
        return None
    if info.file_size > limit:
        return None
    return archive.read(info)


def _package(archive: zipfile.ZipFile) -> tuple[str, Any] | None:
    """The OPF package of an EPUB: its path in the archive and its parsed XML."""
    container = _read_small(archive, "META-INF/container.xml")
    if container is None:
        return None
    rootfile = ElementTree.fromstring(container).find(".//c:rootfile", _NS)
    opf_path = rootfile.get("full-path") if rootfile is not None else None
    opf = _read_small(archive, opf_path) if opf_path else None
    if opf_path is None or opf is None:
        return None
    return opf_path, ElementTree.fromstring(opf)


def _cover_href(package: Any) -> str | None:
    """EPUB 3 cover-image property, then the EPUB 2 cover meta, then a likely name."""
    items = [i for i in package.iterfind(".//opf:manifest/opf:item", _NS) if i.get("href")]
    for item in items:
        if "cover-image" in (item.get("properties") or "").split():
            return item.get("href")
    meta = package.find(".//opf:metadata/opf:meta[@name='cover']", _NS)
    cover_id = meta.get("content") if meta is not None else None
    for item in items:
        if cover_id and item.get("id") == cover_id:
            return item.get("href")
    for item in items:
        if (item.get("media-type") or "").startswith("image/") and "cover" in (
            (item.get("id") or "") + (item.get("href") or "")
        ).lower():
            return item.get("href")
    return None


def _image(archive: zipfile.ZipFile, name: str) -> Cover | None:
    media_type = _MEDIA_TYPES.get(PurePosixPath(name).suffix.lower())
    content = _read_small(archive, name, _MAX_COVER_BYTES) if media_type else None
    if media_type is None or not content:
        return None
    return Cover(content, media_type)


def _epub_series(package: Any) -> tuple[str | None, float | None]:
    """The series of an EPUB: Calibre's meta tags, or EPUB 3's collection."""
    named: dict[str, str] = {}
    for meta in package.iterfind(".//opf:meta", _NS):
        name = meta.get("name")
        if name in ("calibre:series", "calibre:series_index") and meta.get("content"):
            named[name] = str(meta.get("content"))
    if named.get("calibre:series"):
        return named["calibre:series"].strip(), parse_number(named.get("calibre:series_index"))
    # EPUB 3: <meta property="belongs-to-collection" id="c">Name</meta>, its position
    # given by <meta refines="#c" property="group-position">3</meta>.
    for meta in package.iterfind(".//opf:meta", _NS):
        if meta.get("property") == "belongs-to-collection" and (meta.text or "").strip():
            collection_id = meta.get("id")
            position = next(
                (
                    parse_number(m.text)
                    for m in package.iterfind(".//opf:meta", _NS)
                    if m.get("property") == "group-position"
                    and collection_id
                    and m.get("refines") == f"#{collection_id}"
                ),
                None,
            )
            return (meta.text or "").strip(), position
    return None, None


def _comic_info(path: Path) -> BookMetadata:
    """A comic's ComicInfo.xml: genres, series and volume."""
    try:
        with zipfile.ZipFile(path) as archive:
            name = next(
                (n for n in archive.namelist() if PurePosixPath(n).name.lower() == "comicinfo.xml"),
                None,
            )
            if name is None:
                return BookMetadata()
            root = ElementTree.fromstring(archive.read(name))
    except (zipfile.BadZipFile, ElementTree.ParseError, ValueError, OSError):
        return BookMetadata()

    def field(tag: str) -> str | None:
        for e in root.iter():
            if e.tag.rsplit("}", 1)[-1] == tag and e.text and e.text.strip():
                return e.text.strip()
        return None

    genres = [g.strip() for g in (field("Genre") or "").split(",") if g.strip()]
    if (field("Manga") or "").lower().startswith("yes"):
        genres.append("Manga")
    authors = [a.strip() for a in (field("Writer") or "").split(",") if a.strip()]
    return BookMetadata(
        authors=tuple(authors[:3]),
        subjects=tuple(dict.fromkeys(genres))[:20],
        series=field("Series"),
        series_index=parse_number(field("Number")),
    )


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
        if file_format is BookFormat.CBZ:
            return _comic_info(path)
        if file_format is not BookFormat.EPUB:
            return BookMetadata()
        try:
            with zipfile.ZipFile(path) as archive:
                found = _package(archive)
        # ValueError: defused XML attack
        except (zipfile.BadZipFile, ElementTree.ParseError, ValueError):
            return BookMetadata()
        if found is None:
            return BookMetadata()
        _, package = found

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
        series, series_index = _epub_series(package)
        return BookMetadata(
            title=titles[0] if titles else None,
            authors=tuple(texts("creator")[:3]),
            isbn13=isbn,
            language=languages[0].split("-")[0].lower() if languages else None,
            subjects=tuple(dict.fromkeys(texts("subject")))[:40],
            series=series,
            series_index=series_index,
        )

    def cover(self, path: Path, file_format: BookFormat) -> Cover | None:
        try:
            with zipfile.ZipFile(path) as archive:
                if file_format is BookFormat.CBZ:
                    # Comics: the first page, in reading order.
                    pages = sorted(
                        n
                        for n in archive.namelist()
                        if PurePosixPath(n).suffix.lower() in _MEDIA_TYPES
                        and not n.startswith("__MACOSX/")
                    )
                    return _image(archive, pages[0]) if pages else None
                if file_format is not BookFormat.EPUB:
                    return None
                found = _package(archive)
                href = _cover_href(found[1]) if found else None
                if found is None or href is None:
                    return None
                # Manifest paths are relative to the package file, and URL-encoded.
                name = posixpath.normpath(
                    posixpath.join(posixpath.dirname(found[0]), unquote(href))
                )
                return _image(archive, name)
        except (zipfile.BadZipFile, ElementTree.ParseError, ValueError, OSError):
            return None
