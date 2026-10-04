"""API configuration, read from the environment (``BABEL_`` prefix)."""

from functools import lru_cache
from typing import Literal, Self

from pydantic import SecretStr, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

# Development-only signing key; production refuses to start with it.
_DEV_JWT_SECRET = "dev-only-insecure-secret-change-me-0123456789"  # noqa: S105


class Settings(BaseSettings):
    """API settings. Secrets are never committed: see ``.env.example``."""

    model_config = SettingsConfigDict(env_prefix="BABEL_", env_file=".env", extra="ignore")

    environment: Literal["development", "test", "production"] = "development"
    log_level: Literal["DEBUG", "INFO", "WARNING", "ERROR"] = "INFO"
    cors_origins: list[str] = []
    # Path prefix added by the reverse proxy (e.g. "/api"), so docs and links stay correct.
    root_path: str = ""

    # SQLAlchemy async URL, e.g. postgresql+asyncpg://babel:secret@db:5432/babel
    database_url: str = "sqlite+aiosqlite:///./babel.db"

    # Authentication
    jwt_secret: SecretStr = SecretStr(_DEV_JWT_SECRET)
    access_token_ttl_minutes: int = 15
    refresh_token_ttl_days: int = 30
    # The refresh cookie used by the web app is only sent over HTTPS when true.
    cookie_secure: bool = True

    # Public address of the web app, used in links sent by email.
    public_url: str = "http://localhost:8080"

    # Outgoing email (SMTP with STARTTLS). Without a host, emails are only logged.
    smtp_host: str = ""
    smtp_port: int = 587
    smtp_username: str = ""
    smtp_password: SecretStr = SecretStr("")
    mail_from: str = "Babel <contact@jouskaio.me>"

    # Social sign-in: accepted audiences (OAuth client IDs). Empty disables the provider.
    google_client_ids: list[str] = []
    apple_client_ids: list[str] = []

    @model_validator(mode="after")
    def _require_real_secret_in_production(self) -> Self:
        secret = self.jwt_secret.get_secret_value()
        if self.environment == "production" and (secret == _DEV_JWT_SECRET or len(secret) < 32):
            raise ValueError("BABEL_JWT_SECRET must be set to a random value of 32+ characters")
        return self


@lru_cache
def get_settings() -> Settings:
    """Return the settings, loaded once."""
    return Settings()
