-- 248-practice-fh-event-optional.sql (2026-07-27)
-- club_game_model_practices originally required a real linked Google
-- Calendar event (fh_event_id NOT NULL) per migration 245's "one row per
-- REAL practice occurrence" design. In practice, Practice Plans is used
-- as a reusable weekly template per day-of-week (Tuesday..Saturday), and
-- most of those days have no real recurring calendar event to link to —
-- only Thursday does. Relax fh_event_id to optional so a day can get a
-- bare template practice row (day_id set, fh_event_id NULL) that sessions
-- hang off of. Thursday's existing calendar-linked row is unaffected.

BEGIN;

ALTER TABLE club_game_model_practices ALTER COLUMN fh_event_id DROP NOT NULL;

COMMIT;
