# 0004 — OpenAPI contract and generated Dart client

- Status: accepted
- Date: 2026-10-03

## Decision

- FastAPI exports the contract to `contracts/openapi.json` (deterministic output).
- `scripts/generate-api-client.sh` generates `packages/api_client` with OpenAPI Generator
  (`dart` generator, pinned version). The client is never edited by hand.
- The `contract` CI workflow fails if either file is out of date.
- Technical identifiers in the API (tags, operation IDs, fields) are English and ASCII, because
  they become Dart class and method names.

## Consequences

The app always compiles against the real API shape; drift is caught in CI, not by users.
