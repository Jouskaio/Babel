#!/usr/bin/env bash
# Regenerates packages/api_client from contracts/openapi.json.
# Used locally and by the CI: never edit the client by hand.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GENERATOR_VERSION="v7.12.0"
OUT="packages/api_client"
TMP=".generated-api-client"

# Generate into a temporary folder, then swap it in one go so a failed run never
# leaves a half-written client behind.
rm -rf "${ROOT:?}/$TMP" && mkdir -p "$ROOT/$TMP"
cp "$ROOT/$OUT/.openapi-generator-ignore" "$ROOT/$TMP/"
trap 'rm -rf "${ROOT:?}/$TMP"' EXIT

# The dart generator cannot model FastAPI's validation errors (ValidationError.loc mixes
# strings and integers). The app does not need their details — a 422 still surfaces as an
# ApiException carrying the body — so the generator gets a copy without them.
python3 - "$ROOT/contracts/openapi.json" "$ROOT/$TMP/openapi.json" <<'PY'
import json, sys
spec = json.load(open(sys.argv[1], encoding="utf-8"))
for path in spec["paths"].values():
    for operation in path.values():
        operation.get("responses", {}).pop("422", None)
for schema in ("HTTPValidationError", "ValidationError"):
    spec["components"]["schemas"].pop(schema, None)
json.dump(spec, open(sys.argv[2], "w", encoding="utf-8"))
PY

docker run --rm -u "$(id -u):$(id -g)" -v "$ROOT:/local" \
  "openapitools/openapi-generator-cli:${GENERATOR_VERSION}" generate \
  -i "/local/$TMP/openapi.json" \
  -g dart \
  -o "/local/$TMP" \
  --additional-properties=pubName=babel_api_client,pubLibrary=babel_api_client,pubDescription="Generated Dart client for the Babel API" \
  >/dev/null

rm -f "$ROOT/$TMP/openapi.json"
rm -rf "${ROOT:?}/$OUT"
mv "$ROOT/$TMP" "$ROOT/$OUT"
trap - EXIT

echo "Dart client regenerated in $OUT"
