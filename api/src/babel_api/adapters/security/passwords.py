"""Argon2id password hashing (OWASP recommended defaults from argon2-cffi)."""

from argon2 import PasswordHasher
from argon2.exceptions import InvalidHashError, VerificationError


class Argon2PasswordHasher:
    """Hashes and verifies passwords with Argon2id."""

    def __init__(self) -> None:
        self._hasher = PasswordHasher()

    def hash(self, password: str) -> str:
        return self._hasher.hash(password)

    def verify(self, password_hash: str, password: str) -> bool:
        try:
            return self._hasher.verify(password_hash, password)
        except (VerificationError, InvalidHashError):
            return False

    def needs_rehash(self, password_hash: str) -> bool:
        return self._hasher.check_needs_rehash(password_hash)
