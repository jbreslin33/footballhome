-- 501 (2026-09-30) — The league's own roster sheet, printed from Game Center.
-- Owner: "can we make a print roster from game center screen for apsl … it
-- has to be the official exact roster from site. so its more like
-- downloading it and storing it in db tied to that game. every new request
-- would overwrite the old and delete file so we get latest roster … it has
-- to printed fresh for each game technically. to prove the roster is
-- current to refs".  CASA and the youth leagues come next ("then after that
-- we can do it for casa. and maybe even the youth teams").
--
-- official_roster_sources says where a team's sheet lives on its league's
-- site; match_official_rosters holds the one copy per game (the bytes in
-- the DB are the only copy, replaced on every pull).  Pulled by
-- backend/src/services/TeamPassRoster.cpp, served by
-- /api/official-roster (OfficialRosterController), shown on the squad
-- pills (Starters & Bench, 20-Man Squad) of #game-center.

CREATE TABLE IF NOT EXISTS official_roster_sources (
  id               SERIAL PRIMARY KEY,
  team_id          INT  NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  league_label     TEXT NOT NULL,
  season           TEXT NOT NULL,
  system           TEXT NOT NULL,
  site_slug        TEXT NOT NULL,
  external_team_id TEXT NOT NULL,
  credentials_key  TEXT NOT NULL,
  is_active        BOOLEAN NOT NULL DEFAULT true,
  last_fetched_at  TIMESTAMPTZ,
  last_fetch_ok    BOOLEAN,
  last_fetch_note  TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (team_id, season)
);
COMMENT ON TABLE  official_roster_sources IS 'Where a team''s official roster sheet lives on its league site (mig 501). A new season is a new row; the old one goes is_active = false.';
COMMENT ON COLUMN official_roster_sources.league_label     IS 'Shown to coaches: "APSL".';
COMMENT ON COLUMN official_roster_sources.system           IS 'Which fetcher pulls it: teampass (TeamPassRoster).';
COMMENT ON COLUMN official_roster_sources.site_slug        IS 'teampass: the league segment of app.teampass.com/<slug>/Team/<id>.';
COMMENT ON COLUMN official_roster_sources.external_team_id IS 'teampass: the team id in that address. It changes every season.';
COMMENT ON COLUMN official_roster_sources.credentials_key  IS 'The staff login is the backend env pair <KEY>_EMAIL / <KEY>_PASSWORD; never stored here.';
CREATE UNIQUE INDEX IF NOT EXISTS official_roster_sources_one_active_idx ON official_roster_sources (team_id) WHERE is_active;

CREATE TABLE IF NOT EXISTS match_official_rosters (
  match_id   INT PRIMARY KEY REFERENCES matches(id) ON DELETE CASCADE,
  source_id  INT  NOT NULL REFERENCES official_roster_sources(id),
  mime       TEXT NOT NULL,
  byte_size  INT  NOT NULL,
  bytes      BYTEA NOT NULL,
  fetched_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  fetched_by INT REFERENCES persons(id) ON DELETE SET NULL
);
COMMENT ON TABLE match_official_rosters IS 'The league''s roster sheet as pulled for one game (mig 501): one row per game, replaced whole on every pull, bytes exactly as the league site sent them.';

-- Lighthouse 1893 SC, APSL 2026/2027.  One TeamPass team carries both the
-- Active and the Reserve roster, and APSL games are tagged with both teams
-- 35 and 938, so the row on 35 covers them.
INSERT INTO official_roster_sources (team_id, league_label, season, system, site_slug, external_team_id, credentials_key)
VALUES (35, 'APSL', '2026/27', 'teampass', 'APSL', '165430', 'APSL')
ON CONFLICT (team_id, season) DO NOTHING;

-- Panel copy (client_side rows, read through MessageCopy.block('official_roster', tier)).
CREATE OR REPLACE FUNCTION pg_temp.add_client_tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

SELECT pg_temp.add_client_tpl('official_roster', 'title',   'Official roster — panel title',
  '🖨 Official {league} roster', 1);
SELECT pg_temp.add_client_tpl('official_roster', 'hint',    'Official roster — what the button does',
  'The roster sheet exactly as {league} has it right now. Pull a fresh one for every game so the referee sees today''s roster.', 2);
SELECT pg_temp.add_client_tpl('official_roster', 'pull',    'Official roster — pull button',
  'Get today''s roster & print', 3);
SELECT pg_temp.add_client_tpl('official_roster', 'working', 'Official roster — while pulling',
  'Getting the roster from {league}…', 4);
SELECT pg_temp.add_client_tpl('official_roster', 'saved',   'Official roster — last pull',
  'Pulled for this game {when} by {name}.', 5);
SELECT pg_temp.add_client_tpl('official_roster', 'saved_anon', 'Official roster — last pull, no name',
  'Pulled for this game {when}.', 6);
SELECT pg_temp.add_client_tpl('official_roster', 'none',    'Official roster — nothing pulled yet',
  'Not pulled for this game yet.', 7);
SELECT pg_temp.add_client_tpl('official_roster', 'reopen',  'Official roster — open the saved copy',
  'Open that copy', 8);
SELECT pg_temp.add_client_tpl('official_roster', 'failed',  'Official roster — pull failed',
  'Could not get the roster from {league}: {reason}', 9);
