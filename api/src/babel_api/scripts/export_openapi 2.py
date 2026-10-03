"""Export the OpenAPI contract to ``contracts/openapi.json``.

Usage: ``uv run python -m babel_api.scripts.export_openapi [--check]``

With ``--check``, nothing is written and the command fails if the committed contract is out
of date — the CI uses it to catch API changes that were not propagated.
"""

import argparse
import json
import sys
from pathlib import Path

from babel_api.main import create_app

CONTRACT_PATH = Path(__file__).resolve().parents[4] / "contracts" / "openapi.json"


def render() -> str:
    """Render the contract deterministically (sorted keys, trailing newline)."""
    spec = create_app().openapi()
    return json.dumps(spec, indent=2, ensure_ascii=False, sort_keys=True) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="check without writing")
    args = parser.parse_args()

    expected = render()
    if args.check:
        current = CONTRACT_PATH.read_text(encoding="utf-8") if CONTRACT_PATH.exists() else ""
        if current != expected:
            print(
                "contracts/openapi.json is out of date. Run:\n"
                "  cd api && uv run python -m babel_api.scripts.export_openapi",
                file=sys.stderr,
            )
            return 1
        print("OpenAPI contract is up to date.")
        return 0

    CONTRACT_PATH.parent.mkdir(parents=True, exist_ok=True)
    CONTRACT_PATH.write_text(expected, encoding="utf-8")
    print(f"Contract written to {CONTRACT_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
