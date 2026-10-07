import asyncio
import threading
from http.server import BaseHTTPRequestHandler, HTTPServer

import httpx

from babel_api.adapters.sources.stdlib_transport import StdlibTransport


class _Handler(BaseHTTPRequestHandler):
    def log_message(self, format: str, *args: object) -> None:
        return None

    def do_GET(self) -> None:
        if self.path == "/old":
            self.send_response(302)
            self.send_header("Location", "/login")
            self.end_headers()
            return
        body = b"hello " + self.headers.get("User-Agent", "").encode()
        self.send_response(200 if self.path == "/login" else 403)
        self.send_header("Set-Cookie", "a=1")
        self.send_header("Set-Cookie", "b=2")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self) -> None:
        data = self.rfile.read(int(self.headers.get("Content-Length", 0)))
        self.send_response(200)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)


def test_requests_go_through_the_standard_client_with_redirects_cookies_and_forms() -> None:
    server = HTTPServer(("127.0.0.1", 0), _Handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    base = f"http://127.0.0.1:{server.server_port}"

    async def run() -> None:
        async with httpx.AsyncClient(
            transport=StdlibTransport(5),
            base_url=base,
            follow_redirects=True,
            headers={"User-Agent": "Babel/test"},
        ) as client:
            page = await client.get("/old")  # redirected by httpx, answered by urllib
            assert page.status_code == 200
            assert page.text == "hello Babel/test"
            assert client.cookies["a"] == "1"
            assert client.cookies["b"] == "2"  # both Set-Cookie headers survive
            form = await client.post("/x", data={"user[login]": "ada"})
            assert form.text == "user%5Blogin%5D=ada"
            assert (await client.get("/forbidden")).status_code == 403

    try:
        asyncio.run(run())
    finally:
        server.shutdown()
