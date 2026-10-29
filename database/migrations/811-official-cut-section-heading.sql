-- 811 (2026-10-29) — the cut players get their own red block at the foot of
-- OFFICIAL ROSTER on the #teams Roster pill.
--
-- Owner: "we want them in section at bottom so they still count on official
-- roster total wise but should be in a red section". The block sits inside
-- OFFICIAL (its count still includes them); they no longer repeat under
-- DROPPING, so board_cut_note (mig 807) is retired.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', 'Team boards — Roster pill: red block closing OFFICIAL for cut players (no playing LeagueApps membership)',
       'roster_sheet', 'board_cut_h', NULL, '✂ CUT — still on the official roster, needs to be dropped', 953, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = 'board_cut_h');

UPDATE message_templates SET is_active = false WHERE kind = 'roster_sheet' AND tier = 'board_cut_note';
