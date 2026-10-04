# 0008 — Offline-first: pending actions are queued and replayed

- Status: accepted
- Date: 2026-10-04

## Context

Readers search for or scan books in places without network: bookshops, libraries, the
metro, a friend's shelf. Losing a scan because the phone is offline is not acceptable.

## Decision

- The app keeps a persistent **outbox** of actions that need the API: searches, ISBN scans,
  library additions, progress updates and annotations.
- When offline, an action is stored with its creation time and shown as *pending* in the UI
  (e.g. "3 scans waiting for network"). Nothing is lost when the app is closed.
- When connectivity returns (and at start-up), the outbox is replayed in order, with
  exponential backoff on failures. Results of deferred searches and scans are surfaced as a
  notification / badge so the user can review and confirm them.
- Write actions carry a client-generated idempotency key, so a replay after a lost response
  never creates duplicates. The API accepts the original client timestamp for progress and
  annotations, and resolves conflicts per field with "latest change wins".
- Already-fetched catalog data, covers and the user's library are cached locally, so
  browsing and reading work fully offline; only new lookups wait for the network.

## Consequences

Every mutating endpoint must be idempotent (`Idempotency-Key` header) and accept a client
timestamp. The app needs a local database (e.g. SQLite via drift) rather than in-memory
state only.
