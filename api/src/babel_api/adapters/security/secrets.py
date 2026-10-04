"""Authenticated encryption of stored credentials (source tokens…)."""

from cryptography.fernet import Fernet, InvalidToken

from babel_api.domain.errors import SecretsUnavailableError


class SecretBox:
    """Fernet (AES-128-CBC + HMAC-SHA256). Without a key, nothing can be stored."""

    def __init__(self, key: str) -> None:
        self._fernet = Fernet(key.encode()) if key else None

    @property
    def available(self) -> bool:
        return self._fernet is not None

    def encrypt(self, secret: str) -> str:
        if self._fernet is None:
            raise SecretsUnavailableError
        return self._fernet.encrypt(secret.encode()).decode()

    def decrypt(self, token: str) -> str:
        if self._fernet is None:
            raise SecretsUnavailableError
        try:
            return self._fernet.decrypt(token.encode()).decode()
        except InvalidToken as error:  # key rotated without re-encrypting
            raise SecretsUnavailableError from error
