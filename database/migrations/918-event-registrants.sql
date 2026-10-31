-- 918 (2026-10-31) — LeagueApps event sign-ups, stored and nothing else.
-- Owner: keep the families from Nightmare in East in our own DB in case we
-- ever leave LeagueApps; "we are just storing in the db."  Deliberately NOT
-- leads (#contacts, #dashboard and #leads all read that table) and NOT persons
-- or memberships (fh_in_leagueapps() and rosters).  Nothing in the app reads
-- these two tables, and nobody here has been opted in to anything.
-- Rows load via scripts/la-event-registrants.py, DB only, never git.

CREATE TABLE IF NOT EXISTS la_events (
  id             SERIAL PRIMARY KEY,
  la_program_id  BIGINT UNIQUE NOT NULL,
  name           TEXT NOT NULL,
  event_date     DATE NOT NULL,
  created_at     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS la_event_registrants (
  id                  SERIAL PRIMARY KEY,
  la_event_id         INTEGER NOT NULL REFERENCES la_events(id) ON DELETE CASCADE,
  la_registration_id  BIGINT UNIQUE NOT NULL,
  la_user_id          BIGINT,
  la_parent_user_id   BIGINT,
  user_type           TEXT,
  first_name          TEXT,
  last_name           TEXT,
  birth_date          DATE,
  gender              TEXT,
  email               TEXT,
  phone               TEXT,
  parent_first_name   TEXT,
  parent_last_name    TEXT,
  parent_email        TEXT,
  parent_phone        TEXT,
  address1            TEXT,
  city                TEXT,
  state               TEXT,
  zip_code            TEXT,
  registered_at       TIMESTAMP WITH TIME ZONE,
  loaded_at           TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS la_event_registrants_event_idx
  ON la_event_registrants (la_event_id);

INSERT INTO la_events (la_program_id, name, event_date)
VALUES (5148876, 'Nightmare in East', '2026-10-30')
ON CONFLICT (la_program_id) DO NOTHING;
