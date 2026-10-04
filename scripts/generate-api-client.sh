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
# FastAPI describes uploads the OpenAPI 3.1 way (contentMediaType); the dart generator
# only recognizes `format: binary`, without which file parameters become strings.
for schema in spec["components"]["schemas"].values():
    for prop in schema.get("properties", {}).values():
        if prop.get("contentMediaType") == "application/octet-stream":
            prop["format"] = "binary"


# Optional values are `anyOf: [X, {"type": "null"}]` in OpenAPI 3.1, which the generator
# reads as required and non-null (debug builds then assert on every null). Rewrite them
# the OpenAPI 3.0 way, `X` + `nullable: true`, and present the copy as 3.0.
def denull(node):
    if isinstance(node, dict):
        options = node.get("anyOf")
        if isinstance(options, list) and {"type": "null"} in options:
            rest = [o for o in options if o != {"type": "null"}]
            del node["anyOf"]
            if len(rest) == 1:
                node.update(rest[0])
            else:
                node["anyOf"] = rest
            node["nullable"] = True
        # Other OpenAPI 3.1-only keywords.
        if "const" in node:
            node["enum"] = [node.pop("const")]
        node.pop("contentMediaType", None)
        for value in node.values():
            denull(value)
    elif isinstance(node, list):
        for value in node:
            denull(value)


denull(spec)
# The dart generator asserts that required keys are non-null even when nullable:
# nullable fields are presented as optional instead.
for schema in spec["components"]["schemas"].values():
    props = schema.get("properties", {})
    if "required" in schema:
        schema["required"] = [k for k in schema["required"] if not props.get(k, {}).get("nullable")]
spec["openapi"] = "3.0.3"
spec["info"].pop("summary", None)
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
