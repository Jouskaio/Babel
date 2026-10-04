# 0007 — Catalog: works, editions and their identifiers

- Status: accepted
- Date: 2026-10-04

## Context

A "book" is ambiguous. *The Master and Margarita* is one work with hundreds of editions
(translations, paperbacks, audiobooks), each with its own ISBNs, cover, publisher and page
count. A user owns or reads an edition, but recommendations, friends' activity and
statistics are about the work.

## Decision

- The catalog distinguishes **works** (title, authors, original language, first publication)
  from **editions** (format, language, publisher, page count, release date).
- An edition has **any number of identifiers** (ISBN-10, ISBN-13, ASIN, Open Library ID,
  Google Books ID…) and **any number of covers**. ISBNs are normalized to ISBN-13 for
  lookups; an ISBN can match an existing edition, which then resolves to its work.
- A work exposes a **preferred cover**: the cover of the user's own edition when they have
  one, otherwise the most common cover in the user's language, otherwise any cover.
- A user's library entry points to an edition (or to a work when the edition is unknown,
  e.g. a paper book added by title), and can be moved to another edition later without
  losing progress or notes.
- External sources (Open Library first, Google Books as fallback) are queried by the API,
  never by the app, and their results are cached in the catalog. Covers are proxied and
  cached by the API so clients never depend on third-party URLs directly.
- **Trending books** (landing page, discovery) come from the API: Open Library trending
  data at first, then Babel's own reading activity once there is enough of it. The landing
  page never hard-codes books.

## Consequences

Search results group editions under their work; scanning any ISBN of an edition finds it.
Merging duplicate works and editions is an expected maintenance task (admin screen).
