-- 1307 (2026-11-13) — ⚽ Teams pills on the player sheet: move / add / take off.
--
-- Owner 2026-11-13: "can it work like starters and bench. like a move
-- section that has pills for all the teams. then if i click another team it
-- asks do we want to move or add them to this team" / "have consistency
-- between screens".  The player sheet (player-sheet.js) draws one pill per
-- board team of his sections on EVERY screen that opens it (#teams, #members,
-- #rsvps, #tuition, #fines, Event Center, #person).  Lit = on that team.
-- Tap an unlit pill → "Move here (off <team>)" per team he is on, "Add", or
-- Cancel; tap a lit one → "Take off?".  "Move" is one transaction
-- (MensTeamAssignments::moveForPerson) via POST /api/person-teams; the
-- #teams card's own move list is gone from the sheet.  Words below
-- (kind player_sheet; {name} {team} {from} {teams} tokens).

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Player sheet', v.label, 'player_sheet', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('teams_heading',       'Player sheet — team pills heading',                       'Teams — tap to move, add or take off', 70),
    ('teams_domain_mens',   'Player sheet — team pills section: men',                  'Men', 71),
    ('teams_domain_womens', 'Player sheet — team pills section: women',                'Women', 72),
    ('teams_domain_boys',   'Player sheet — team pills section: youth (boys teams)',   'Youth', 73),
    ('teams_domain_girls',  'Player sheet — team pills section: girls',                'Girls', 74),
    ('teams_they',          'Player sheet — stands in for a player with no first name', 'them', 75),
    ('teams_on_tip',        'Player sheet — lit pill tooltip ({team})',                'On {team} — tap to take off', 76),
    ('teams_off_tip',       'Player sheet — unlit pill tooltip ({team})',              'Tap to move or add to {team}', 77),
    ('teams_locked_tip',    'Player sheet — 🔒 pill tooltip (on the league list)',     'On the league''s list — only the league takes them off', 78),
    ('teams_no_rights_tip', 'Player sheet — greyed pill tooltip (not your team)',      'You don''t run this team', 79),
    ('teams_ask',           'Player sheet — move/add question ({name} {team})',        'Put {name} on {team}?', 80),
    ('teams_move_from',     'Player sheet — Move button ({team} {from})',              'Move here (off {from})', 81),
    ('teams_add_also',      'Player sheet — Add button when already on teams ({team} {teams})', 'Add — stays on {teams} too', 82),
    ('teams_add',           'Player sheet — Add button when on no team ({team})',      'Add to {team}', 83),
    ('teams_cancel',        'Player sheet — Cancel button',                            'Cancel', 84),
    ('teams_remove_ask',    'Player sheet — take-off question ({name} {team})',        'Take {name} off {team}?', 85),
    ('teams_remove_yes',    'Player sheet — take-off button ({team})',                 'Take off {team}', 86),
    ('teams_moved',         'Player sheet — moved toast ({name} {team} {from})',       '{name} moved to {team}.', 87),
    ('teams_added',         'Player sheet — added toast ({name} {team})',              '{name} added to {team}.', 88),
    ('teams_removed',       'Player sheet — taken off toast ({name} {team})',          '{name} taken off {team}.', 89),
    ('teams_failed',        'Player sheet — save failed prefix',                       'Could not save', 90)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'player_sheet' AND t.tier = v.tier);
