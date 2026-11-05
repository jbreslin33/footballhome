-- 1084 (owner 2026-11-05): "make him [David Naranjo] active and on roster put
-- him as needs add.  and on roster put lucca santos as needs drop for liga 1
-- and reserves. then put him as needs ad for apsl main."
--   David Naranjo (22496), Liga 1 (120): 💤 Inactive → ACTIVE; Roster status
--     Needs Add (paid up, $0; not on the CASA list yet).  His 11/2 Yes for
--     Sunday's Desert Hawks game counts again.
--   Lucca Santos (22698): Roster status NEEDS DROP (possible_drop) on Liga 1
--     (120) and APSL Reserves (938); Needs Add on APSL (35).  Team statuses
--     unchanged (Inactive on Liga 1, ACTIVE on APSL / Reserves).
--   Evan Watson (22589): first applied (as "1083") to him by mistake —
--     wrong person id; his Roster statuses go back to what they were
--     (APSL none, Liga 1 On Roster, Reserves On Roster).

BEGIN;

UPDATE team_persons
   SET squad_status_id = NULL, invite_only = false, call_in = false,
       roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'needs_add')
 WHERE team_id = 120 AND person_id = 22496 AND removed_at IS NULL;

-- Undo the mix-up on Evan Watson.
UPDATE team_persons SET roster_status_id = NULL
 WHERE team_id = 35 AND person_id = 22589 AND removed_at IS NULL;
UPDATE team_persons SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'on_roster')
 WHERE team_id IN (120, 938) AND person_id = 22589 AND removed_at IS NULL;

-- Lucca Santos.
UPDATE team_persons
   SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'possible_drop')
 WHERE team_id IN (120, 938) AND person_id = 22698 AND removed_at IS NULL;
UPDATE team_persons
   SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'needs_add')
 WHERE team_id = 35 AND person_id = 22698 AND removed_at IS NULL;

COMMIT;
