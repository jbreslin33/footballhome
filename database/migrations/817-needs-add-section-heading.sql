-- 817 (2026-10-29) — NEEDS ADD on the #teams Roster pill.
--
-- Owner: "if he is on apsl 'team' would he not be a 'needs add' in
-- roster?" … "build the needs add section too".  Derived on the board: on
-- the team in FH, not on its official roster, no roster step, not a
-- call-in — listed above PROPOSED ADDS until a step is set (→ PROPOSED
-- ADDS) or he is marked Not on Roster.  Only on teams that keep a league
-- roster.  This row is the section heading.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', 'Team boards — Roster pill: on the team, not on the official roster, no step yet',
       'roster_sheet', 'board_needs_add_h', NULL, 'NEEDS ADD — on the team, not on the official roster', 954, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = 'board_needs_add_h');
