# 0003 — Flutter app as a pure client

- Status: accepted
- Date: 2026-10-03

## Context

Babel targets phones first, plus tablets, desktops, the web and e-readers.

## Decision

A single Flutter app with no server logic: it only renders data and calls the API. Secrets,
scraping, media-server access and analytics stay in the API.

## Consequences

- One codebase for iOS, Android, web, macOS, Windows, Linux and Boox (Android).
- Kobo devices cannot install apps and their browser cannot run Flutter web: Kobo support goes
  through the Kobo sync protocol served by the API, not through the app.
- Feature availability is configured per device (camera, offline downloads, e-ink mode).
