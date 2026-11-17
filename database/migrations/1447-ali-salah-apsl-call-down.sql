-- Ali Salah Alshami (person 3509) → APSL only, standing call-down to L1
-- (owner 11/17 "so ali salah we should move to just apsl then and he would
-- be a call down"). He is on the APSL Active list and on no CASA list, so
-- his L1 team row ends; the APSL → L1 standing call-down (mig 1446) keeps
-- him on every L1 game and practice. In the L1 squad he counts toward the
-- 2-per-game call-down cap.
UPDATE team_persons
   SET removed_at = now(), removed_reason = 'admin_remove',
       removed_details = jsonb_build_object('mig', 1447, 'why', 'APSL only; standing call-down to L1')
 WHERE person_id = 3509 AND team_id = 120 AND removed_at IS NULL;

INSERT INTO team_auto_invites (team_id, person_id, from_team_id, active)
VALUES (120, 3509, 35, true)
ON CONFLICT (team_id, person_id) DO UPDATE SET active = true, from_team_id = 35;

SELECT fh_team_auto_invites_backfill(120, 3509, 35);
