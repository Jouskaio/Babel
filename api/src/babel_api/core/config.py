"""API configuration, read from the environment (``BABEL_`` prefix)."""

from functools import lru_cache
from typing import Literal

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """API settings. Secrets are never committed: see ``.env.example``."""

    model_config = SettingsConfigDict(env_prefix="BABEL_", env_file=".env", extra="ignore")

    environment: Literal["development", "test", "production"] = "development"
    log_level: Literal["DEBUG", "INFO", "WARNING", "ERROR"] = "INFO"
    cors_origins: list[str] = []


@lru_cache
def get_settings() -> Settings:
    """Return the settings, loaded once."""
    return Settings()
