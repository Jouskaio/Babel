"""An httpx transport that sends requests with Python's standard HTTP client.

Archive of Our Own's front (Cloudflare) answers 403 to httpx's connection signature, even for
a polite, identified client, and accepts the standard library's. Same requests, same honest
User-Agent: only the library that opens the connection differs. Redirects and cookies stay
with httpx (this transport never follows a redirect), and the body is asked unencoded.
"""

import asyncio
import urllib.error
import urllib.request
from typing import Any

import httpx


class _NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *args: Any, **kwargs: Any) -> None:
        return None  # httpx follows redirects, hop by hop


class StdlibTransport(httpx.AsyncBaseTransport):
    def __init__(self, timeout: float = 30.0) -> None:
        self._timeout = timeout
        self._opener = urllib.request.build_opener(_NoRedirect)

    def _send(self, request: httpx.Request, body: bytes) -> httpx.Response:
        if request.url.scheme not in {"http", "https"}:  # never file: or a custom scheme
            raise httpx.UnsupportedProtocol(f"unsupported scheme {request.url.scheme!r}")
        headers = {
            k: v for k, v in request.headers.items() if k.lower() not in {"connection", "host"}
        }
        headers["Accept-Encoding"] = "identity"
        sent = urllib.request.Request(  # noqa: S310 - http(s) only, checked above
            str(request.url), data=body or None, method=request.method, headers=headers
        )
        try:
            answer: Any = self._opener.open(sent, timeout=self._timeout)
        except urllib.error.HTTPError as error:  # 3xx, 4xx and 5xx are answers too
            answer = error
        except (urllib.error.URLError, TimeoutError, OSError) as error:
            raise httpx.ConnectError(str(error), request=request) from error
        with answer:
            content = answer.read()
            status = int(answer.status if hasattr(answer, "status") else answer.code)
            raw = [(k.encode(), v.encode()) for k, v in answer.headers.items()]
        return httpx.Response(status, headers=raw, content=content, request=request)

    async def handle_async_request(self, request: httpx.Request) -> httpx.Response:
        body = await request.aread()
        return await asyncio.to_thread(self._send, request, body)
