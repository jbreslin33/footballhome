-- 1076: ↔ Call-in folds into 💤 Inactive (owner 2026-11-05: "i think we
-- can merge them and have a call in button on the inactive for that
-- event").  Before a call-in the two were the same — that team's games by
-- invite only, its practices seen but not asked, no fines — and the
-- call-in itself is the 🎟 invite.  So: Lucca Santos and Evan Watson
-- (APSL regulars on the Liga 1 list) are Inactive on Liga 1; Game Center
-- and Event Center put a 🎟 CALL IN button on every 💤 Inactive card of a
-- game — the 📇 popup with the call-up preselected; sending it invites
-- him, which drops him into No Response for that game (mig 1069).
-- The Team dropdown's ↔ Call-in option and the Team pill's CALL INS
-- group go.  team_persons.call_in stays (always false now).

BEGIN;

UPDATE team_persons
   SET squad_status_id = (SELECT id FROM squad_statuses WHERE code = 'inactive'),
       invite_only = true, call_in = false
 WHERE removed_at IS NULL AND call_in;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Contact', 'Call-in button on an Inactive card of a game', 'contact_popup', 'callin_button', NULL, '🎟 CALL IN', 1348, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'contact_popup' AND tier = 'callin_button');

UPDATE message_templates SET is_active = false
 WHERE kind = 'roster_sheet' AND tier IN ('team_status_callin', 'board_callins_h');

COMMIT;
