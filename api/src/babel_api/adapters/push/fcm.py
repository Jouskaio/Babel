"""Firebase Cloud Messaging (HTTP v1), authenticated with a service account.

The service account JSON comes from the Firebase console (Project settings → Service
accounts). Without it, notifications are only logged.
"""

import json
import logging
import time
from pathlib import Path
from typing import Any

import httpx
import jwt

logger = logging.getLogger(__name__)

TOKEN_URL = "https://oauth2.googleapis.com/token"  # noqa: S105 - endpoint, not a secret
SCOPE = "https://www.googleapis.com/auth/firebase.messaging"
# Answers meaning the device token will never work again.
_GONE = {"UNREGISTERED", "NOT_FOUND"}


class LogPusher:
    """Development: notifications are written to the log."""

    async def send(self, token: str, title: str, body: str, data: dict[str, str]) -> bool:
        logger.info("Push to %s…: %s · %s", token[:12], title, body)
        return True

    async def aclose(self) -> None:
        pass


class FcmPusher:
    def __init__(
        self, credentials: dict[str, Any], client: httpx.AsyncClient | None = None
    ) -> None:
        self._project = str(credentials["project_id"])
        self._email = str(credentials["client_email"])
        self._key = str(credentials["private_key"])
        self._token_url = str(credentials.get("token_uri") or TOKEN_URL)
        self._client = client or httpx.AsyncClient(timeout=15)
        self._access: tuple[str, float] | None = None

    @classmethod
    def from_file(cls, path: str) -> "FcmPusher":
        return cls(json.loads(Path(path).read_text(encoding="utf-8")))

    async def _access_token(self) -> str:
        now = time.time()
        if self._access and self._access[1] > now + 60:
            return self._access[0]
        assertion = jwt.encode(
            {
                "iss": self._email,
                "scope": SCOPE,
                "aud": self._token_url,
                "iat": int(now),
                "exp": int(now) + 3600,
            },
            self._key,
            algorithm="RS256",
        )
        response = await self._client.post(
            self._token_url,
            data={
                "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                "assertion": assertion,
            },
        )
        response.raise_for_status()
        body = response.json()
        self._access = (str(body["access_token"]), now + float(body.get("expires_in", 3600)))
        return self._access[0]

    async def send(self, token: str, title: str, body: str, data: dict[str, str]) -> bool:
        """Sends one notification. False when the device token is no longer valid."""
        response = await self._client.post(
            f"https://fcm.googleapis.com/v1/projects/{self._project}/messages:send",
            headers={"Authorization": f"Bearer {await self._access_token()}"},
            json={
                "message": {
                    "token": token,
                    "notification": {"title": title, "body": body},
                    "data": data,
                    # One notification per book: a newer chapter replaces the previous one.
                    "android": {"notification": {"tag": data.get("item_id", "babel")}},
                }
            },
        )
        if response.status_code == 404 or _error_code(response) in _GONE:
            return False
        response.raise_for_status()
        return True

    async def aclose(self) -> None:
        await self._client.aclose()


def _error_code(response: httpx.Response) -> str | None:
    if response.status_code < 400:
        return None
    try:
        details = response.json()["error"].get("details", [])
    except (ValueError, KeyError, AttributeError):
        return None
    for detail in details:
        if isinstance(detail, dict) and "errorCode" in detail:
            return str(detail["errorCode"])  # pyright: ignore[reportUnknownArgumentType]
    return None
