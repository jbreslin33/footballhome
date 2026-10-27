-- 776 (2026-10-27) — the #teams Roster pill is only the league to-do list:
-- OFFICIAL ROSTER, PROPOSED ADDS, REMOVE (the planned drops by name + their
-- official #; the cards stay in OFFICIAL so it remains 1:1 with the list).
-- Owner: "for rosters we only need official, proposed and remove right? we
-- dont need evan etc there for apsl for example that is a team thing" —
-- non-roster players and call-downs now show on the Team pill only.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', 'Team boards — Roster view: planned drops to take off the list', 'roster_sheet', 'board_remove_h', NULL, 'REMOVE', 944, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = 'board_remove_h');

-- NON ROSTER PLAYERS (mig 770) no longer renders anywhere.
UPDATE message_templates SET is_active = false WHERE kind = 'roster_sheet' AND tier = 'board_non_roster_h';
