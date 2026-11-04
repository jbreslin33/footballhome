-- 1037: Roster pill NOT ON ROSTER lives under a team (owner 2026-11-04:
-- "on rosters page 'NOT ON ROSTER' should be under a team. put them all
-- under liga 1 for men … and for youth by age group").
-- teams.not_on_roster_home: on a board with such a column, every member
-- on no league roster is listed under it; on a board without one (youth)
-- each is listed under his own team (his age team).  Men: Liga 1 (120).

ALTER TABLE teams ADD COLUMN IF NOT EXISTS not_on_roster_home boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN teams.not_on_roster_home IS
  'mig 1037: #teams Roster pill lists every member of this board on no league roster under this team''s NOT ON ROSTER. No such team on a board = each under his own team (youth: age group).';
UPDATE teams SET not_on_roster_home = true WHERE id = 120;
