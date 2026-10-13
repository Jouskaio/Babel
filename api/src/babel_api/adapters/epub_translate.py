"""Translating an EPUB: its chapters' paragraphs are translated, everything else is kept.

The text of each block (paragraph, heading, list item…) is sent as HTML so that inline marks
(italics, links) survive. Images, styles, the table of contents file and the cover are copied
untouched; the language and the title in the package are updated.
"""

import re
import zipfile
from collections.abc import Awaitable, Callable
from pathlib import Path, PurePosixPath

from bs4 import BeautifulSoup, Tag
from defusedxml import ElementTree

_BLOCKS = [
    "p", "h1", "h2", "h3", "h4", "h5", "h6", "li", "blockquote", "figcaption", "td", "th",
    "dt", "dd", "caption", "div",
]  # fmt: skip
_NS = {
    "c": "urn:oasis:names:tc:opendocument:xmlns:container",
    "opf": "http://www.idpf.org/2007/opf",
}
BATCH_CHARS = 3500
BATCH_BLOCKS = 40

# Translates several pieces of HTML at once.
BatchTranslate = Callable[[list[str]], Awaitable[list[str]]]
Progress = Callable[[int, int], Awaitable[None]]


def _documents(archive: zipfile.ZipFile) -> tuple[str, list[str]]:
    """The package's path and the chapters' paths, in reading order."""
    container = ElementTree.fromstring(archive.read("META-INF/container.xml"))
    rootfile = container.find(".//c:rootfile", _NS)
    opf_path = rootfile.get("full-path") if rootfile is not None else None
    if not opf_path:
        raise ValueError("no package")
    package = ElementTree.fromstring(archive.read(opf_path))
    base = PurePosixPath(opf_path).parent
    manifest = {
        i.get("id"): i
        for i in package.iterfind(".//opf:manifest/opf:item", _NS)
        if i.get("href") and "html" in (i.get("media-type") or "")
    }
    paths: list[str] = []
    for ref in package.iterfind(".//opf:spine/opf:itemref", _NS):
        item = manifest.get(ref.get("idref"))
        if item is not None:
            href = (item.get("href") or "").split("#", 1)[0]
            paths.append(str(PurePosixPath(base, href)).lstrip("./") if str(base) != "." else href)
    if not paths:  # a package without a usable spine: every page of the archive, in name order
        paths = sorted(
            n for n in archive.namelist() if n.lower().endswith((".xhtml", ".html", ".htm"))
        )
    return opf_path, paths


def _blocks(soup: BeautifulSoup) -> list[Tag]:
    """The leaf blocks that hold some text (a block with blocks inside is left to them)."""
    found: list[Tag] = []
    for element in soup.find_all(_BLOCKS):
        if element.find(_BLOCKS):
            continue
        if element.find_parent(["script", "style"]):
            continue
        if re.search(r"[^\W\d_]", element.get_text()):
            found.append(element)
    return found


def _inner(element: Tag) -> str:
    return "".join(str(child) for child in element.contents)


def _replace(element: Tag, html: str) -> None:
    fragment = BeautifulSoup(html, "html.parser")
    element.clear()
    for node in list(fragment.contents):
        element.append(node)


def batches(texts: list[str]) -> list[list[int]]:
    """Indexes of [texts] grouped so that a request stays small."""
    groups: list[list[int]] = []
    current: list[int] = []
    size = 0
    for index, text in enumerate(texts):
        if current and (size + len(text) > BATCH_CHARS or len(current) >= BATCH_BLOCKS):
            groups.append(current)
            current, size = [], 0
        current.append(index)
        size += len(text)
    if current:
        groups.append(current)
    return groups


def _package_text(opf: str, language: str, title_suffix: str) -> str:
    opf = re.sub(
        r"(<dc:language[^>]*>)[^<]*(</dc:language>)", rf"\g<1>{language}\g<2>", opf, count=1
    )
    if title_suffix:
        opf = re.sub(
            r"(<dc:title[^>]*>)([^<]*)(</dc:title>)",
            lambda m: f"{m.group(1)}{m.group(2)} {title_suffix}{m.group(3)}",
            opf,
            count=1,
        )
    return opf


async def translate_epub(
    source: Path,
    destination: Path,
    translate: BatchTranslate,
    *,
    language: str,
    title_suffix: str = "",
    progress: Progress | None = None,
) -> None:
    """Writes to [destination] the book [source] with its chapters translated by [translate]."""
    replaced: dict[str, bytes] = {}
    with zipfile.ZipFile(source) as archive:
        opf_path, documents = _documents(archive)
        parsed: dict[str, tuple[BeautifulSoup, list[Tag]]] = {}
        total = 0
        for path in documents:
            try:
                data = archive.read(path)
            except KeyError:
                continue
            soup = BeautifulSoup(data.decode("utf-8", errors="replace"), "html.parser")
            blocks = _blocks(soup)
            parsed[path] = (soup, blocks)
            total += sum(len(_inner(b)) for b in blocks)
        done = 0
        for path, (soup, blocks) in parsed.items():
            texts = [_inner(b) for b in blocks]
            for group in batches(texts):
                translated = await translate([texts[i] for i in group])
                for index, html in zip(group, translated, strict=True):
                    _replace(blocks[index], html)
                done += sum(len(texts[i]) for i in group)
                if progress is not None:
                    await progress(done, max(total, 1))
            replaced[path] = soup.decode().encode("utf-8")
        opf = archive.read(opf_path).decode("utf-8", errors="replace")
        replaced[opf_path] = _package_text(opf, language, title_suffix).encode("utf-8")
        with zipfile.ZipFile(destination, "w") as out:
            for info in archive.infolist():
                data = replaced.get(info.filename)
                if data is None:
                    data = archive.read(info.filename)
                compress = (
                    zipfile.ZIP_STORED if info.filename == "mimetype" else zipfile.ZIP_DEFLATED
                )
                out.writestr(info.filename, data, compress_type=compress)
