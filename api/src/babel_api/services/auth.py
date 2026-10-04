"""Account creation, sign-in, token rotation and account management."""

from dataclasses import dataclass
from datetime import UTC, datetime, timedelta
from uuid import UUID, uuid4

from babel_api.adapters.security.tokens import (
    hash_refresh_secret,
    new_refresh_secret,
    refresh_secret_matches,
)
from babel_api.domain.errors import (
    EmailAlreadyUsedError,
    InvalidCredentialsError,
    InvalidResetTokenError,
    PasswordRequiredError,
)
from babel_api.domain.ports import (
    AccessTokens,
    IdentityVerifier,
    Mailer,
    PasswordHasher,
    UserRepository,
)
from babel_api.domain.users import IdentityProvider, PasswordResetToken, RefreshToken, User
from babel_api.services import emails

RESET_TTL = timedelta(hours=1)
# At most one reset email per account in this interval, to prevent mail bombing.
RESET_THROTTLE = timedelta(minutes=1)


@dataclass(frozen=True, slots=True)
class AuthSession:
    """Tokens handed to a client after a successful sign-in or refresh."""

    user: User
    access_token: str
    expires_in: int
    refresh_token: str


def normalize_email(email: str) -> str:
    return email.strip().lower()


class AuthService:
    """Use cases of authentication. Commits are done here, once per use case."""

    def __init__(
        self,
        users: UserRepository,
        hasher: PasswordHasher,
        access_tokens: AccessTokens,
        refresh_ttl: timedelta,
        verifiers: dict[IdentityProvider, IdentityVerifier],
        mailer: Mailer,
        public_url: str,
    ) -> None:
        self._users = users
        self._mailer = mailer
        self._public_url = public_url.rstrip("/")
        self._hasher = hasher
        self._access = access_tokens
        self._refresh_ttl = refresh_ttl
        self._verifiers = verifiers
        # Hash checked when the email is unknown, so both paths take the same time.
        self._dummy_hash = hasher.hash("timing-equalizer")

    # ------------------------------------------------------------ sign-up / sign-in
    async def register(
        self, email: str, password: str, display_name: str, locale: str = "fr"
    ) -> AuthSession:
        email = normalize_email(email)
        if await self._users.get_by_email(email):
            raise EmailAlreadyUsedError
        user = await self._users.add(
            email, display_name.strip(), self._hasher.hash(password), locale
        )
        return await self._open_session(user)

    async def login(self, email: str, password: str) -> AuthSession:
        user = await self._users.get_by_email(normalize_email(email))
        if user is None or user.password_hash is None:
            self._hasher.verify(self._dummy_hash, password)
            raise InvalidCredentialsError
        if not self._hasher.verify(user.password_hash, password):
            raise InvalidCredentialsError
        if self._hasher.needs_rehash(user.password_hash):
            user = await self._users.update(user.id, password_hash=self._hasher.hash(password))
        return await self._open_session(user)

    async def login_with_provider(
        self,
        provider: IdentityProvider,
        id_token: str,
        nonce: str | None,
        display_name: str | None = None,
    ) -> AuthSession:
        identity = await self._verifiers[provider].verify(id_token, nonce)
        user = await self._users.get_by_identity(provider, identity.subject)
        if user is None:
            if not identity.email or not identity.email_verified:
                # Without a verified email we cannot create or link an account safely.
                raise InvalidCredentialsError
            email = normalize_email(identity.email)
            user = await self._users.get_by_email(email)
            if user is None:
                name = display_name or identity.display_name or email.split("@")[0]
                user = await self._users.add(email, name.strip()[:80], None)
            await self._users.link_identity(user.id, provider, identity.subject)
            user = await self._users.get_by_id(user.id) or user
        return await self._open_session(user)

    def provider_enabled(self, provider: IdentityProvider) -> bool:
        verifier = self._verifiers.get(provider)
        return verifier is not None and verifier.enabled

    # ------------------------------------------------------------ refresh / logout
    async def refresh(self, refresh_token: str) -> AuthSession:
        token = await self._find_refresh_token(refresh_token)
        now = datetime.now(UTC)
        if token.revoked_at is not None:
            # A rotated token was reused: it may have been stolen. End the whole sign-in.
            await self._users.revoke_refresh_family(token.family_id, now)
            await self._users.commit()
            raise InvalidCredentialsError
        if token.expires_at <= now:
            raise InvalidCredentialsError
        user = await self._users.get_by_id(token.user_id)
        if user is None:
            raise InvalidCredentialsError
        await self._users.revoke_refresh_token(token.id, now)
        return await self._open_session(user, family_id=token.family_id)

    async def logout(self, refresh_token: str) -> None:
        try:
            token = await self._find_refresh_token(refresh_token)
        except InvalidCredentialsError:
            return
        await self._users.revoke_refresh_family(token.family_id, datetime.now(UTC))
        await self._users.commit()

    # ------------------------------------------------------------ account
    async def get_user(self, user_id: UUID) -> User:
        user = await self._users.get_by_id(user_id)
        if user is None:
            raise InvalidCredentialsError
        return user

    async def update_profile(
        self, user_id: UUID, display_name: str | None = None, locale: str | None = None
    ) -> User:
        name = display_name.strip() if display_name is not None else None
        user = await self._users.update(user_id, display_name=name, locale=locale)
        await self._users.commit()
        return user

    async def change_password(
        self, user_id: UUID, current_password: str | None, new_password: str
    ) -> None:
        """Set or change the password, then sign out every other device."""
        user = await self.get_user(user_id)
        if user.password_hash is not None and (
            current_password is None
            or not self._hasher.verify(user.password_hash, current_password)
        ):
            raise PasswordRequiredError
        await self._set_password(user, new_password)

    # ------------------------------------------------------------ password reset
    async def request_password_reset(self, email: str) -> None:
        """Email a reset link. Says nothing about whether the account exists."""
        user = await self._users.get_by_email(normalize_email(email))
        if user is None:
            return
        now = datetime.now(UTC)
        last = await self._users.last_reset_request(user.id)
        if last is not None and now - last < RESET_THROTTLE:
            return
        token_id, secret = uuid4(), new_refresh_secret()
        await self._users.add_reset_token(
            PasswordResetToken(
                id=token_id,
                user_id=user.id,
                secret_hash=hash_refresh_secret(secret),
                created_at=now,
                expires_at=now + RESET_TTL,
            )
        )
        await self._users.commit()
        link = f"{self._public_url}/reset-password?token={token_id}.{secret}"
        await self._mailer.send(
            emails.password_reset(user.email, user.display_name, user.locale, link)
        )

    async def reset_password(self, token: str, new_password: str) -> None:
        token_id, _, secret = token.partition(".")
        try:
            stored = await self._users.get_reset_token(UUID(token_id))
        except ValueError as error:
            raise InvalidResetTokenError from error
        now = datetime.now(UTC)
        if (
            stored is None
            or stored.used_at is not None
            or stored.expires_at <= now
            or not refresh_secret_matches(secret, stored.secret_hash)
        ):
            raise InvalidResetTokenError
        user = await self._users.get_by_id(stored.user_id)
        if user is None:
            raise InvalidResetTokenError
        await self._set_password(user, new_password)

    async def _set_password(self, user: User, new_password: str) -> None:
        """Store the new password, end every session and every pending reset, notify."""
        now = datetime.now(UTC)
        await self._users.update(user.id, password_hash=self._hasher.hash(new_password))
        await self._users.revoke_user_refresh_tokens(user.id, now)
        await self._users.use_reset_tokens(user.id, now)
        await self._users.commit()
        await self._mailer.send(emails.password_changed(user.email, user.display_name, user.locale))

    async def delete_account(self, user_id: UUID) -> None:
        await self._users.delete(user_id)
        await self._users.commit()

    # ------------------------------------------------------------ internals
    async def _open_session(self, user: User, family_id: UUID | None = None) -> AuthSession:
        token_id, secret = uuid4(), new_refresh_secret()
        await self._users.add_refresh_token(
            RefreshToken(
                id=token_id,
                user_id=user.id,
                family_id=family_id or uuid4(),
                secret_hash=hash_refresh_secret(secret),
                expires_at=datetime.now(UTC) + self._refresh_ttl,
            )
        )
        await self._users.commit()
        return AuthSession(
            user=user,
            access_token=self._access.issue(user.id),
            expires_in=int(self._access.ttl.total_seconds()),
            refresh_token=f"{token_id}.{secret}",
        )

    async def _find_refresh_token(self, refresh_token: str) -> RefreshToken:
        token_id, _, secret = refresh_token.partition(".")
        try:
            token = await self._users.get_refresh_token(UUID(token_id))
        except ValueError as error:
            raise InvalidCredentialsError from error
        if token is None or not refresh_secret_matches(secret, token.secret_hash):
            raise InvalidCredentialsError
        return token
