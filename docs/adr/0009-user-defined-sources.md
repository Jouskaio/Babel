# 0009 — User-defined sources

- Status: proposed
- Date: 2026-10-04

## Context

Readers keep books in many places: a GitHub repository of EPUBs, a Calibre-Web or Kavita
library exposed over OPDS, a Nextcloud folder, a fanfiction account. Babel should let each
user connect the places they already use instead of re-uploading everything.

## Decision

### Source kinds

A **source** belongs to one user and is one of:

| Kind | Connects to | Authentication |
| --- | --- | --- |
| `github` | a repository (and optional folder) containing book files | fine-grained personal access token, read-only, optional for public repositories |
| `opds` | an OPDS 1.2 / 2.0 catalog (Calibre-Web, Kavita, Komga, COPS…) | none, HTTP Basic or API key |
| `webdav` | a WebDAV folder (Nextcloud, ownCloud, NAS) | username + app password |
| `ao3` | the user's Archive of Our Own bookmarks (and subscriptions when signed in) | none for public bookmarks, or the user's own password |
| `generic` | any HTTP endpoint returning a Babel source manifest (JSON) | optional bearer token or header |

The generic manifest is a small, documented JSON format (title, authors, file URL, format,
optional cover and identifiers) so anyone can expose a source without a dedicated connector.

### Architecture

- Connectors run in the API, never in the app. Each kind implements one port:
  `list(cursor) → entries`, `fetch(entry) → file stream`, `test() → health`.
- Sources are **read-only**: Babel lists and imports; it never writes back.
- An entry is matched to the catalog (ADR 0007) by its identifiers, then by title and
  authors; unmatched entries can still be imported as personal books.
- Importing copies the file into the user's library; a source can also be re-scanned
  (manually or on a schedule) to offer new entries. Removing a source keeps the books
  already imported, unless the reader asks to remove them too (their stored files stay, for
  other readers).
- Files that are not readable books are remembered as such and not retried until their
  content changes.
- Fanfiction connectors only access works the user can access with their own account, at
  a polite rate, and identify Babel in their user agent.
- Unfinished AO3 works imported by link are followed: their page is read once a day (one
  request, at AO3's pace, for every reader of the server) and a new version replaces the
  file of the same library item, keeping reading positions and annotations. Finished works
  stop being followed (`BABEL_FOLLOW_INTERVAL_HOURS`, 0 turns it off).

### Secrets

- Credentials are encrypted at rest with a server-side key (`BABEL_SECRETS_KEY`,
  authenticated encryption), never returned by the API after creation and never logged.
  The app only shows a hint (e.g. `ghp_…a1b2`).
- Users are told to create dedicated, read-only, revocable tokens (GitHub fine-grained token,
  Nextcloud app password) rather than their main password; the UI links to the right page.
- Deleting a source or the account deletes its credentials immediately.

### Limits

Per-user limits on the number of sources, scan frequency and imported volume protect the
server; outbound requests are restricted to public addresses (no access to the server's
private network), with timeouts and size caps. The operator can allow specific private
hosts (`BABEL_SOURCE_ALLOWED_HOSTS`), e.g. a Calibre-Web or Nextcloud on the same LAN.

## Consequences

The API gains a connector registry, an encrypted secrets column and a background scan job.
Adding a new kind is one adapter plus its form in the app.
