-- 1016: undo mig 1012's league move for Evan Watson (person 22589).
-- Owner 2026-11-03: "Evan Watson should be normal active. because teams
-- page is not rosters page the active players whether main or reserves
-- should be treated same".  He stays on APSL (35) so every APSL game asks
-- him; no NEEDS ADD to the Active list, no NEEDS DROP from the Reserve
-- list — he is on the Reserve list and that's fine.  The Team pill now
-- counts either APSL list as on the list.

BEGIN;

UPDATE team_persons SET roster_status_id = NULL
 WHERE team_id = 35 AND person_id = 22589 AND removed_at IS NULL
   AND roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'needs_add');

UPDATE team_persons SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'on_roster')
 WHERE team_id = 938 AND person_id = 22589 AND removed_at IS NULL
   AND roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'possible_drop');

COMMIT;
