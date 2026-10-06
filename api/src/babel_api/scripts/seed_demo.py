"""Fills a local development API with demo readers, books and social activity.

Usage (API running on http://127.0.0.1:8000, on a throwaway database)::

    uv run python -m babel_api.scripts.seed_demo [API URL]

Demo accounts, all with the password ``babel-demo-2026``: ada@example.com (@ada),
bob@example.com (@bob), camille@example.com (@camille). Never point it at production.
"""

import io
import struct
import sys
import uuid
import zipfile
import zlib
from datetime import UTC, datetime, timedelta
from typing import Any

import httpx

PASSWORD = "babel-demo-2026"  # noqa: S105 - local demo accounts only
READERS = {"ada": "Ada", "bob": "Bob", "camille": "Camille"}


def _png(width: int, height: int, color: tuple[int, int, int], stripe: int) -> bytes:
    """A plain PNG with a darker band, so pages look different."""
    rows = b""
    for y in range(height):
        shade = 0.6 if (y // stripe) % 2 else 1.0
        pixel = bytes(int(c * shade) for c in color)
        rows += b"\x00" + pixel * width

    def chunk(kind: bytes, data: bytes) -> bytes:
        return (
            struct.pack(">I", len(data))
            + kind
            + data
            + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)
        )

    header = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    return (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", header)
        + chunk(b"IDAT", zlib.compress(rows))
        + chunk(b"IEND", b"")
    )


def _epub(title: str, author: str, chapters: list[tuple[str, str]]) -> bytes:
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, "w") as epub:
        epub.writestr("mimetype", "application/epub+zip", compress_type=zipfile.ZIP_STORED)
        epub.writestr(
            "META-INF/container.xml",
            '<?xml version="1.0"?><container version="1.0" '
            'xmlns="urn:oasis:names:tc:opendocument:xmlns:container"><rootfiles>'
            '<rootfile full-path="OEBPS/content.opf" '
            'media-type="application/oebps-package+xml"/></rootfiles></container>',
        )
        manifest = "".join(
            f'<item id="c{i}" href="c{i}.xhtml" media-type="application/xhtml+xml"/>'
            for i in range(len(chapters))
        )
        spine = "".join(f'<itemref idref="c{i}"/>' for i in range(len(chapters)))
        epub.writestr(
            "OEBPS/content.opf",
            '<?xml version="1.0"?><package xmlns="http://www.idpf.org/2007/opf" version="3.0" '
            'unique-identifier="id"><metadata xmlns:dc="http://purl.org/dc/elements/1.1/">'
            f'<dc:identifier id="id">urn:uuid:{uuid.uuid5(uuid.NAMESPACE_URL, title)}'
            f"</dc:identifier><dc:title>{title}</dc:title><dc:creator>{author}</dc:creator>"
            f"<dc:language>fr</dc:language></metadata><manifest>{manifest}</manifest>"
            f"<spine>{spine}</spine></package>",
        )
        for i, (name, text) in enumerate(chapters):
            paragraphs = "".join(f"<p>{p}</p>" for p in text.split("\n\n"))
            epub.writestr(
                f"OEBPS/c{i}.xhtml",
                '<html xmlns="http://www.w3.org/1999/xhtml"><body>'
                f"<h1>{name}</h1>{paragraphs}</body></html>",
            )
    return buffer.getvalue()


def _cbz(pages: int, manga: bool) -> bytes:
    buffer = io.BytesIO()
    colors = [(200, 164, 101), (196, 144, 146), (125, 38, 56), (79, 163, 107)]
    with zipfile.ZipFile(buffer, "w") as cbz:
        for page in range(1, pages + 1):
            cbz.writestr(f"page{page}.png", _png(600, 900, colors[page % 4], 60 + page * 10))
        if manga:
            cbz.writestr(
                "ComicInfo.xml",
                '<?xml version="1.0"?><ComicInfo><Manga>YesAndRightToLeft</Manga></ComicInfo>',
            )
    return buffer.getvalue()


HEIGHTS = (
    "Mon amour pour Linton est comme le feuillage des bois : le temps le changera, je le "
    "sais bien, comme l’hiver change les arbres.\n\nMon amour pour Heathcliff ressemble aux "
    "rochers éternels qui sont dessous. Nelly, je suis Heathcliff !\n\nIl est toujours, "
    "toujours présent à mon esprit ; non comme un plaisir, mais comme mon propre être."
)


def main() -> int:
    api = sys.argv[1] if len(sys.argv) > 1 else "http://127.0.0.1:8000"
    if "babel.jouskaio.me" in api:
        print("Refusing to seed production.")
        return 1
    client = httpx.Client(base_url=api, timeout=30)
    auth: dict[str, dict[str, str]] = {}
    for handle, name in READERS.items():
        email = f"{handle}@example.com"
        response = client.post(
            "/v1/auth/register",
            json={"email": email, "password": PASSWORD, "display_name": name},
        )
        if response.status_code == 409:
            response = client.post("/v1/auth/login", json={"email": email, "password": PASSWORD})
        response.raise_for_status()
        auth[handle] = {"Authorization": f"Bearer {response.json()['access_token']}"}
        client.patch("/v1/me/profile", json={"handle": handle}, headers=auth[handle])

    def books(handle: str) -> dict[str, str]:
        return {
            item["title"]: item["id"]
            for item in client.get("/v1/library", headers=auth[handle]).json()
        }

    def upload(handle: str, name: str, content: bytes) -> None:
        client.post("/v1/library/files", files={"file": (name, content)}, headers=auth[handle])

    upload(
        "ada",
        "hurlevent.epub",
        _epub(
            "Les Hauts de Hurle-Vent",
            "Emily Brontë",
            [("Chapitre XII", HEIGHTS), ("Chapitre XIII", HEIGHTS)],
        ),
    )
    upload("ada", "akira.cbz", _cbz(6, manga=True))
    upload(
        "camille",
        "jane-eyre.epub",
        _epub("Jane Eyre", "Charlotte Brontë", [("Chapitre I", HEIGHTS)]),
    )
    upload("camille", "arcane.cbz", _cbz(4, manga=False))

    # Friends: Ada and Camille; Bob asked Ada; Bob follows Camille.
    client.put("/v1/social/friends/camille", headers=auth["ada"])
    client.put("/v1/social/friends/ada", headers=auth["camille"])
    client.put("/v1/social/friends/ada", headers=auth["bob"])
    client.put("/v1/social/following/camille", headers=auth["bob"])

    camille = books("camille")
    device = client.post(
        "/v1/devices", json={"name": "Demo", "kind": "phone"}, headers=auth["camille"]
    ).json()["id"]
    now = datetime.now(UTC)

    def op(entity: str, entity_id: str, data: dict[str, Any]) -> dict[str, Any]:
        return {
            "key": str(uuid.uuid4()),
            "entity": entity,
            "entity_id": entity_id,
            "op": "upsert",
            "data": data,
        }

    jane = camille.get("Jane Eyre") or next(iter(camille.values()))
    client.post(
        f"/v1/sync/{device}",
        json={
            "operations": [
                op(
                    "reading_position",
                    jane,
                    {
                        "item_id": jane,
                        "locator": "epub:0:0.6",
                        "percent": 63.0,
                        "client_time": (now - timedelta(hours=2)).isoformat(),
                    },
                ),
                op(
                    "annotation",
                    str(uuid.uuid4()),
                    {
                        "item_id": jane,
                        "chapter": 0,
                        "quote": "Nelly, je suis Heathcliff !",
                        "color": "rose",
                        "note": "Cette phrase m’a fait poser le livre.",
                        "visibility": "friends",
                        "client_time": now.isoformat(),
                    },
                ),
            ]
        },
        headers=auth["camille"],
    )
    client.put(
        f"/v1/library/{jane}/review",
        json={"rating": 4, "text": "Lecteur, je l’ai adoré.", "audience": "public"},
        headers=auth["camille"],
    )
    client.post(
        "/v1/social/recommendations",
        json={
            "to": "ada",
            "item_id": jane,
            "message": "Tu vas adorer Rochester.",
        },
        headers=auth["camille"],
    )
    print(f"Seeded {api}: {', '.join(f'{h}@example.com' for h in READERS)} / {PASSWORD}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
