-- 1055: PPR Indoor max roster = 12 for every team (owner 2026-11-04: "max
-- roster size for ppr indoor is 12 for all tems").  The winter youth teams
-- play PPR Indoor: U9 (945), U10 (942), U12 (940).  teams.max_roster drives
-- the board's N/12 count and the Roster pill's over-the-max warning.

UPDATE teams SET max_roster = 12
 WHERE is_active AND gender_category IN ('boys', 'girls')
   AND id IN (SELECT team_id FROM team_terms WHERE term = 'winter');
