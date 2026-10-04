"""HTTP for connectors reaching addresses chosen by readers (OPDS, WebDAV).

Every request, redirects included, is checked: addresses on private networks (the
server's LAN, loopback, link-local, cloud metadata…) are refused unless the operator
allows the host explicitly (``BABEL_SOURCE_ALLOWED_HOSTS``), so a source cannot be used
to probe what the server can reach (ADR 0009, Limits).
"""

import asyncio
import ipaddress
import socket
from collections.abc import Iterable
from urllib.parse import urlsplit

import httpx

from babel_api.domain.errors import SourceAddressBlockedError, SourceConnectionError

USER_AGENT = "Babel/1.0 (+https://babel.jouskaio.me; personal library)"
TIMEOUT = httpx.Timeout(30.0, connect=10.0)


def _is_public(address: str) -> bool:
    ip = ipaddress.ip_address(address)
    if isinstance(ip, ipaddress.IPv6Address) and ip.ipv4_mapped:
        ip = ip.ipv4_mapped
    return ip.is_global and not ip.is_multicast


async def check_url(url: str, allowed_hosts: Iterable[str] = ()) -> None:
    """Refuses non-HTTP URLs and hosts resolving to non-public addresses."""
    parts = urlsplit(url)
    host = (parts.hostname or "").lower()
    if parts.scheme not in ("http", "https") or not host:
        raise SourceConnectionError("url")
    if host in {h.lower() for h in allowed_hosts}:
        return
    try:
        infos = await asyncio.get_running_loop().getaddrinfo(
            host, parts.port or (443 if parts.scheme == "https" else 80), type=socket.SOCK_STREAM
        )
    except OSError as error:
        raise SourceConnectionError("unreachable") from error
    if not infos or not all(_is_public(str(info[4][0])) for info in infos):
        raise SourceAddressBlockedError


def guarded_client(allowed_hosts: Iterable[str] = ()) -> httpx.AsyncClient:
    allowed = tuple(allowed_hosts)

    async def check(request: httpx.Request) -> None:
        await check_url(str(request.url), allowed)

    return httpx.AsyncClient(
        timeout=TIMEOUT,
        follow_redirects=True,
        headers={"User-Agent": USER_AGENT},
        event_hooks={"request": [check]},
    )


def book_format(name: str, media_type: str | None = None) -> str | None:
    """epub, pdf, cbz or cbr from a media type or a file name; None for anything else."""
    media = (media_type or "").split(";")[0].strip().lower()
    by_media = {
        "application/epub+zip": "epub",
        "application/pdf": "pdf",
        "application/vnd.comicbook+zip": "cbz",
        "application/x-cbz": "cbz",
        "application/vnd.comicbook-rar": "cbr",
        "application/x-cbr": "cbr",
    }
    if media in by_media:
        return by_media[media]
    suffix = name.lower().rsplit(".", 1)[-1] if "." in name else ""
    return suffix if suffix in ("epub", "pdf", "cbz", "cbr") else None
