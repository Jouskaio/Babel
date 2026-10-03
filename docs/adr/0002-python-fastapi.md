# 0002 — Python and FastAPI for the API

- Status: accepted
- Date: 2026-10-03

## Context

The API aggregates media services, scrapes several sites, imports fanfiction and computes
reading statistics (monthly and yearly Wraps). Rust and Python were considered.

## Decision

Use Python 3.13 with FastAPI, managed with uv; strict typing (pyright) and Ruff.

## Consequences

- FanFicFare (fanfiction import) is a Python library and can be used directly.
- Mature data tooling (Polars, DuckDB) and scraping tooling (httpx, selectolax, Playwright).
- FastAPI produces the OpenAPI contract used to generate the Dart client.
- Raw performance is lower than Rust, which is irrelevant at this scale; a hot path can be
  rewritten later if profiling ever requires it.
