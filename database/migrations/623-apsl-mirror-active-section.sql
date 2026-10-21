-- 623 (2026-10-21) — The APSL mirror names its section explicitly.
--
-- The TeamPass team page carries THREE grids — "Active Roster (20
-- Players)", "Reserve Roster (28 Players)", "Inactive Roster (2
-- Players)" — and the first-team source was leaning on "first grid on
-- the page" (mig 622's NULL behavior).  Explicit beats implicit:
-- pin it to the Active Roster heading, same mechanism as the
-- Reserves' row.

UPDATE official_roster_sources
   SET section_label = 'Active Roster'
 WHERE team_id = 35 AND system = 'teampass' AND section_label IS NULL;
