"""Verification of Google and Apple ID tokens against their published keys."""

import asyncio
import hashlib
from typing import Any

import jwt
from jwt import PyJWKClient

from babel_api.domain.errors import InvalidCredentialsError, ProviderNotConfiguredError
from babel_api.domain.users import ExternalIdentity, IdentityProvider


class OidcIdentityVerifier:
    """Verifies an OpenID Connect ID token: signature, issuer, audience, expiry, nonce."""

    def __init__(
        self,
        provider: IdentityProvider,
        jwks_url: str,
        issuers: tuple[str, ...],
        audiences: list[str],
        *,
        hashed_nonce: bool,
    ) -> None:
        self._provider = provider
        self._jwks = PyJWKClient(jwks_url, cache_keys=True, lifespan=3600)
        self._issuers = issuers
        self._audiences = audiences
        # Apple stores SHA-256(nonce) in the token; Google stores the nonce itself.
        self._hashed_nonce = hashed_nonce

    @property
    def enabled(self) -> bool:
        return bool(self._audiences)

    async def verify(self, id_token: str, nonce: str | None) -> ExternalIdentity:
        if not self.enabled:
            raise ProviderNotConfiguredError(self._provider.value)
        try:
            # PyJWKClient fetches keys synchronously: keep it off the event loop.
            key = await asyncio.to_thread(self._jwks.get_signing_key_from_jwt, id_token)
            claims: dict[str, Any] = jwt.decode(
                id_token,
                key.key,
                algorithms=["RS256"],
                audience=self._audiences,
                options={"require": ["iss", "sub", "aud", "exp", "iat"]},
            )
        except jwt.PyJWTError as error:
            raise InvalidCredentialsError from error
        if claims["iss"] not in self._issuers:
            raise InvalidCredentialsError
        if nonce is not None:
            expected = hashlib.sha256(nonce.encode()).hexdigest() if self._hashed_nonce else nonce
            if claims.get("nonce") != expected:
                raise InvalidCredentialsError
        verified = claims.get("email_verified") in (True, "true")
        return ExternalIdentity(
            provider=self._provider,
            subject=str(claims["sub"]),
            email=claims.get("email"),
            email_verified=verified,
            display_name=claims.get("name"),
        )


def google_verifier(client_ids: list[str]) -> OidcIdentityVerifier:
    return OidcIdentityVerifier(
        IdentityProvider.GOOGLE,
        "https://www.googleapis.com/oauth2/v3/certs",
        ("accounts.google.com", "https://accounts.google.com"),
        client_ids,
        hashed_nonce=False,
    )


def apple_verifier(client_ids: list[str]) -> OidcIdentityVerifier:
    return OidcIdentityVerifier(
        IdentityProvider.APPLE,
        "https://appleid.apple.com/auth/keys",
        ("https://appleid.apple.com",),
        client_ids,
        hashed_nonce=True,
    )
