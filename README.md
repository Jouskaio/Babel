# Babel

A personal and social library: ebooks, audiobooks, comics, fanfiction and paper books,
annotated reading ("in the margin"), e-reader sync, statistics and monthly Wraps.

## Repository layout

| Folder | Purpose | Stack |
| --- | --- | --- |
| [`api/`](api/) | Server API — the only component talking to book sources, catalogs and metadata services | Python · FastAPI · uv |
| [`app/`](app/) | Single client (mobile, tablet, desktop, web, Boox) — **no server logic** | Flutter |
| [`packages/api_client/`](packages/api_client/) | Dart client **generated** from the OpenAPI contract | Dart (generated) |
| [`contracts/`](contracts/) | Versioned OpenAPI contract of the API | OpenAPI 3.1 |
| [`infra/`](infra/) | API deployment on the server VM | Docker Compose |
| [`docs/`](docs/) | Architecture and decision records (ADR) | Markdown |
| [`scripts/`](scripts/) | Repository tooling (client generation) | Bash |

The API and the app are **deployed independently**: each CI workflow only runs when its own
folder changes (see [`docs/architecture.md`](docs/architecture.md)).

## Quick start

```bash
# API
cd api && uv sync && uv run uvicorn babel_api.main:app --reload

# App
cd app && flutter pub get && flutter run
```

## Contributing

The repository follows **git flow** and **Conventional Commits**: see
[`CONTRIBUTING.md`](CONTRIBUTING.md).

## Design

Mockups, design tokens and feature map live in the "Babel" Penpot file.
