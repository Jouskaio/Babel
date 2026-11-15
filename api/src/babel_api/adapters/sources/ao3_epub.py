"""An EPUB built from Archive of Our Own's HTML download.

AO3 sometimes offers only its HTML download (after its November 2026 outage, EPUB, MOBI,
AZW3 and PDF were turned off for weeks). The HTML file holds every chapter. Babel wraps
it in a plain EPUB 3, with the work page's metadata in the package, the same metadata
AO3's own EPUB carries: title, authors, tags as subjects, summary, series and the work's
address. The rest of Babel reads it like any AO3 EPUB.
"""

import io
import re
import zipfile
from html import escape
from uuid import NAMESPACE_URL, uuid5

from bs4 import BeautifulSoup, Tag

from babel_api.domain.sources import FanficDetails

# AO3 shows a work's language by its own name.
_LANGUAGES = {
    "english": "en",
    "français": "fr",
    "francais": "fr",
    "español": "es",
    "deutsch": "de",
    "italiano": "it",
    "português brasileiro": "pt",
    "português europeu": "pt",
    "português": "pt",
    "nederlands": "nl",
    "polski": "pl",
    "русский": "ru",
    "українська": "uk",
    "中文-普通话 國語": "zh",
    "中文": "zh",
    "日本語": "ja",
    "한국어": "ko",
    "svenska": "sv",
    "norsk": "no",
    "dansk": "da",
    "suomi": "fi",
    "čeština": "cs",
    "magyar": "hu",
    "türkçe": "tr",
    "bahasa indonesia": "id",
    "tiếng việt": "vi",
}
# Never in a book: what could run code or reach the network.
_DROPPED = ("script", "style", "iframe", "object", "embed", "form", "input", "button", "link")
_XHTML = (
    '<?xml version="1.0" encoding="utf-8"?>\n<!DOCTYPE html>\n'
    '<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops"'
    ' lang="{lang}" xml:lang="{lang}"><head><meta charset="utf-8"/><title>{title}</title>'
    "</head><body>{body}</body></html>"
)


def language_code(name: str | None) -> str:
    if not name:
        return "und"
    return _LANGUAGES.get(name.strip().lower(), "und")


def _clean(tag: Tag) -> None:
    """Strip what does not belong in a book; an image (hosted elsewhere) becomes its text."""
    for dropped in tag.find_all(_DROPPED):
        dropped.decompose()
    for image in tag.find_all("img"):
        alt = str(image.get("alt") or "").strip()
        image.replace_with(f"[{alt}]" if alt else "")
    for element in [tag, *tag.find_all(True)]:
        for name in list(element.attrs):
            key = name.lower()
            unsafe_link = key == "href" and str(element.attrs[name]).strip().lower().startswith(
                ("javascript:", "data:")
            )
            if key.startswith("on") or key in {"style", "src"} or unsafe_link:
                del element.attrs[name]


def _xhtml(tag: Tag) -> str:
    # bs4 closes void elements (<br/>) and quotes attributes: well-formed XML.
    return "".join(child.decode(formatter="minimal") for child in tag.children)  # type: ignore[union-attr]


def chapters(html: bytes) -> list[tuple[str, str]]:
    """The work's chapters as (heading, XHTML body), in reading order."""
    soup = BeautifulSoup(html, "html.parser")
    root = soup.select_one("#chapters") or soup.body or soup
    _clean(root)
    found: list[tuple[str, str]] = []
    heading: str | None = None
    parts: list[str] = []
    for child in root.children:
        if not isinstance(child, Tag):
            continue
        classes = child.get("class")
        if classes is not None and "meta" in classes:
            # A chapter starts with its heading (and the author's notes).
            if heading is not None or parts:
                found.append((heading or "", "".join(parts)))
            title = child.select_one("h2.heading")
            heading = title.get_text(" ", strip=True) if title else ""
            parts = [child.decode(formatter="minimal")]
        else:
            parts.append(child.decode(formatter="minimal"))
    if heading is not None or parts:
        found.append((heading or "", "".join(parts)))
    if not found:
        found.append(("", _xhtml(root)))
    return found


def build_epub(
    work_id: str, details: FanficDetails, html: bytes, *, series_index: str | None = None
) -> bytes:
    """An EPUB 3 of the work: its chapters from the HTML download, metadata from its page."""
    lang = language_code(details.language)
    title = escape(details.title)
    address = f"https://archiveofourown.org/works/{work_id}"
    found = chapters(html)
    meta = [
        f'<dc:identifier id="id">urn:uuid:{uuid5(NAMESPACE_URL, address)}</dc:identifier>',
        f"<dc:title>{title}</dc:title>",
        f"<dc:language>{lang}</dc:language>",
        f"<dc:source>{address}</dc:source>",
        "<dc:publisher>Archive of Our Own</dc:publisher>",
        '<meta property="dcterms:modified">2000-01-01T00:00:00Z</meta>',
        *(f"<dc:creator>{escape(a)}</dc:creator>" for a in details.authors),
    ]
    subjects = (
        *details.fandoms,
        *details.relationships,
        *details.characters,
        *details.tags,
    )
    meta += [f"<dc:subject>{escape(s)}</dc:subject>" for s in dict.fromkeys(subjects)]
    if details.summary:
        meta.append(f"<dc:description>{escape(details.summary)}</dc:description>")
    if details.series:
        meta.append(f'<meta name="calibre:series" content="{escape(details.series)}"/>')
        if series_index:
            meta.append(f'<meta name="calibre:series_index" content="{escape(series_index)}"/>')

    preface = [f"<h1>{title}</h1>"]
    if details.authors:
        preface.append(f"<p>by {escape(', '.join(details.authors))}</p>")
    preface.append(f'<p><a href="{address}">{address}</a></p>')
    if details.summary:
        preface.append(f"<h2>Summary</h2><blockquote><p>{escape(details.summary)}</p></blockquote>")

    pages = [("title.xhtml", details.title, "".join(preface))]
    for number, (heading, body) in enumerate(found, start=1):
        pages.append((f"chapter{number:04d}.xhtml", heading or f"Chapter {number}", body))

    manifest = "".join(
        f'<item id="p{i}" href="{name}" media-type="application/xhtml+xml"/>'
        for i, (name, _, _) in enumerate(pages)
    )
    spine = "".join(f'<itemref idref="p{i}"/>' for i in range(len(pages)))
    package = (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="id">'
        '<metadata xmlns:dc="http://purl.org/dc/elements/1.1/">'
        + "".join(meta)
        + "</metadata><manifest>"
        '<item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>'
        + manifest
        + "</manifest><spine>"
        + spine
        + "</spine></package>"
    )
    links = "".join(
        f'<li><a href="{name}">{escape(label)}</a></li>' for name, label, _ in pages[1:]
    )
    nav = _XHTML.format(
        lang=lang,
        title=title,
        body=f'<nav epub:type="toc" id="toc"><h1>{title}</h1><ol>{links}</ol></nav>',
    )
    out = io.BytesIO()
    with zipfile.ZipFile(out, "w") as archive:
        # The mimetype comes first, uncompressed: how a reader knows the file is an EPUB.
        archive.writestr("mimetype", "application/epub+zip", compress_type=zipfile.ZIP_STORED)
        archive.writestr(
            "META-INF/container.xml",
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">'
            '<rootfiles><rootfile full-path="OEBPS/content.opf"'
            ' media-type="application/oebps-package+xml"/></rootfiles></container>',
            compress_type=zipfile.ZIP_DEFLATED,
        )
        archive.writestr("OEBPS/content.opf", package, compress_type=zipfile.ZIP_DEFLATED)
        archive.writestr("OEBPS/nav.xhtml", nav, compress_type=zipfile.ZIP_DEFLATED)
        for name, label, body in pages:
            page = _XHTML.format(lang=lang, title=escape(label), body=body)
            archive.writestr(f"OEBPS/{name}", page, compress_type=zipfile.ZIP_DEFLATED)
    return out.getvalue()


_POSITION = re.compile(r"Part\s+(\d+)", re.IGNORECASE)


def series_position(text: str) -> str | None:
    """The part a work is in its series ("Part 2 of the Rivers series" -> "2")."""
    found = _POSITION.search(text)
    return found.group(1) if found else None
