-- 770 (2026-10-27) — #teams columns split into OFFICIAL ROSTER (On Roster
-- status, A–Z) then NON ROSTER PLAYERS, each with its count.
-- Owner: "first who is on official league roster in alpha order by last
-- name. then the random non official roster guys put in a section under
-- the official guys called non roster players. run a count on each".
-- Section headings — RosterScreenBase.renderRosterSplit.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', l, 'roster_sheet', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('board_official_h',   'Team boards — official league roster section', 'OFFICIAL ROSTER',    929),
    ('board_non_roster_h', 'Team boards — players not on the league roster', 'NON ROSTER PLAYERS', 930)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.t);

-- Owner follow-up: "your roster group should match 1 to 1 the official
-- roster … same order they appear on official league roster. this should
-- not be editable" — the section is the 🌐 list verbatim; a list name
-- tied to no FH person wears this note.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', 'Team boards — league list name with no FH person', 'roster_sheet', 'board_official_unmatched', NULL, 'not in Football Home', 931, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = 'board_official_unmatched');
