-- Migration 114: user activity heartbeat.
--
-- Adds `users.last_seen_at` so club admins can spot dormant accounts
-- from the Members screen.  `users.last_login_at` already exists (see
-- 00-schema.sql) but has been dead — nothing writes to it, and it only
-- captures the moment of authentication, not ongoing engagement.
--
-- `last_seen_at` is bumped by the auth middleware (Controller::
-- requireBearer) on every authenticated request, throttled to at most
-- once per minute per user so a page burst doesn't hammer the DB.
-- Impersonation requests (`?asPersonId=` with an admin caller) are
-- skipped so admin view-as sessions do not falsify a member's
-- activity ledger.
--
-- Contract (as of 2026-07-12):
--   NULL          → no authenticated request ever recorded for this
--                   user.  Frontend renders `🚫 Never` chip.
--   NOW() - N     → last request seen N seconds ago.  Frontend renders
--                   `⏰ Nd` with color banding:
--                     0–7d  green    (active this week)
--                     8–30d amber    (dormant)
--                     31d+  red      (cold)
--
-- Idempotent: `IF NOT EXISTS` guards let the migration re-run without
-- error.  No backfill — every existing row starts at NULL so admins
-- immediately see who has been silent since the feature launched.

BEGIN;

ALTER TABLE public.users
    ADD COLUMN IF NOT EXISTS last_seen_at TIMESTAMP WITHOUT TIME ZONE;

COMMENT ON COLUMN public.users.last_seen_at IS
    'Last authenticated request from this user.  Bumped by '
    'Controller::requireBearer, throttled to once/minute.  NULL means '
    'no authenticated request has ever been observed.  Impersonation '
    'requests (admin view-as) do NOT bump this — see MyController '
    'applyImpersonation.';

COMMIT;
