import asyncio
import hashlib
from datetime import UTC, datetime, timedelta
from types import SimpleNamespace
from typing import Any

import jwt
import pytest
from cryptography.hazmat.primitives.asymmetric import rsa

from babel_api.adapters.security.identity import (
    OidcIdentityVerifier,
    apple_verifier,
    google_verifier,
)
from babel_api.domain.errors import InvalidCredentialsError, ProviderNotConfiguredError

KEY = rsa.generate_private_key(public_exponent=65537, key_size=2048)
CLIENT_ID = "babel-client"


def with_test_key(verifier: OidcIdentityVerifier) -> OidcIdentityVerifier:
    """Replace the provider's published keys by the local test key."""
    signing_key = SimpleNamespace(key=KEY.public_key())
    verifier._jwks.get_signing_key_from_jwt = lambda _token: signing_key  # type: ignore[method-assign]
    return verifier


def token(**overrides: Any) -> str:
    now = datetime.now(UTC)
    claims: dict[str, Any] = {
        "iss": "https://accounts.google.com",
        "aud": CLIENT_ID,
        "sub": "user-1",
        "email": "ada@example.com",
        "email_verified": True,
        "name": "Ada",
        "iat": now,
        "exp": now + timedelta(minutes=5),
    } | overrides
    return jwt.encode(claims, KEY, algorithm="RS256")


def verify(verifier: OidcIdentityVerifier, id_token: str, nonce: str | None = None) -> Any:
    return asyncio.run(verifier.verify(id_token, nonce))


def test_a_valid_google_token_yields_the_identity() -> None:
    identity = verify(with_test_key(google_verifier([CLIENT_ID])), token())

    assert identity.subject == "user-1"
    assert identity.email == "ada@example.com"
    assert identity.email_verified is True
    assert identity.display_name == "Ada"


@pytest.mark.parametrize(
    "claims",
    [
        {"aud": "someone-else"},
        {"iss": "https://evil.example.com"},
        {"exp": datetime.now(UTC) - timedelta(minutes=1)},
        {"nonce": "other"},
    ],
)
def test_invalid_google_tokens_are_refused(claims: dict[str, Any]) -> None:
    verifier = with_test_key(google_verifier([CLIENT_ID]))
    with pytest.raises(InvalidCredentialsError):
        verify(verifier, token(**claims), nonce="expected")


def test_a_token_signed_by_another_key_is_refused() -> None:
    other = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    forged = jwt.encode({"sub": "x", "aud": CLIENT_ID}, other, algorithm="RS256")
    with pytest.raises(InvalidCredentialsError):
        verify(with_test_key(google_verifier([CLIENT_ID])), forged)


def test_apple_compares_the_hashed_nonce() -> None:
    verifier = with_test_key(apple_verifier([CLIENT_ID]))
    apple_token = token(
        iss="https://appleid.apple.com",
        nonce=hashlib.sha256(b"raw-nonce").hexdigest(),
        email_verified="true",
    )

    identity = verify(verifier, apple_token, nonce="raw-nonce")

    assert identity.email_verified is True


def test_a_provider_without_client_ids_is_disabled() -> None:
    verifier = google_verifier([])
    assert verifier.enabled is False
    with pytest.raises(ProviderNotConfiguredError):
        verify(verifier, token())
