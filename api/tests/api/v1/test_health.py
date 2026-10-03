from fastapi.testclient import TestClient

from babel_api import __version__


def test_health_returns_ok_and_version(client: TestClient) -> None:
    response = client.get("/v1/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok", "version": __version__}


def test_unversioned_route_is_not_exposed(client: TestClient) -> None:
    assert client.get("/health").status_code == 404
