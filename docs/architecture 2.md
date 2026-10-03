# Architecture

```
┌──────────────────────┐   HTTPS /v1   ┌───────────────────────────┐
│  Flutter app         │ ────────────► │  Babel API (FastAPI)      │
│  phone · tablet · PC │               │  API VM                   │
│  web · Boox          │               │                           │
└──────────────────────┘               │  services ─► domain       │
                                       │  adapters ─┬─► Kavita / ABS (media VM)
 Kobo e-reader ── Kobo sync protocol ─►│            ├─► Shelfmark / Chaptarr / qBittorrent
 KOReader / Boox ── kosync protocol ──►│            ├─► Hardcover / Open Library / Wikidata / TMDB
                                       │            └─► Goodreads / Booknode / Pagebound (scraping)
                                       └───────────────────────────┘
```

## Principles

1. **The app is a pure client.** It renders data and sends HTTP requests to the API. It holds
   no secrets and no server logic.
2. **One contract, generated client.** The API publishes an OpenAPI contract
   (`contracts/openapi.json`); the Dart client in `packages/api_client` is generated from it.
3. **Versioned API.** Every route lives under `/v1`. A breaking change introduces `/v2` so
   older installed apps keep working.
4. **Independent delivery.** API and app have their own CI workflows (path filters), their own
   versions and tags (`api-vX.Y.Z`, `app-vX.Y.Z`).
5. **Isolated connectors.** Each external source is an adapter with its own cache and on/off
   switch; one failing source never breaks the API.

## Decision records

| ADR | Decision |
| --- | --- |
| [0001](adr/0001-monorepo.md) | Single repository for API, app and contract |
| [0002](adr/0002-python-fastapi.md) | Python + FastAPI for the API |
| [0003](adr/0003-flutter-pure-client.md) | Flutter app as a pure client |
| [0004](adr/0004-contract-first-generated-client.md) | OpenAPI contract and generated Dart client |
| [0005](adr/0005-git-flow-independent-versions.md) | git flow with independent component versions |
