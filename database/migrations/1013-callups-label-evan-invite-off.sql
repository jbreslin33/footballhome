-- 1013: standing invites are named by direction (owner 2026-11-03: "call
-- downs belong in liga 1 right? it does not effect apsl. apsl col should
-- be call ups right?").  APSL's riders come up from Liga 1 = ⭐ CALL-UPS;
-- Liga 1's come down from APSL = ⭐ CALL-DOWNS (unchanged).  Evan Watson
-- is on APSL itself now (mig 1012), so his standing call-up is off.

BEGIN;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', 'Team boards — Team pill: standing invites from a lower team', 'roster_sheet', 'board_callups_h',
       NULL, '⭐ CALL-UPS · every game', 1014, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = 'board_callups_h');

UPDATE team_auto_invites SET active = false
 WHERE team_id = 35 AND person_id = 22589 AND active;

COMMIT;
