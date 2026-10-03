"""Shared fixtures."""

from collections.abc import Iterator

import pytest
from fastapi.testclient import TestClient

from babel_api.core.config import Settings
from babel_api.main import create_app


@pytest.fixture
def client() -> Iterator[TestClient]:
    """HTTP client on an application configured for tests."""
    app = create_app(Settings(environment="test"))
    with TestClient(app) as test_client:
        yield test_client
