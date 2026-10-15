"""A WebDAV view of the reader's library, for KOReader's cloud storage.

In KOReader: Cloud storage > + > WebDAV, address https://<babel>/api/v1/webdav, the e-mail and the
KOReader password made in Babel. The folder lists the books of the library (to download them to
the e-reader); sending a file into it (menu > Upload file) imports it into the library, where
duplicates are recognised and fanfictions of AO3 too. Basic authentication, like the sync.
"""

import base64
import hashlib
from datetime import UTC
from email.utils import format_datetime
from pathlib import Path, PurePosixPath
from urllib.parse import quote
from uuid import UUID
from xml.sax.saxutils import escape

from fastapi import APIRouter, HTTPException, Request, Response, status
from fastapi.responses import FileResponse

from babel_api.api.dependencies import FileServiceDep, KoreaderServiceDep
from babel_api.domain.files import LibraryItem

router = APIRouter(prefix="/webdav", tags=["webdav"], include_in_schema=False)

# The Babel plugin for KOReader, offered as a folder: an e-reader without a file manager that can
# unzip downloads the two files straight into koreader/plugins/babel.koplugin.
PLUGIN = "babel.koplugin"
_PLUGIN_DIR = Path(__file__).resolve().parents[3] / "plugins" / "koreader" / PLUGIN

_METHODS = ["OPTIONS", "PROPFIND", "GET", "HEAD", "PUT", "MKCOL", "DELETE", "MOVE", "COPY"]
_ALLOW = "OPTIONS, PROPFIND, GET, HEAD, PUT"
_CHUNK = 1 << 20


def _unauthorized() -> HTTPException:
    return HTTPException(
        status.HTTP_401_UNAUTHORIZED,
        "Unauthorized",
        headers={"WWW-Authenticate": 'Basic realm="Babel"'},
    )


async def _reader(request: Request, koreader: KoreaderServiceDep) -> UUID:
    header = request.headers.get("authorization", "")
    if not header.lower().startswith("basic "):
        raise _unauthorized()
    try:
        decoded = base64.b64decode(header[6:]).decode()
    except ValueError:
        raise _unauthorized() from None
    username, _, password = decoded.partition(":")
    key = hashlib.md5(password.encode(), usedforsecurity=False).hexdigest()
    user_id = await koreader.authenticate(username, key)
    if user_id is None:
        raise _unauthorized()
    return user_id


def _plugin_files() -> dict[str, Path]:
    if not _PLUGIN_DIR.is_dir():
        return {}
    # Listed as .txt (KOReader's cloud browser hides file types it cannot open, such as .lua);
    # the real names are served too.
    found = {p.name + ".txt": p for p in sorted(_PLUGIN_DIR.iterdir()) if p.suffix == ".lua"}
    return found | {path.name: path for path in found.values()}


def _plugin_entry(base: str, name: str | None) -> str:
    """The plugin folder (name None) or one of its files, as a WebDAV response."""
    if name is None:
        return (
            f"<D:response><D:href>{escape(base + '/' + PLUGIN)}/</D:href><D:propstat><D:prop>"
            f"<D:displayname>{PLUGIN}</D:displayname><D:resourcetype><D:collection/>"
            "</D:resourcetype></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat>"
            "</D:response>"
        )
    path = _plugin_files()[name]
    return (
        f"<D:response><D:href>{escape(base + '/' + PLUGIN + '/' + quote(name))}</D:href>"
        f"<D:propstat><D:prop><D:displayname>{escape(name)}</D:displayname><D:resourcetype/>"
        f"<D:getcontentlength>{path.stat().st_size}</D:getcontentlength>"
        "<D:getcontenttype>text/plain</D:getcontenttype></D:prop>"
        "<D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>"
    )


def _named(items: list[LibraryItem]) -> dict[str, LibraryItem]:
    """The files of the library by name; two books with one name keep both, told apart."""
    named: dict[str, LibraryItem] = {}
    for item in sorted(items, key=lambda i: i.added_at):
        if item.file is None or item.removed_at is not None:
            continue
        name = PurePosixPath(item.file.original_name).name or f"{item.file.sha256}.epub"
        if name in named:
            path = PurePosixPath(name)
            name = f"{path.stem} ({item.file.sha256[:6]}){path.suffix}"
        named[name] = item
    return named


def _entry(base: str, name: str, item: LibraryItem | None) -> str:
    if item is None or item.file is None:
        return (
            f"<D:response><D:href>{escape(base)}/</D:href><D:propstat><D:prop>"
            "<D:displayname>Babel</D:displayname><D:resourcetype><D:collection/></D:resourcetype>"
            "</D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>"
        )
    return (
        f"<D:response><D:href>{escape(base + '/' + quote(name))}</D:href><D:propstat><D:prop>"
        f"<D:displayname>{escape(name)}</D:displayname><D:resourcetype/>"
        f"<D:getcontentlength>{item.file.size}</D:getcontentlength>"
        f"<D:getcontenttype>{item.file.format.media_type}</D:getcontenttype>"
        f"<D:getlastmodified>{format_datetime(item.added_at.astimezone(UTC), usegmt=True)}"
        "</D:getlastmodified>"
        f'<D:getetag>"{item.file.sha256}"</D:getetag>'
        "</D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response>"
    )


def _multistatus(body: str) -> Response:
    xml = (
        '<?xml version="1.0" encoding="utf-8"?>'
        f'<D:multistatus xmlns:D="DAV:">{body}</D:multistatus>'
    )
    return Response(xml, status_code=207, media_type="application/xml; charset=utf-8")


@router.api_route("", methods=_METHODS, include_in_schema=False)
@router.api_route("/{name:path}", methods=_METHODS, include_in_schema=False)
async def webdav(
    request: Request,
    koreader: KoreaderServiceDep,
    files: FileServiceDep,
    name: str = "",
) -> Response:
    method = request.method
    if method == "OPTIONS":
        return Response(status_code=200, headers={"DAV": "1", "Allow": _ALLOW})
    user_id = await _reader(request, koreader)
    parts = [p for p in name.strip("/").split("/") if p]
    leaf = PurePosixPath(name.strip("/")).name
    base = f"{request.scope.get('root_path', '')}/v1/webdav".replace("//", "/")

    if parts and parts[0] == PLUGIN and method in ("PROPFIND", "GET", "HEAD"):
        files_in = _plugin_files()
        if len(parts) == 1:
            if method != "PROPFIND" or not files_in:
                raise HTTPException(status.HTTP_404_NOT_FOUND, "No such folder")
            body = _plugin_entry(base, None)
            if request.headers.get("depth", "1") != "0":
                body += "".join(_plugin_entry(base, n) for n in files_in if n.endswith(".txt"))
            return _multistatus(body)
        found = files_in.get(parts[1]) if len(parts) == 2 else None
        if found is None:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "No such file")
        if method == "PROPFIND":
            return _multistatus(_plugin_entry(base, parts[1]))
        if method == "HEAD":
            return Response(
                status_code=200,
                headers={
                    "Content-Length": str(found.stat().st_size),
                    "Content-Type": "text/plain",
                },
            )
        return FileResponse(found, media_type="text/plain", filename=parts[1])

    if method == "PUT":
        if not leaf:
            raise HTTPException(status.HTTP_405_METHOD_NOT_ALLOWED, "Not a file")

        async def chunks():
            async for chunk in request.stream():
                if chunk:
                    yield chunk

        await files.import_file(user_id, chunks(), leaf)
        return Response(status_code=status.HTTP_201_CREATED)

    if method in ("MKCOL", "DELETE", "MOVE", "COPY"):
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Not supported")

    named = _named(await files.library(user_id))
    if method == "PROPFIND":
        depth = request.headers.get("depth", "1")
        if leaf:
            if leaf not in named:
                raise HTTPException(status.HTTP_404_NOT_FOUND, "No such file")
            body = _entry(base, leaf, named[leaf])
        else:
            body = _entry(base, "", None)
            if depth != "0":
                if _plugin_files():
                    body += _plugin_entry(base, None)
                body += "".join(_entry(base, n, i) for n, i in named.items())
        return _multistatus(body)

    # GET and HEAD
    item = named.get(leaf)
    if item is None or item.file is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "No such file")
    download = await files.download(user_id, item.file.sha256)
    response = FileResponse(
        download.path,
        media_type=download.file.format.media_type,
        filename=leaf,
        headers={"ETag": f'"{download.file.sha256}"'},
    )
    if method == "HEAD":
        return Response(
            status_code=200,
            headers={
                "Content-Length": str(download.file.size),
                "Content-Type": download.file.format.media_type,
            },
        )
    return response
