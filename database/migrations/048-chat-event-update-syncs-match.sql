-- Migration 048: GroupMe is source of truth — propagate chat_event updates to matches
--
-- Background:
-- ──────────────────────────────────────────────────────────────────────
-- The original trigger `trg_chat_event_create_match` only fires AFTER
-- INSERT (see data/059-fix-chat-event-match-trigger.sql).  That means
-- when the GroupMe sync upserts a chat_event row and Postgres routes
-- it through the ON CONFLICT DO UPDATE path, the linked `matches` row
-- is never re-synced.  Result: a GroupMe calendar event that gets
-- renamed (e.g. opponent changed from Phoenix → Vidas), rescheduled,
-- or relocated keeps its old title/date/time/location on the matches
-- table forever, and every UI surface that joins through `matches`
-- shows stale data.
--
-- This migration:
--   1. Adds `matches.manual_override` so coaches can pin a manual edit
--      and have GroupMe stop clobbering it.  Default FALSE => GroupMe
--      wins by default, which matches our stated policy ("GroupMe is
--      source of truth except when manually overridden").
--   2. Adds an AFTER UPDATE trigger on chat_events that re-syncs
--      title, match_date, match_time (and clears description drift)
--      onto the linked matches row, but only when manual_override is
--      FALSE.
--   3. Backfills every drifted match row right now so historical
--      drift (like the 2026-06-18 U23 Vs Phoenix → Vidas case) gets
--      corrected immediately.
-- ──────────────────────────────────────────────────────────────────────

BEGIN;

-- ── 1. Add the manual_override flag ──────────────────────────────────
ALTER TABLE matches
    ADD COLUMN IF NOT EXISTS manual_override BOOLEAN NOT NULL DEFAULT FALSE;

COMMENT ON COLUMN matches.manual_override IS
    'When TRUE, GroupMe (or any other upstream sync) is forbidden from overwriting title/match_date/match_time. Set this when a coach edits the match manually and we should preserve their values.';

-- ── 2. Trigger function: re-sync match fields from chat_event ────────
CREATE OR REPLACE FUNCTION chat_event_sync_match()
RETURNS TRIGGER AS $$
DECLARE
    v_new_date   DATE;
    v_new_time   TIME;
BEGIN
    -- No linked match yet → nothing to sync (INSERT trigger will create
    -- one if appropriate).
    IF NEW.match_id IS NULL THEN
        RETURN NULL;
    END IF;

    -- Only act if the user-visible fields actually changed.  This keeps
    -- noisy rsvp_snapshot-only updates from burning a write on matches.
    IF NEW.title           IS NOT DISTINCT FROM OLD.title
       AND NEW.event_date  IS NOT DISTINCT FROM OLD.event_date
       AND NEW.event_time  IS NOT DISTINCT FROM OLD.event_time
       AND NEW.start_at    IS NOT DISTINCT FROM OLD.start_at
    THEN
        RETURN NULL;
    END IF;

    v_new_date := COALESCE(
        NEW.event_date,
        (NEW.start_at AT TIME ZONE 'America/New_York')::date
    );
    v_new_time := COALESCE(
        NEW.event_time,
        (NEW.start_at AT TIME ZONE 'America/New_York')::time
    );

    -- Respect manual_override: skip the row silently.  Coach wins.
    UPDATE matches
       SET title      = NEW.title,
           match_date = v_new_date,
           match_time = v_new_time
     WHERE id = NEW.match_id
       AND manual_override = FALSE;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION chat_event_sync_match() IS
    'Propagates title/date/time changes from chat_events to the linked matches row. Skips rows where manual_override = TRUE so coach edits stick.';

-- ── 3. Wire the AFTER UPDATE trigger ─────────────────────────────────
DROP TRIGGER IF EXISTS trg_chat_event_sync_match ON chat_events;
CREATE TRIGGER trg_chat_event_sync_match
    AFTER UPDATE ON chat_events
    FOR EACH ROW
    WHEN (
        NEW.title          IS DISTINCT FROM OLD.title
        OR NEW.event_date  IS DISTINCT FROM OLD.event_date
        OR NEW.event_time  IS DISTINCT FROM OLD.event_time
        OR NEW.start_at    IS DISTINCT FROM OLD.start_at
    )
    EXECUTE FUNCTION chat_event_sync_match();

-- ── 4. Backfill: heal every drifted match row right now ──────────────
-- For every linked (chat_event, match) pair where the title/date/time
-- has drifted, force the match to match the chat_event.  Skip rows
-- where someone has set manual_override = TRUE.
WITH drift AS (
    SELECT ce.id          AS chat_event_id,
           ce.match_id    AS match_id,
           ce.title       AS new_title,
           COALESCE(
               ce.event_date,
               (ce.start_at AT TIME ZONE 'America/New_York')::date
           ) AS new_date,
           COALESCE(
               ce.event_time,
               (ce.start_at AT TIME ZONE 'America/New_York')::time
           ) AS new_time
      FROM chat_events ce
      JOIN matches m ON m.id = ce.match_id
     WHERE m.manual_override = FALSE
       AND (
              m.title      IS DISTINCT FROM ce.title
           OR m.match_date IS DISTINCT FROM COALESCE(ce.event_date, (ce.start_at AT TIME ZONE 'America/New_York')::date)
           OR m.match_time IS DISTINCT FROM COALESCE(ce.event_time, (ce.start_at AT TIME ZONE 'America/New_York')::time)
       )
)
UPDATE matches m
   SET title      = d.new_title,
       match_date = d.new_date,
       match_time = d.new_time
  FROM drift d
 WHERE m.id = d.match_id;

COMMIT;
