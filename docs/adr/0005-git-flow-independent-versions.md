# 0005 — git flow with independent component versions

- Status: accepted
- Date: 2026-10-03

## Decision

- Branching follows git flow (`master`, `develop`, `feature/*`, `release/*`, `hotfix/*`).
- Releases are per component: `release/api-X.Y.Z` → tag `api-vX.Y.Z`,
  `release/app-X.Y.Z` → tag `app-vX.Y.Z`.
- Tags trigger the release workflows; branch pushes and pull requests only run checks.
- Commits follow Conventional Commits with a component scope.

## Consequences

The API can ship fixes without an app release, and vice versa.
