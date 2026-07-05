-- 086-rsvp-recurring-and-sources.sql (2026-07-04)
--
-- Adds recurring-RSVP support for players.
--
-- Two changes:
--   1. Extend `rsvp_change_sources` lookup with two new rows:
--        4 = 'recurring'  — RSVP auto-materialised from a player's
--                          player_recurring_rsvps preference at week
--                          rollover or event creation.
--        5 = 'reminder'   — RSVP set by the player in response to a
--                          coach-issued reminder magic-link.
--      These reuse the existing player_rsvp_history.change_source_id
--      column — no schema change on the history table itself.
--
--   2. New table `player_recurring_rsvps` capturing "I usually go on
--      Tuesdays and Thursdays" preferences.  Materialisation lands
--      real rows into player_rsvp_history with change_source_id=4.
--
-- Design notes:
--   • Composite PK on (person_id, day_of_week, match_type_id) means a
--     player can have one preference per (day, event type) tuple.
--     e.g. (alice, 2, 7) = "Tuesday pickup, going".  Independent from
--     (alice, 2, 3) = "Tuesday practice" (unlikely combo, but valid).
--   • rsvp_status_id nullable NOT because absence is meaningful — an
--     absent row simply means "no preference".  A row with any status
--     (yes / no / maybe) is the preference itself.  Deleting the row
--     removes the preference; setting it to `no` means "usually not
--     going" (still useful signal for coach).
--   • updated_at trigger reuses existing set_updated_at() from
--     migration 069.

BEGIN;

-- 1. Extend rsvp_change_sources.
INSERT INTO rsvp_change_sources (id, name, description) VALUES
  (4, 'recurring', 'RSVP auto-applied from a player recurring preference'),
  (5, 'reminder',  'RSVP set in response to a coach reminder magic-link')
ON CONFLICT (id) DO NOTHING;

-- 2. Recurring RSVP preferences.
CREATE TABLE IF NOT EXISTS player_recurring_rsvps (
  person_id      INTEGER      NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  day_of_week    SMALLINT     NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
  match_type_id  INTEGER      NOT NULL REFERENCES match_types(id),
  rsvp_status_id INTEGER      NOT NULL REFERENCES rsvp_statuses(id),
  created_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  PRIMARY KEY (person_id, day_of_week, match_type_id)
);

CREATE INDEX IF NOT EXISTS idx_player_recurring_rsvps_person
  ON player_recurring_rsvps (person_id);

CREATE TRIGGER trg_player_recurring_rsvps_updated_at
  BEFORE UPDATE ON player_recurring_rsvps
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

COMMIT;
