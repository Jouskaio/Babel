from fastapi.testclient import TestClient

from babel_api.core.config import Settings
from babel_api.main import create_app


def test_routes_are_served_behind_a_proxy_prefix() -> None:
    """The proxy strips "/api"; the API must keep answering on its own paths."""
    app = create_app(Settings(environment="test", root_path="/api"))
    with TestClient(app, root_path="/api") as client:
        assert client.get("/v1/health").status_code == 200
        assert client.get("/openapi.json").json()["servers"] == [{"url": "/api"}]
