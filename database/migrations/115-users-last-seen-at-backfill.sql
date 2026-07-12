-- 115-users-last-seen-at-backfill.sql
--
-- Backfill `users.last_seen_at` from the pre-existing activity ledgers.
-- Migration 114 added the column and Controller::requireBearer started
-- populating it, but that only works going *forward* — every user shows
-- "💤 Never logged in" until they next authenticate against the new
-- backend, which is misleading (many have been setting availability,
-- posting to team chats, etc. for weeks).
--
-- This migration seeds `last_seen_at` from the union of the tables that
-- record "the human clicked a thing" — RSVP history, chat messages, and
-- successful login history.  The heartbeat in requireBearer keeps it
-- fresh from here on; if a user is currently silent in every ledger
-- they'll stay NULL, which is what we want for the "🚫 Never logged in"
-- signal.
--
-- Idempotent: takes GREATEST() with the existing value, so re-running
-- can only move the timestamp forward, never backward.

BEGIN;

WITH activity(user_id, ts) AS (
    -- New event RSVP log (chat_events + person-scoped, populated by the
    -- RSVP trigger on chat_event_rsvps and by explicit admin overrides).
    SELECT changed_by_user_id, MAX(changed_at)
      FROM event_rsvp_log
     WHERE changed_by_user_id IS NOT NULL
     GROUP BY changed_by_user_id

    UNION ALL

    -- Legacy per-player RSVP history — the primary "player set their
    -- availability" signal (287 rows / 44 users at time of writing).
    SELECT changed_by, MAX(changed_at)
      FROM player_rsvp_history
     WHERE changed_by IS NOT NULL
     GROUP BY changed_by

    UNION ALL

    -- Parent-on-behalf-of-child RSVP history.
    SELECT changed_by, MAX(changed_at)
      FROM parent_rsvp_history
     WHERE changed_by IS NOT NULL
     GROUP BY changed_by

    UNION ALL

    -- Coach RSVP history.
    SELECT changed_by, MAX(changed_at)
      FROM coach_rsvp_history
     WHERE changed_by IS NOT NULL
     GROUP BY changed_by

    UNION ALL

    -- Team chat activity — writing a message requires being authed.
    SELECT user_id, MAX(created_at)
      FROM chat_messages
     WHERE user_id IS NOT NULL
     GROUP BY user_id

    UNION ALL

    -- Successful password / magic-link logins.
    SELECT user_id, MAX(created_at)
      FROM login_history
     WHERE user_id IS NOT NULL AND success = TRUE
     GROUP BY user_id

    UNION ALL

    -- Historical last_login_at column (dead in prod today but harmless
    -- if any row ever gets populated by an older code path).
    SELECT id, last_login_at
      FROM users
     WHERE last_login_at IS NOT NULL
),
best AS (
    SELECT user_id, MAX(ts) AS ts
      FROM activity
     GROUP BY user_id
)
UPDATE users u
   -- event_rsvp_log.changed_at is timestamptz; the target column is
   -- `timestamp without time zone`, so cast at the boundary.
   SET last_seen_at = GREATEST(
           COALESCE(u.last_seen_at, '-infinity'::timestamp),
           (b.ts AT TIME ZONE 'UTC')::timestamp
       )
  FROM best b
 WHERE b.user_id = u.id
   AND b.ts IS NOT NULL;

COMMIT;
