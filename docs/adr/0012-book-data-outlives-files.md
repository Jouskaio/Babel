# 0012 — A reader's book data outlives the file, and is gathered per work

- Status: accepted
- Date: 2026-10-06

## Context

Readers organize their library (shelves, statuses, progress read elsewhere), hide books they
are done with, and sometimes take a book out. What they wrote about a book (reviews, ratings,
highlights, notes) and where they were in it must not disappear with the file: they want it
back on the book's page, in searches, and when they add the book again. Other readers read
other editions, sometimes in other languages, and reviews and notes should meet on the work
whatever the edition.

## Decision

- **Status and progress.** A library item has a status (`to_read`, `reading`, `finished`,
  `abandoned`), a progress declared by hand (percent, for a book read elsewhere), and when it
  was started and finished. Reading positions move the status on their own (opened → reading,
  end reached → finished); a later change made by hand wins. Changes are pushed through the
  sync outbox (`reading_state` operations, latest client time wins, ADR 0010).
- **Shelves.** Ordered lists of books, private by default, with the same audiences as other
  shared content (ADR 0011). A shelf is synchronized whole, the latest edit wins.
- **Hiding.** A hidden book stays in the library with all its data; the app shows it only
  when "Show hidden books" is on. Hidden books are never shown to other readers.
- **Removing keeps the data.** Taking a book out of the library marks the item removed
  instead of deleting it. Status, review, notes and positions stay; follows and shelf places
  go. Adding the same file again restores the item as it was. When the file itself goes
  (withdrawn by an administrator), the item is removed the same way and its data stays.
  Only deleting the account erases it. `GET /v1/library/history` lists every book a reader
  has or once had, with what they left on it.
- **Per work.** Each library item points to a catalog work: from the file's edition (ISBN),
  else a known work with the same title and author, else chosen by the reader. Reviews and
  notes are gathered per work through their item (`GET /v1/catalog/works/{id}/readers`),
  whatever the edition or file, with each reader's audiences and blocks applied.

## Placing notes from other editions (next step)

Notes keep the quoted text; that, not a position, is the anchor between editions.

- Same file: exact place (chapter and quote).
- Other edition, same language: the quote is searched in the whole book (chapters differ
  between editions), tolerant of typography (quotes, apostrophes, spaces, punctuation,
  hyphenation), with a few words of context to choose between repeated passages. Found: the
  note is shown on the passage. Not found: it stays in the margin list, never misplaced.
- Other language: no reliable text match. The note is placed approximately at the same
  percentage of the book, marked as such, with the original quote. Machine translation to
  find the passage may come later.
- Comic panels: exact only on the same file; otherwise listed at the approximate page.

## Consequences

- Queries showing books to other readers must exclude hidden and removed items.
- A reader's data grows with every book ever read; it is small (text) and erased with the
  account.
- Linking books to works by title can be wrong: the reader can change or remove the link.
