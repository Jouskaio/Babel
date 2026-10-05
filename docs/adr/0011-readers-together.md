# 0011 — Readers together

- Status: accepted
- Date: 2026-10-06

## Context

Babel readers want to see what their friends read, share some notes, review books and
recommend them to each other, without turning their library into a public page.

## Decision

- **Handles.** A reader is found only by a handle they choose (3 to 30 lower-case letters,
  digits, dots or underscores, unique). Without a handle nobody can find them. Search matches
  the beginning of handles only; emails are never searchable.
- **Two relations.** Friends are mutual: a request, accepted by the other reader. Following is
  one way and needs no consent; it only gives access to public content.
- **Audiences.** Each kind of content has an audience: `private` (only the reader), `friends`
  (mutual friends), `public` (any signed-in reader; followers get it in their feed).
  - What one is reading (books started in the last 60 days, with progress) and the titles of
    the library: one setting each, `friends` by default.
  - Reviews (rating 1–5 and/or text, one per book of the library): `public` by default, chosen
    per review.
  - Highlights and notes: `private` by default, chosen per annotation (synced like any edit,
    ADR 0010).
- **Recommendations** go to friends only: a book of the sender's library, or a title or link,
  with a message. The recipient gets a notification.
- **Feed.** Built when asked from the friends' and followed readers' latest readings, reviews
  and shared notes, filtered by audience. Nothing is copied or fanned out.
- **Comics and manga.** Notes on a comic page point at an area of the page (`region`:
  x, y, width, height as fractions of the page) instead of a quote; they are shared like any
  other note.
- Files are never shared through these features: only titles, progress and text written by
  readers. Deleting an account removes its profile, relations, reviews and recommendations.

## Consequences

- A reader's page and the feed are computed per request from indexed tables; enough for a
  small community, to revisit (cached feed) if Babel grows.
- Blocking and reporting are not there yet: unfriending and unfollowing are the only tools.
