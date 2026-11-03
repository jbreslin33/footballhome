-- 1007-teams-league-roster.sql
--
-- Owner 11/3: "for youth rosters page its only 3 real rosters. u8,u10,u12.
-- take out u19".  teams.league_roster says whether a team keeps a league
-- roster; false leaves its column off #teams' Roster pill (the Team pill
-- still shows it — they train).  Default true; U19 (932) has none.

ALTER TABLE teams ADD COLUMN IF NOT EXISTS league_roster boolean NOT NULL DEFAULT true;
COMMENT ON COLUMN teams.league_roster IS 'mig 1007: false = no league roster; #teams Roster pill leaves the column out, the Team pill keeps it.';

UPDATE teams SET league_roster = false WHERE id = 932 AND name = 'U19';
