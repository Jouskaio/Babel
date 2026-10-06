"""Access tokens (short-lived JWT) and refresh-token secrets."""

import hashlib
import hmac
import secrets
from datetime import UTC, datetime, timedelta
from uuid import UUID

import jwt

_ISSUER = "babel"
_ALGORITHM = "HS256"


class AccessTokenError(Exception):
    """The access token is missing, malformed, expired or forged."""


class AccessTokenIssuer:
    """Signs and verifies access tokens with a shared secret."""

    def __init__(self, secret: str, ttl: timedelta) -> None:
        self._secret = secret
        self.ttl = ttl

    def issue(self, user_id: UUID, now: datetime | None = None) -> str:
        now = now or datetime.now(UTC)
        claims = {"sub": str(user_id), "iss": _ISSUER, "iat": now, "exp": now + self.ttl}
        return jwt.encode(claims, self._secret, algorithm=_ALGORITHM)

    def verify(self, token: str) -> UUID:
        try:
            claims = jwt.decode(
                token,
                self._secret,
                algorithms=[_ALGORITHM],
                issuer=_ISSUER,
                options={"require": ["sub", "exp", "iat", "iss"]},
            )
            return UUID(claims["sub"])
        except (jwt.PyJWTError, ValueError) as error:
            raise AccessTokenError from error


_TICKET_ISSUER = "babel-audio"
TICKET_TTL = timedelta(hours=12)


def issue_ticket(secret: str, user_id: UUID, item_id: UUID, now: datetime | None = None) -> str:
    """A signed pass to stream one audiobook's tracks, for players that cannot send
    headers (the web) or that outlive an access token. Never valid as an access token."""
    now = now or datetime.now(UTC)
    claims = {
        "sub": str(user_id),
        "item": str(item_id),
        "iss": _TICKET_ISSUER,
        "iat": now,
        "exp": now + TICKET_TTL,
    }
    return jwt.encode(claims, secret, algorithm=_ALGORITHM)


def verify_ticket(secret: str, ticket: str, item_id: UUID) -> UUID:
    """The reader a ticket was issued to, if it is valid for this audiobook."""
    try:
        claims = jwt.decode(
            ticket,
            secret,
            algorithms=[_ALGORITHM],
            issuer=_TICKET_ISSUER,
            options={"require": ["sub", "item", "exp", "iss"]},
        )
        if claims["item"] != str(item_id):
            raise AccessTokenError
        return UUID(claims["sub"])
    except (jwt.PyJWTError, ValueError) as error:
        raise AccessTokenError from error


def new_refresh_secret() -> str:
    """Random, URL-safe secret of 256 bits."""
    return secrets.token_urlsafe(32)


def hash_refresh_secret(secret: str) -> str:
    """Refresh secrets are high-entropy, so a fast hash is enough."""
    return hashlib.sha256(secret.encode()).hexdigest()


def refresh_secret_matches(secret: str, secret_hash: str) -> bool:
    return hmac.compare_digest(hash_refresh_secret(secret), secret_hash)
