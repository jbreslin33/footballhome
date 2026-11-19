-- 1557 (2026-11-19) — #teams Graphic team cards check the league rules between official rosters.
--
-- Owner: "we need to show a flag if a player is on reserves official but
-- not on liga 1 offiical as that is illegal with league and if they saw it
-- we would have to fix".  The rules already exist (roster_team_rules, mig
-- 820: APSL Reserves requires Liga 1; APSL excludes Reserves) and the
-- Roster view's columns flag them; the Graphic team cards did not.
--   · box corner: red ILLEGAL tag (hover = which rule)
--   · card top: red ⚠ INELIGIBLE banner naming everyone on the card's
--     official lists who breaks a rule (from the lists themselves, so a
--     listed man not on our board still shows)
-- On 11/19 all 26 APSL Reserve names were on the CASA Liga 1 sheet
-- (4 spelled differently there), so nothing shows today.
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Roster sheet', 'Team card box: corner flag — breaks a league roster rule (roster_team_rules)', 'roster_sheet', 'tc_flag_illegal', 'ILLEGAL', 906, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = 'tc_flag_illegal');
