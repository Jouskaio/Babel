# Babel — API

Server API written in Python (FastAPI). It is the only component that talks to the media stack
and metadata sources; the Flutter app only calls it.

## Architecture

```
src/babel_api/
├── api/        # HTTP: versioned routes (/v1), schemas, FastAPI dependencies
├── services/   # use cases
├── domain/     # pure business models and rules
├── adapters/   # Kavita, Audiobookshelf, Shelfmark, scrapers…
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
