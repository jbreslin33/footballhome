-- 124-player-event-reminders-fh-events.sql (2026-07-17)
--
-- Repoint `player_event_reminders` from `matches.id` to `fh_events.id`.
--
-- Follows migration 123 which dropped `player_rsvp_history` +
-- `player_recurring_rsvps` + purged pickup rows from `matches`.  The
-- new reminder surface (`POST /api/events/:fhEventId/remind`) targets
-- fh_events.  Existing reminder rows are magic-link tokens with a
-- 48-hour TTL that are already expired by the time this runs, so
-- clearing them out is safe.

BEGIN;

DELETE FROM player_event_reminders;

ALTER TABLE player_event_reminders
    DROP CONSTRAINT IF EXISTS player_event_reminders_match_id_fkey;

ALTER TABLE player_event_reminders
    DROP CONSTRAINT IF EXISTS player_event_reminders_fh_event_id_fkey;

DROP INDEX IF EXISTS idx_player_event_reminders_match_person;

ALTER TABLE player_event_reminders
    RENAME COLUMN match_id TO fh_event_id;

ALTER TABLE player_event_reminders
    ALTER COLUMN fh_event_id TYPE bigint USING fh_event_id::bigint;

ALTER TABLE player_event_reminders
    ADD CONSTRAINT player_event_reminders_fh_event_id_fkey
        FOREIGN KEY (fh_event_id) REFERENCES fh_events(id) ON DELETE CASCADE;

CREATE INDEX idx_player_event_reminders_fh_event_person
    ON player_event_reminders (fh_event_id, person_id, sent_at DESC);

COMMIT;
