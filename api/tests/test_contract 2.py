import json

from babel_api.scripts import export_openapi


def test_contract_is_deterministic() -> None:
    assert export_openapi.render() == export_openapi.render()


def test_contract_only_exposes_versioned_routes() -> None:
    paths: dict[str, object] = json.loads(export_openapi.render())["paths"]

    assert "/v1/health" in paths
    assert all(path.startswith("/v1/") for path in paths)


def test_committed_contract_is_up_to_date() -> None:
    """Fails when a route changed without regenerating contracts/openapi.json."""
    committed = export_openapi.CONTRACT_PATH.read_text(encoding="utf-8")

    assert committed == export_openapi.render()
