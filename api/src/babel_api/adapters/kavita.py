"""Kavita's own API (0.9.1+): signing in, inviting readers, and keys for Babel.

Babel never keeps a Kavita password: it signs in once, then works with a key named
"Babel" on the reader's account, which the reader can revoke in Kavita.
"""

import secrets
import string
from typing import Any, cast
from urllib.parse import parse_qs, urlsplit

import httpx

from babel_api.adapters.sources.http import check_url, guarded_client
from babel_api.domain.errors import DomainError
from babel_api.domain.kavita import KavitaAccount

KEY_NAME = "Babel"
# What a reader created by Babel may do: sign in, download (OPDS), keep bookmarks and
# change their password. Never administrate.
READER_ROLES = ["Login", "Download", "Bookmark", "Change Password"]
NOT_APPLICABLE = -1  # Kavita's AgeRating: no age restriction


class KavitaError(DomainError):
    """Kavita refused or could not be reached; ``reason`` says why."""

    def __init__(self, reason: str) -> None:
        super().__init__(reason)
        self.reason = reason


class KavitaAccountExistsError(KavitaError):
    """Kavita already has an account with this email."""

    def __init__(self) -> None:
        super().__init__("exists")


def strong_password() -> str:
    """A random password meeting any Kavita password policy (never shown nor stored)."""
    alphabet = string.ascii_letters + string.digits
    core = "".join(secrets.choice(alphabet) for _ in range(28))
    return f"{core}aZ7!"


def username_from(text: str) -> str:
    """A Kavita user name from a handle or an email."""
    base = text.split("@")[0]
    allowed = "".join(c for c in base if c.isalnum() or c in "._-")
    return (allowed or "lecteur")[:30]


class KavitaClient:
    def __init__(
        self,
        base_url: str,
        client: httpx.AsyncClient | None = None,
        allowed_hosts: tuple[str, ...] = (),
    ) -> None:
        self.base_url = base_url.strip().rstrip("/")
        self._allowed = allowed_hosts
        self._client = client or guarded_client(allowed_hosts)

    async def _call(
        self,
        method: str,
        path: str,
        token: str | None = None,
        json: object | None = None,
        params: dict[str, Any] | None = None,
    ) -> httpx.Response:
        try:
            response = await self._client.request(
                method,
                f"{self.base_url}{path}",
                json=json,
                params=params,
                headers={"Authorization": f"Bearer {token}"} if token else None,
            )
        except httpx.HTTPError as error:
            raise KavitaError("unreachable") from error
        if response.status_code == 401:
            raise KavitaError("unauthorized")
        return response

    async def check(self) -> None:
        """The address is allowed and answers like Kavita."""
        await check_url(self.base_url, self._allowed)
        response = await self._call("GET", "/api/health")
        if response.status_code != 200:
            raise KavitaError("not_kavita")

    async def login(self, username: str, password: str) -> KavitaAccount:
        response = await self._call(
            "POST", "/api/Account/login", json={"username": username, "password": password}
        )
        return self._account(response)

    async def login_with_key(self, key: str) -> KavitaAccount:
        response = await self._call(
            "POST", "/api/Account/login", json={"username": "", "password": "", "apiKey": key}
        )
        return self._account(response)

    @staticmethod
    def _account(response: httpx.Response) -> KavitaAccount:
        if response.status_code != 200:
            raise KavitaError("unauthorized")
        body = cast(dict[str, Any], response.json())
        return KavitaAccount(username=str(body.get("username") or ""), token=str(body["token"]))

    async def libraries(self, admin_token: str) -> list[int]:
        response = await self._call("GET", "/api/Library/libraries", admin_token)
        if response.status_code != 200:
            raise KavitaError("libraries")
        return [int(lib["id"]) for lib in cast(list[dict[str, Any]], response.json())]

    async def scan_all(self, admin_token: str) -> None:
        """Asks Kavita to look for new files in every library."""
        response = await self._call("POST", "/api/Library/scan-all", admin_token)
        if response.status_code >= 400:
            raise KavitaError("scan")

    async def invite(self, admin_token: str, email: str, libraries: list[int]) -> str:
        """Creates the account (all given libraries); returns its confirmation token."""
        response = await self._call(
            "POST",
            "/api/Account/invite",
            admin_token,
            json={
                "email": email,
                "roles": READER_ROLES,
                "libraries": libraries,
                "ageRestriction": {"ageRating": NOT_APPLICABLE, "includeUnknowns": True},
            },
        )
        if response.status_code == 400 and "already" in response.text.lower():
            raise KavitaAccountExistsError
        if response.status_code != 200:
            raise KavitaError("invite")
        link = str(cast(dict[str, Any], response.json()).get("emailLink") or "")
        token = parse_qs(urlsplit(link).query).get("token", [""])[0]
        if not token:
            raise KavitaError("invite")
        return token

    async def confirm(self, email: str, token: str, username: str, password: str) -> KavitaAccount:
        response = await self._call(
            "POST",
            "/api/Account/confirm-email",
            json={"email": email, "token": token, "username": username, "password": password},
        )
        if response.status_code == 400 and "username" in response.text.lower():
            raise KavitaError("username_taken")
        return self._account(response)

    async def babel_key(self, token: str) -> str:
        """The account's "Babel" key, created when missing."""
        response = await self._call("GET", "/api/Account/auth-keys", token)
        if response.status_code == 200:
            for key in cast(list[dict[str, Any]], response.json()):
                if str(key.get("name")) == KEY_NAME and key.get("key"):
                    return str(key["key"])
        response = await self._call(
            "POST",
            "/api/Account/create-auth-key",
            token,
            json={"keyLength": 32, "name": KEY_NAME},
        )
        if response.status_code != 200:
            raise KavitaError("key")
        return str(cast(dict[str, Any], response.json())["key"])

    async def opds_url(self, token: str) -> str:
        """The OPDS address of the account's "Babel" key, as Kavita builds it."""
        response = await self._call(
            "GET", "/api/Account/opds-url", token, params={"authKeyName": KEY_NAME}
        )
        if response.status_code != 200:
            raise KavitaError("key")
        return response.text.strip().strip('"')

    async def delete_user(self, admin_token: str, username: str) -> None:
        response = await self._call(
            "DELETE", "/api/Users/delete-user", admin_token, params={"username": username}
        )
        if response.status_code not in (200, 204, 404):
            raise KavitaError("delete")

    async def aclose(self) -> None:
        await self._client.aclose()
