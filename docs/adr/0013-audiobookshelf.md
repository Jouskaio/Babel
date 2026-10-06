# 0013 — Audiobooks from the reader's Audiobookshelf

- Status: accepted
- Date: 2026-10-06

## Context

Readers keep audiobooks in Audiobookshelf (ABS). They want them in Babel next to their
books: status, shelves, reviews, statistics, and listening in the app.

## Decision

- **Link once.** A reader links their ABS with an API key made in ABS (recommended: it does
  not expire), or with their password used once: Babel signs in asking for tokens
  (`x-return-tokens`), keeps the refresh token and rotates it on 401. Secrets are encrypted
  (Fernet, like sources); the password is never stored. When ABS refuses the refresh, the
  link is marked expired and the app asks to link again.
- **Babel in the middle.** The app only talks to Babel. The API lists ABS libraries and
  audiobooks, adds the chosen ones to the library (an item with `audio_duration`, no file,
  its cover kept by Babel), and streams tracks from ABS with byte ranges. ABS can stay on
  the home network; its address must be allowed (`BABEL_SOURCE_ALLOWED_HOSTS`).
- **Progress.** Positions are Babel reading positions (`audio:<seconds>`, through sync,
  offline included), and the app also sends them to ABS (`/api/me/progress`) so its other
  apps resume there; when opening a book, the newest of the two wins.
- **Like any book.** Audiobooks have statuses, shelves, reviews, works and statistics;
  removing one keeps its data (ADR 0012); notes need a text and are not offered.
