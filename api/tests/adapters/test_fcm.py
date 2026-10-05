import asyncio
import json

import httpx
import jwt
import pytest
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa

from babel_api.adapters.push.fcm import FcmPusher

KEY = rsa.generate_private_key(public_exponent=65537, key_size=2048)
PEM = KEY.private_bytes(
    serialization.Encoding.PEM,
    serialization.PrivateFormat.PKCS8,
    serialization.NoEncryption(),
).decode()
CREDENTIALS = {
    "project_id": "babel-test",
    "client_email": "push@babel-test.iam.gserviceaccount.com",
    "private_key": PEM,
    "token_uri": "https://oauth2.googleapis.com/token",
}


class Google:
    def __init__(self, answer: httpx.Response | None = None) -> None:
        self.answer = answer
        self.token_requests = 0
        self.messages: list[dict[str, object]] = []

    def __call__(self, request: httpx.Request) -> httpx.Response:
        if request.url.host == "oauth2.googleapis.com":
            self.token_requests += 1
            form = dict(x.split("=", 1) for x in request.content.decode().split("&"))
            claims = jwt.decode(
                form["assertion"],
                KEY.public_key(),
                algorithms=["RS256"],
                audience=CREDENTIALS["token_uri"],
            )
            assert claims["iss"] == CREDENTIALS["client_email"]
            return httpx.Response(200, json={"access_token": "ya29.token", "expires_in": 3600})
        assert request.url.path == "/v1/projects/babel-test/messages:send"
        assert request.headers["Authorization"] == "Bearer ya29.token"
        self.messages.append(json.loads(request.content)["message"])
        return self.answer or httpx.Response(200, json={"name": "projects/babel-test/m/1"})


def pusher(google: Google) -> FcmPusher:
    return FcmPusher(CREDENTIALS, httpx.AsyncClient(transport=httpx.MockTransport(google)))


def test_sends_a_notification_with_a_cached_access_token() -> None:
    google = Google()
    fcm = pusher(google)

    async def both() -> tuple[bool, bool]:
        return (
            await fcm.send("device-1", "New chapter", "Arcane · 4/?", {"item_id": "i1"}),
            await fcm.send("device-2", "New chapter", "Arcane · 5/?", {"item_id": "i1"}),
        )

    assert asyncio.run(both()) == (True, True)

    assert google.token_requests == 1
    assert google.messages[0] == {
        "token": "device-1",
        "notification": {"title": "New chapter", "body": "Arcane · 4/?"},
        "data": {"item_id": "i1"},
        "android": {"notification": {"tag": "i1"}},
    }


def test_an_unregistered_device_is_reported() -> None:
    gone = httpx.Response(
        404,
        json={
            "error": {
                "status": "NOT_FOUND",
                "details": [{"@type": "…FcmError", "errorCode": "UNREGISTERED"}],
            }
        },
    )
    assert asyncio.run(pusher(Google(gone)).send("old", "t", "b", {})) is False


def test_other_errors_are_raised() -> None:
    with pytest.raises(httpx.HTTPStatusError):
        asyncio.run(pusher(Google(httpx.Response(500))).send("t", "t", "b", {}))
