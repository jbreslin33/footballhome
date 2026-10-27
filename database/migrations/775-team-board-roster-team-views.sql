-- 775 (2026-10-27) — #teams right panel = "Players", two views by pill:
--   Roster (default) — the LEAGUE side: OFFICIAL ROSTER (the league list
--     1:1, planned drops flagged inside it), PROPOSED ADDS (grouped by
--     paperwork step), NON ROSTER PLAYERS.
--   Team — the FUNCTIONAL side: PLAYS, CALL-DOWNS ⭐, CALL INS ↔, NOT
--     FUNCTIONAL 📄 (paper spots), INJURED 🩹.
-- Owner: "there is a roster which is league and a team which is
-- functional" … "build it, planned drops stay in official, default
-- roster" … "should it be pill based so on 'teams' section (maybe rename
-- to players)? then we can have a pill for roster and one for teams".
--
-- Which Roster-view section a status lands in is a DB fact:
-- roster_statuses.board_section — 'proposed' (a paperwork step toward the
-- list), 'drop' (on the list, planned to come off), NULL (no section of
-- its own: On Roster lives on the list, the rest are non-roster).

ALTER TABLE roster_statuses ADD COLUMN IF NOT EXISTS board_section TEXT
    CHECK (board_section IN ('proposed', 'drop'));
COMMENT ON COLUMN roster_statuses.board_section IS 'mig 775: #teams Roster view — proposed = a step toward the league list (PROPOSED ADDS), drop = on the list but planned to come off (flagged inside OFFICIAL ROSTER), NULL = no section of its own';

UPDATE roster_statuses SET board_section = 'proposed'
 WHERE code IN ('needs_itc','submitted_itc','needs_transfer','awaiting_transfer',
                'needs_docs','has_docs','awaiting_roster_spot','awaiting_approval');
UPDATE roster_statuses SET board_section = 'drop' WHERE code = 'possible_drop';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', l, 'roster_sheet', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('board_panel_players',     'Team boards — right panel heading',                    '👥 Players',           933),
    ('board_view_roster',       'Team boards — Roster view pill (league side)',         'Roster',               934),
    ('board_view_team',         'Team boards — Team view pill (functional side)',       'Team',                 935),
    ('board_planned_drops',     'Team boards — official banner suffix ({n})',           '{n} planned drop',     936),
    ('board_planned_drop_chip', 'Team boards — flag on a planned-drop card',           '⬇ PLANNED DROP',       937),
    ('board_proposed_h',        'Team boards — Roster view: paperwork toward the list', 'PROPOSED ADDS',        938),
    ('board_plays_h',           'Team boards — Team view: plays',                       'PLAYS',                939),
    ('board_calldowns_h',       'Team boards — Team view: standing call-downs',         '⭐ CALL-DOWNS',        940),
    ('board_callins_h',         'Team boards — Team view: call ins',                    '↔ CALL INS',          941),
    ('board_not_functional_h',  'Team boards — Team view: paper spots',                 '📄 NOT FUNCTIONAL',    942),
    ('board_injured_h',         'Team boards — Team view: injured',                     '🩹 INJURED',           943)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.t);
