-- 1006-youth-fall-rosters-frozen.sql
--
-- Owner 11/3: "no needs added needed for youth in fall as rosters are
-- frozen. same with needs drop".  A team's roster can be frozen for a
-- season: #teams' Roster pill then shows only ON ROSTER for that team under
-- that season pill — no NEEDS ADD (or its NO ROOM step), no NEEDS DROP, no
-- PROJECTED.  Per team per season, on team_terms (mig 795); change it by
-- migration.  Youth = the Boys teams (girls play on them), fall.

ALTER TABLE team_terms ADD COLUMN IF NOT EXISTS roster_frozen boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN team_terms.roster_frozen IS 'mig 1006: the league roster is frozen this season — #teams Roster pill shows no NEEDS ADD / NEEDS DROP for this team under this season pill.';

UPDATE team_terms tt SET roster_frozen = true
  FROM teams t
 WHERE t.id = tt.team_id AND t.gender_category IN ('boys', 'girls') AND tt.term = 'fall';
