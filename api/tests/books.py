"""Small, valid book files built in memory for tests."""

import io
import zipfile


def epub(
    title: str = "Jane Eyre",
    author: str = "Charlotte Brontë",
    isbn: str | None = "9782070360246",
    opf_extra: str = "",
    cover: bytes | None = None,
    cover_style: str = "epub3",
) -> bytes:
    """A minimal EPUB; ``cover`` adds a JPEG cover declared the EPUB 3 or EPUB 2 way."""
    identifier = f"<dc:identifier>urn:isbn:{isbn}</dc:identifier>" if isbn else ""
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, "w") as archive:
        archive.writestr("mimetype", "application/epub+zip", compress_type=zipfile.ZIP_STORED)
        archive.writestr(
            "META-INF/container.xml",
            '<?xml version="1.0"?><container version="1.0" '
            'xmlns="urn:oasis:names:tc:opendocument:xmlns:container"><rootfiles>'
            '<rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>'
            "</rootfiles></container>",
        )
        archive.writestr(
            "OEBPS/content.opf",
            f'<?xml version="1.0"?>{opf_extra}<package xmlns="http://www.idpf.org/2007/opf" '
            'version="3.0"><metadata xmlns:dc="http://purl.org/dc/elements/1.1/">'
            f"<dc:title>{title}</dc:title><dc:creator>{author}</dc:creator>"
            f"{identifier}<dc:language>fr-FR</dc:language>{_cover_meta(cover, cover_style)}"
            f"</metadata>{_manifest(cover, cover_style)}</package>",
        )
        if cover is not None:
            archive.writestr("OEBPS/images/cover art.jpg", cover)
        archive.writestr(
            "OEBPS/chapter1.xhtml", "<html><body><p>Reader, I married him.</p></body></html>"
        )
    return buffer.getvalue()


def _cover_meta(cover: bytes | None, style: str) -> str:
    return '<meta name="cover" content="cov"/>' if cover and style == "epub2" else ""


def _manifest(cover: bytes | None, style: str) -> str:
    if cover is None:
        return ""
    properties = ' properties="cover-image"' if style == "epub3" else ""
    return (
        '<manifest><item id="cov" href="images/cover%20art.jpg" media-type="image/jpeg"'
        f"{properties}/></manifest>"
    )


JPEG = b"\xff\xd8\xff\xe0" + b"cover" * 20


def cbz() -> bytes:
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, "w") as archive:
        archive.writestr("001.jpg", b"\xff\xd8\xff" + b"0" * 100)
    return buffer.getvalue()


PDF = b"%PDF-1.4\n1 0 obj << >> endobj\ntrailer << >>\n%%EOF\n"
CBR = b"Rar!\x1a\x07\x00" + b"0" * 64
NOT_A_BOOK = b"MZ\x90\x00 definitely an executable"
