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

docker run --rm -u "$(id -u):$(id -g)" -v "$ROOT:/local" \
  "openapitools/openapi-generator-cli:${GENERATOR_VERSION}" generate \
  -i /local/contracts/openapi.json \
  -g dart \
  -o "/local/$TMP" \
  --additional-properties=pubName=babel_api_client,pubLibrary=babel_api_client,pubDescription="Generated Dart client for the Babel API" \
  >/dev/null

rm -rf "${ROOT:?}/$OUT"
mv "$ROOT/$TMP" "$ROOT/$OUT"
trap - EXIT

echo "Dart client regenerated in $OUT"
