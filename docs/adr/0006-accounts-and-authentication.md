# 0006 — Accounts and authentication

- Status: accepted
- Date: 2026-10-04

## Decision

- The API owns accounts: email + password, plus Google and Apple sign-in. Social sign-in
  sends the provider's ID token to the API, which verifies it against the provider's
  published keys (signature, issuer, audience, expiry, nonce). There is no separate
  identity server.
- Passwords are hashed with Argon2id.
- Sessions use a short-lived access token (JWT, 15 min) and an opaque refresh token
  (30 days) stored hashed. Refresh tokens rotate on every use; replaying a rotated token
  revokes the whole sign-in (reuse detection).
- The web app receives the refresh token in an `HttpOnly`, `Secure`, `SameSite=Strict`
  cookie and must send `X-Babel-Client: web`; mobile apps receive it in the body and keep
  it in the platform's secure storage.
- A provider identity is linked to an existing account only when the provider reports the
  email as verified.
- PostgreSQL in production, migrated by Alembic when the API starts. Tests run the same
  migrations on SQLite; the CI also applies them to PostgreSQL.

## Consequences

Store review rules apply: offering Google sign-in on iOS requires Sign in with Apple, and
in-app account deletion is mandatory (`DELETE /v1/me`).
