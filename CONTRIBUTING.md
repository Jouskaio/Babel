# Contributing to Babel

## Branches (git flow)

| Branch | Purpose | From | Merges into |
| --- | --- | --- | --- |
| `master` | What runs in production. Every merge is tagged. | — | — |
| `develop` | Integration of the next version | `master` | `release/*` |
| `feature/<topic>` | A feature | `develop` | `develop` (PR) |
| `bugfix/<topic>` | Non-urgent fix | `develop` | `develop` (PR) |
| `release/<component>-v<version>` | Release stabilization | `develop` | `master` **and** `develop` |
| `hotfix/<component>-v<version>` | Urgent production fix | `master` | `master` **and** `develop` |

```bash
git flow feature start my-feature
git flow feature finish my-feature    # or open a PR to develop
git flow release start api-v1.2.0
git flow release finish api-v1.2.0    # tag api-v1.2.0
```

## Versions and tags

The API and the app have **independent versions**:

- `api-vX.Y.Z` → builds and deploys the API Docker image;
- `app-vX.Y.Z` → builds the app release artifacts.

A release may concern a single component only.

## Commit messages

[Conventional Commits](https://www.conventionalcommits.org/), scoped by component:

```
feat(api): add GET /v1/books/{id}
fix(app): fix scrolling on the book page
chore(ci): cache uv dependencies
docs(adr): add ADR 0004 about the database
```

Scopes: `api`, `app`, `client`, `contract`, `infra`, `ci`, `docs`.

## Language

Code, identifiers, comments, docstrings, commits and documentation are written in **English**.
User-facing UI copy is localized through the app's localization files.

## Toolchain

| Tool | Version |
| --- | --- |
| Python | 3.13, managed by [uv](https://docs.astral.sh/uv/) |
| Flutter | latest **stable** (3.47+, Dart 3.13+) — the CI always uses the latest stable |
| Java (Android builds) | 25 (Temurin); Gradle 9.3 and AGP 9.1 also accept 17 or newer |
| Docker | to regenerate the API client (OpenAPI Generator image) |

## Quality

Run the same checks as the CI before opening a PR:

```bash
# API
cd api && uv run ruff format --check && uv run ruff check && uv run pyright && uv run pytest

# App
cd app && dart format --set-exit-if-changed lib test && flutter analyze --fatal-infos && flutter test
```

[pre-commit](https://pre-commit.com) hooks automate formatting and linting:
`uvx pre-commit install`.

## API contract

Any change to the API routes must regenerate the contract and the Dart client:

```bash
cd api && uv run python -m babel_api.scripts.export_openapi
./scripts/generate-api-client.sh
```

The CI fails if `contracts/openapi.json` or `packages/api_client/` no longer match the API.
