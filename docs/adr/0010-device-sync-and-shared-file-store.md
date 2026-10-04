# 0010 — Device sync and shared file store

- Status: proposed
- Date: 2026-10-04

## Context

A reader uses several devices (phone, e-reader, computer, web) and expects the same library
everywhere: books, files, shelves, progress and notes. Book files come from many places
(imports, user sources — ADR 0009); once a file is on the server, fetching it again from its
origin is wasteful and sometimes impossible.

## Decision

### Shared file store

- Files are stored **once**, addressed by their SHA-256 (content-addressed). Importing a file
  that already exists only adds a reference.
- A stored file is attached to a catalog edition (ADR 0007) with its format, size, origin
  (import, source kind) and the account that first imported it.
- **Access policy** is a server setting, `BABEL_FILE_ACCESS`:
  - `everyone` (current choice): any signed-in account can download any available file;
  - `entitled`: only accounts that imported the file, have it in one of their sources, or
    for which the work is public domain or openly licensed.
  Switching the policy needs no data migration.
- **Takedown**: an administrator can withdraw a file (it disappears from every library, the
  bytes are deleted) and block its hash so it cannot be imported again. Requests are received
  at the contact address and handled from the admin screen; every import and withdrawal is
  logged with its author and date.
- Downloads require a session, use short-lived signed URLs, support HTTP range requests (so
  interrupted downloads resume) and are rate-limited per account. Storage starts on a local
  volume, behind an interface that also fits S3-compatible storage (MinIO, Garage).

### Sync between devices

- The server is the source of truth for the library: entries, shelves, reading state,
  progress and annotations. Every change is appended to a per-user change log with a
  monotonic cursor.
- Devices pull with `GET /v1/sync?since=<cursor>` (on start, on resume, and on a push
  notification) and push their own changes through the offline outbox (ADR 0008), with
  idempotency keys and client timestamps.
- Conflicts resolve per field, latest change wins; reading progress keeps one position per
  device and offers "continue where you stopped on <device>" when they disagree. A book
  reopens at the most recent position of any device. Locators are opaque to the API:
  `epub:<chapter>:<fraction>` (spine index, fraction of the chapter scrolled) or
  `pages:<page>` (comics, PDF); the percent is weighted by the length of each chapter.
  Only the latest position of a book waits in the outbox.
- Each device registers itself (name, kind, capabilities). Files are downloaded per device
  on demand or marked "available offline"; the library shows which devices hold a copy.
  Removing a file from one device never removes it from the library or other devices.
- E-readers without the app use the Kobo sync protocol and OPDS (later), mapped onto the
  same change log.

## Consequences

The API gains a blob store, `edition_files` and `blocked_hashes` tables, a change log and a
devices table. Every library mutation goes through one service that writes the change log,
so sync stays consistent whatever the client.
