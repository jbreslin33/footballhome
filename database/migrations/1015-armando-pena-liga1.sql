-- 1015: Armando Pena (person 22710) belongs on Liga 1 (owner 2026-11-03:
-- "pena needs to be liga 1 needs onboard").  He rode Liga 1 only as a
-- standing call-down from APSL (his Liga 1 row was admin-removed 10/20).
-- Back on Liga 1 as a full spot; the standing call-down is off since he's
-- on the team.  He has never answered an RSVP, so the Team pill shows him
-- under NEEDS ONBOARD until he does.  His APSL paper spot stays (he is on
-- the APSL Active list).

BEGIN;

INSERT INTO team_persons (team_id, person_id)
SELECT 120, 22710
 WHERE EXISTS (SELECT 1 FROM persons WHERE id = 22710 AND first_name = 'Armando' AND last_name = 'Pena')
   AND NOT EXISTS (SELECT 1 FROM team_persons WHERE team_id = 120 AND person_id = 22710 AND removed_at IS NULL);

UPDATE team_auto_invites SET active = false
 WHERE team_id = 120 AND person_id = 22710 AND active;

COMMIT;
