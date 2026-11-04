-- 1040: 👀⚽ on the player card replaces the column's 👀 Sees games pill
-- (owner 2026-11-04: "get rid of the sees games pill … just an eye ball and
-- soccer ball … the game they see is then obvious because of column they
-- are in").  The chip means this column's games reach him with no
-- per-game invite (a roster row that grants games, or a ⭐ standing invite).

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', v.label, 'roster_sheet', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Team boards — card chip: sees this column''s games', 'card_sees_games', '👀⚽', 1020),
    ('Team boards — card chip tooltip: sees games', 'card_sees_games_tip', 'Asked about every {team} game automatically — no call-up needed', 1021)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.tier);
