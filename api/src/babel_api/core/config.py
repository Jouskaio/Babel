"""API configuration, read from the environment (``BABEL_`` prefix)."""

from functools import lru_cache
from pathlib import Path
from typing import Literal, Self

from pydantic import SecretStr, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

# Development-only signing key; production refuses to start with it.
_DEV_JWT_SECRET = "dev-only-insecure-secret-change-me-0123456789"  # noqa: S105


# The api/ folder (this file is api/src/babel_api/core/config.py).
API_DIR = Path(__file__).resolve().parents[3]


class Settings(BaseSettings):
    """API settings. Secrets are never committed: see ``.env.example``."""

    model_config = SettingsConfigDict(
        env_prefix="BABEL_", env_file=API_DIR / ".env", extra="ignore"
    )

    environment: Literal["development", "test", "production"] = "development"
    log_level: Literal["DEBUG", "INFO", "WARNING", "ERROR"] = "INFO"
    cors_origins: list[str] = []
    # Path prefix added by the reverse proxy (e.g. "/api"), so docs and links stay correct.
    root_path: str = ""

    # SQLAlchemy async URL, e.g. postgresql+asyncpg://babel:secret@db:5432/babel
    # Local defaults live in api/, whatever folder the server is started from.
    database_url: str = f"sqlite+aiosqlite:///{API_DIR / 'babel.db'}"

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

    # Book files (ADR 0010): content-addressed store, who may download, upload size cap.
    files_dir: str = str(API_DIR / "data" / "files")
    file_access: Literal["everyone", "entitled"] = "everyone"
    max_upload_mb: int = 300
    # Fernet key encrypting source credentials. Without it, sources work without tokens only.
    # Generate one with Fernet.generate_key() (see infra/README.md).
    secrets_key: SecretStr = SecretStr("")
    max_sources_per_user: int = 20
    # Hosts on private networks that OPDS and WebDAV sources may reach (e.g. a home
    # Calibre-Web or Nextcloud), as a JSON list: ["calibre.lan", "192.168.1.20"].
    source_allowed_hosts: list[str] = []
    # How often unfinished AO3 works imported by link are checked for new chapters
    # (hours; 0 turns the follow-up off).
    follow_interval_hours: float = 24
    # Apply pending database migrations when the API starts. Default: in development
    # only (the production image migrates before starting the server).
    migrate_on_startup: bool | None = None
    # Firebase service account JSON (Project settings → Service accounts) used to send
    # push notifications. Empty: notifications are only logged.
    fcm_credentials_file: str = ""

    # Accounts with these emails are administrators (file withdrawal, blocking); they are
    # premium too, and only they can make other accounts premium.
    admin_emails: list[str] = []

    # Babel's own Kavita: administrators and premium readers get an account there, created
    # and linked by Babel. The key is an auth key of a Kavita administrator account.
    kavita_url: str = ""
    kavita_admin_key: SecretStr = SecretStr("")

    # Chaptarr (a book manager of the Readarr family): premium readers can ask for a book
    # that is in none of their sources, and it downloads it into the library Kavita reads.
    # Address and API key (Settings > General). Empty: requests are off.
    chaptarr_url: str = ""
    chaptarr_api_key: SecretStr = SecretStr("")

    # Hardcover (free API key, hardcover.app > Settings > Hardcover API): names the volumes of
    # a saga the catalog lacks. Public book data only. Empty: not used.
    hardcover_api_key: SecretStr = SecretStr("")

    # Google Books completes the one-line descriptions of Open Library. Without a key its
    # shared anonymous quota is often used up: a free key (Google Cloud, Books API)
    # makes it reliable. Empty: tried anyway, and given up on quietly when refused.
    google_books_api_key: SecretStr = SecretStr("")

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
