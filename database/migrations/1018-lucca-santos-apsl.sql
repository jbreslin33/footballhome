-- 1018: Lucca Santos (person 22698) is ACTIVE on APSL (owner 2026-11-03:
-- "santos should be active apsl").  He rode APSL as a standing call-up
-- from Liga 1; now on APSL (35) itself, so every APSL game asks him, and
-- the standing call-up is off.  No league move — he's on the APSL Reserve
-- list, which the Team pill counts as on the APSL list (mig 1016).

BEGIN;

INSERT INTO team_persons (team_id, person_id)
SELECT 35, 22698
 WHERE EXISTS (SELECT 1 FROM persons WHERE id = 22698 AND first_name = 'Lucca' AND last_name = 'Santos')
   AND NOT EXISTS (SELECT 1 FROM team_persons WHERE team_id = 35 AND person_id = 22698 AND removed_at IS NULL);

UPDATE team_auto_invites SET active = false
 WHERE team_id = 35 AND person_id = 22698 AND active;

COMMIT;
