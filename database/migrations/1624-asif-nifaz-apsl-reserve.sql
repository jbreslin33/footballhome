-- James 11/20: "he is getting added to apsl main soon ... will be a call down
-- so he should be regular liga 1 apsl reserve" + "for teams".
-- Team category only (not the league list): Asif Nifaz (22796) is a Regular
-- on Liga 1 (120, squad_status NULL — already so by mig 1623) and 🪑 Reserves
-- (squad_status 5 'standby') on APSL main, Lighthouse Mens Club 1893 (35).
-- Official roster status on 35 is left alone until he's actually added.
INSERT INTO team_persons (team_id, person_id, squad_status_id)
SELECT 35, 22796, 5
WHERE NOT EXISTS (SELECT 1 FROM team_persons
                  WHERE team_id = 35 AND person_id = 22796 AND removed_at IS NULL);
UPDATE team_persons SET squad_status_id = 5
 WHERE team_id = 35 AND person_id = 22796 AND removed_at IS NULL;
UPDATE team_persons SET squad_status_id = NULL
 WHERE team_id = 120 AND person_id = 22796 AND removed_at IS NULL;
