-- 123-rip-legacy-pickup-rsvp.sql (2026-07-17)
--
-- Wholesale removal of the legacy pickup/practice RSVP surface.
--
-- The new canonical event/RSVP system lives in `fh_events` +
-- `fh_event_rsvps` + `fh_recurring_rsvps`, fed by the Google Calendar
-- mirror (`gcal_events` + `gcal_calendars`).  Members RSVP via
-- /#calendar (CalendarScreen → /api/calendar/*).  This migration
-- removes the pre-gcal surface it replaces.
--
-- User directive (2026-07-17): "no la handles membership status and dues
-- paid/balance. fh handles due date. gcal handles event creation and
-- details. fh ties into that and adds on rsvp and attendence(later).
-- right now we need you to focus on the event system for practice
-- pickup and games. it needs to use the gcal to get events from google
-- cals then using our coding sysetem it gets put in fh db and displaeyd
-- to players to rsvp to."
--
-- Data migration was performed BEFORE running this migration by:
--   scripts/migrate-legacy-pickup-rsvps.js        (per-event → fh_event_rsvps)
--   scripts/migrate-legacy-pickup-standing.js     (standing prefs → fh_recurring_rsvps)
--
-- REAL LEAGUE MATCH RSVPs on player_rsvp_history are lost by this
-- migration (accepted trade — league matches don't currently flow
-- through gcal, so once ops adds them there, RSVPs go through the new
-- surface).

BEGIN;

-- ---- delete legacy pickup rows in matches -------------------------
--
-- match_type_id = 7 is the "Pickup" match type — every row here is a
-- synthetic pickup that was materialised by RsvpMaterialization from
-- match_series templates.  Now handled by fh_events.
DELETE FROM matches WHERE match_type_id = 7;

-- ---- drop dependent view + tables ---------------------------------
DROP VIEW  IF EXISTS player_rsvps_current;
DROP TABLE IF EXISTS player_rsvp_history    CASCADE;
DROP TABLE IF EXISTS player_recurring_rsvps CASCADE;

-- ---- tighten check_match_teams constraint -------------------------
--
-- Previous constraint allowed match_type_id IN (2, 3, 5, 7) to skip
-- home/away requirements (custom / practice / tournament / pickup).
-- Pickup (7) is dropped from that list now that pickup lives in
-- fh_events.
ALTER TABLE matches DROP CONSTRAINT IF EXISTS check_match_teams;
ALTER TABLE matches ADD  CONSTRAINT check_match_teams CHECK (
  (match_type_id = ANY (ARRAY[2, 3, 5]))
  OR (home_team_id IS NOT NULL AND away_team_id IS NOT NULL)
);

COMMIT;
