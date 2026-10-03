# 0001 — Single repository

- Status: accepted
- Date: 2026-10-03

## Context

Babel has an API and a Flutter client maintained by a single developer. The client depends on
the exact shape of the API.

## Decision

Keep the API, the app, the OpenAPI contract and the generated client in one repository.

## Consequences

- An API change and the matching client update land in the same pull request.
- CI workflows use path filters, so each component is built, tested and released on its own:
  an API-only change never rebuilds or republishes the app.
- Two repositories would only be worth it with separate teams or a public/private split.
