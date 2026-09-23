-- 413 — Per-team display names.
--
-- Owner 2026-09-23: "can we turn for liga 1 only isaac last name to
-- Modesto-Anderson lol. can we do that normalized in db."
--
-- A player can be listed under one name on one league's roster and
-- another elsewhere (Isaac Anderson is Modesto-Anderson on the Liga 1
-- roster, Anderson on APSL Reserves).  persons keeps the canonical name;
-- this table holds the name a person goes by ON A TEAM — a fact about
-- the (team, person) pair, so it survives team_persons rows being
-- removed and re-added.  NULL for either half means "canonical".
--
-- Readers wrap the persons columns:
--   fh_team_first_name(team_id, person_id, p.first_name)
--   fh_team_last_name (team_id, person_id, p.last_name)
-- (men's board, Game Center lineup/squad, team roster — 2026-09-23).
CREATE TABLE IF NOT EXISTS team_person_names (
  id          SERIAL PRIMARY KEY,
  team_id     INTEGER NOT NULL REFERENCES teams(id)   ON DELETE CASCADE,
  person_id   INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  first_name  TEXT,
  last_name   TEXT,
  note        TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (team_id, person_id),
  CHECK (NULLIF(BTRIM(first_name), '') IS NOT NULL OR NULLIF(BTRIM(last_name), '') IS NOT NULL)
);
CREATE INDEX IF NOT EXISTS idx_team_person_names_person ON team_person_names(person_id);

CREATE OR REPLACE FUNCTION fh_team_first_name(p_team_id integer, p_person_id integer, p_default text)
RETURNS text LANGUAGE sql STABLE AS $$
  SELECT COALESCE((SELECT NULLIF(BTRIM(n.first_name), '') FROM team_person_names n
                    WHERE n.team_id = p_team_id AND n.person_id = p_person_id), p_default)
$$;

CREATE OR REPLACE FUNCTION fh_team_last_name(p_team_id integer, p_person_id integer, p_default text)
RETURNS text LANGUAGE sql STABLE AS $$
  SELECT COALESCE((SELECT NULLIF(BTRIM(n.last_name), '') FROM team_person_names n
                    WHERE n.team_id = p_team_id AND n.person_id = p_person_id), p_default)
$$;

-- Isaac Anderson (22228) on Lighthouse Boys Club Liga 1 (120).
INSERT INTO team_person_names (team_id, person_id, last_name, note)
VALUES (120, 22228, 'Modesto-Anderson', 'Liga 1 roster lists him as Isaac Modesto-Anderson. Owner 2026-09-23.')
ON CONFLICT (team_id, person_id) DO UPDATE
   SET last_name = EXCLUDED.last_name, note = EXCLUDED.note, updated_at = now();
