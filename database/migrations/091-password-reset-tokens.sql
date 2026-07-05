-- 091-password-reset-tokens.sql (2026-07-05)
--
-- Password reset flow ("Forgot password?" / "Set initial password").
--
-- Purpose:
--   1. A user (rostered player, coach, admin) enters their email.
--   2. Backend generates a random 32-byte token, stores its SHA-256
--      hash + expiry (60 min) here, and emails the raw token to the
--      user in a link like https://footballhome.org/reset-password?token=…
--   3. User clicks link, sets new password.  Backend verifies the
--      token by hashing it and looking up this table.
--   4. On successful reset (or explicit resend) the row is marked
--      used_at=NOW() so the token can never be reused.
--
-- This doubles as the "set initial password" flow for LeagueApps-synced
-- accounts whose password_hash was seeded to an unguessable string —
-- the "forgot my password" affordance IS how they onboard.
--
-- Design notes:
--   • `token_hash` is SHA-256 hex of the raw token — same convention as
--     player_event_reminders.magic_token.  Raw tokens live only in the
--     email body and the user's URL bar.
--   • `expires_at` is UTC.  60 min is a common industry balance; short
--     enough that a leaked link is useless within a working session,
--     long enough for a user to actually read the email.
--   • `used_at` NULL = still valid.  Set on successful reset (and on
--     any subsequent reset attempt to prevent replay).
--   • `requested_ip` + `requested_ua` help post-mortem an abuse event.
--     Optional; NULL if the backend couldn't determine.
--   • Legacy per-user unused tokens are NOT auto-invalidated when a
--     new one is issued — we let both live until one is used or
--     expires.  Simpler; no meaningful attack surface for 60-min TTLs.

BEGIN;

CREATE TABLE IF NOT EXISTS password_reset_tokens (
  id            SERIAL       PRIMARY KEY,
  user_id       INTEGER      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash    VARCHAR(64)  NOT NULL,
  expires_at    TIMESTAMPTZ  NOT NULL,
  used_at       TIMESTAMPTZ,
  requested_ip  TEXT,
  requested_ua  TEXT,
  created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  UNIQUE (token_hash)
);

CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_user
  ON password_reset_tokens (user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_active
  ON password_reset_tokens (token_hash)
  WHERE used_at IS NULL;

COMMIT;
