-- 1012: Evan Watson (person 22589) is APSL's regular starting keeper
-- (owner 2026-11-03: "he should just be active right?").
--
-- He was on APSL only through the Reserves call-up pool (7 call-ups) and
-- the TeamPass Reserve list.  Back on APSL (35) so every APSL game asks
-- him, as NEEDS ADD for the Active list; his Reserves row (938) goes to
-- Possible Drop (NEEDS DROP) because no man is on both APSL lists
-- (roster_team_rules, mig 820).  The Reserves row stays until TeamPass
-- moves him; the next pull settles both lists.

BEGIN;

INSERT INTO team_persons (team_id, person_id, roster_status_id)
SELECT 35, 22589, (SELECT id FROM roster_statuses WHERE code = 'needs_add')
 WHERE EXISTS (SELECT 1 FROM persons WHERE id = 22589 AND first_name = 'Evan' AND last_name = 'Watson')
   AND NOT EXISTS (SELECT 1 FROM team_persons WHERE team_id = 35 AND person_id = 22589 AND removed_at IS NULL);

UPDATE team_persons
   SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'possible_drop')
 WHERE team_id = 938 AND person_id = 22589 AND removed_at IS NULL;

COMMIT;
