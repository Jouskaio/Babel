import pytest
from pydantic import SecretStr, ValidationError

from babel_api.core.config import Settings


def test_production_refuses_the_development_secret() -> None:
    with pytest.raises(ValidationError):
        Settings(environment="production")


def test_production_accepts_a_real_secret() -> None:
    settings = Settings(environment="production", jwt_secret=SecretStr("x" * 48))
    assert settings.environment == "production"
