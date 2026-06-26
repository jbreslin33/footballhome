-- 055-person-field-overrides.sql
--
-- Generic per-field admin overrides for the canonical `persons` row.
-- Goal: separate the *source* of truth (LeagueApps, GroupMe, future native
-- football-home tables) from the *displayed* value, so we can:
--   1. Admin-edit any LA-/GM-sourced field locally without round-tripping
--      to the upstream system.
--   2. Show a visible "overridden" badge + the original upstream value.
--   3. One-click clear the override → instantly snap back to the live
--      upstream value, no migration required.
--   4. Later swap the source (e.g. RSVP from GroupMe → in-app) by
--      changing the resolver routing, with no schema or UI changes.
--
-- Field naming convention (`field_name`):
--   Person-scoped (single row per (person_id, field)):
--     firstName, lastName, birthDate, parentFirstName, parentLastName,
--     parentEmail, parentPhone, jerseyNumber, isKeeper, paymentStatus, …
--   Event-scoped (override RSVP for a specific event — RARE, prefer
--   `chat_event_rsvps.override_rsvp_status_id` for that use case):
--     "rsvp:<chat_event_id>"  e.g. "rsvp:12345"
--
-- `source_was` records which upstream source the value came from at the
-- moment the override was set, so the resolver can decide whether the
-- upstream has since changed and prompt a re-sync.

CREATE TABLE IF NOT EXISTS person_field_overrides (
  id              SERIAL PRIMARY KEY,
  person_id       INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  field_name      TEXT    NOT NULL,
  value           TEXT,             -- NULL is a legal overridden value (e.g. "blank out parent email")
  source_was      TEXT,             -- 'la' | 'gm' | 'footballhome' | NULL (no prior upstream value)
  original_value  TEXT,             -- snapshot of the upstream value at override time, for diffing
  note            TEXT,             -- optional admin-supplied reason
  set_by_user_id  INTEGER REFERENCES users(id) ON DELETE SET NULL,
  set_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (person_id, field_name)
);

CREATE INDEX IF NOT EXISTS idx_person_field_overrides_person
  ON person_field_overrides (person_id);
CREATE INDEX IF NOT EXISTS idx_person_field_overrides_field
  ON person_field_overrides (field_name);
