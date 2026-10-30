-- 905 (2026-10-30) — #teams: total players beside the Roster | Team pills' board.
--
-- Owner: "show me total players when roster or teams pill are hit".  Each
-- person once, however many team columns they sit in.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', 'Team boards — total players for the lit pill ({n})', 'roster_sheet', 'board_total', NULL, '{n} players total', 944, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = 'board_total');
