# Babel — API

Server API written in Python (FastAPI). It is the only component that talks to the media stack
and metadata sources; the Flutter app only calls it.

## Architecture

```
src/babel_api/
├── api/        # HTTP: versioned routes (/v1), schemas, FastAPI dependencies
├── services/   # use cases
├── domain/     # pure business models and rules
├── adapters/   # database, file store, sources (GitHub, OPDS, WebDAV, AO3), catalogs…
├── core/       # configuration, logging
└── scripts/    # maintenance (OpenAPI contract export)
```

Allowed dependencies: `api → services → domain` and `adapters → domain`.
Ruff forbids importing FastAPI outside `api/` (rule `TID251`).

## Commands

```bash
uv sync                                               # install everything
uv run uvicorn babel_api.main:app --reload            # run the API (http://127.0.0.1:8000/docs)
uv run pytest                                         # tests + coverage
uv run ruff format && uv run ruff check --fix         # format + lint
uv run pyright                                        # strict type checking
uv run python -m babel_api.scripts.export_openapi     # regenerate contracts/openapi.json
```

In development the API applies pending migrations when it starts (`BABEL_MIGRATE_ON_STARTUP`
turns this on or off); `uv run python -m babel_api.scripts.migrate` does it by hand.

## Developing on a copy of production

Local development uses `api/babel.db` (SQLite) by default. To work on real data, copy
the production database into a local PostgreSQL (Docker), never the other way round:

```bash
./scripts/copy-prod-db.sh
```

It exports the database over SSH (`deploy@babel-api` through Tailscale, or
`BABEL_PROD_SSH`), restores it into the `babel-db-local` container on port 5433, deletes
the export and prints the command that starts the API on the copy. Running it again
replaces the copy. Migrations not yet released apply to the copy only. The copy holds real
accounts, so it stays on this machine; sources' tokens cannot be read locally, and book
files stay on the NAS.
