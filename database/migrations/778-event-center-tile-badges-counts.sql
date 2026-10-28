-- 778: Event Center week tiles lead with WHO is playing (owner 2026-10-28:
-- "the thing i need highlighted is u8, or u10 or liga 1 or apsl or tri
-- county. so start time, end time, u8 travel vs x, full address. going
-- total, not responded total, not going total").
--
-- The badge is the team's own label + colour (teams.label / teams.color,
-- now in the calendar feed's teams); the game line is "{team} vs
-- {opponent}"; the counts are players only (coaches never in a player
-- total) off the feed's roster, which already honours call-up gates and
-- paper spots.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', l, 'event_center', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('tile_vs',         'Week tile — game line ({team} {opponent})',      '{team} vs {opponent}', 1220),
    ('tile_going',      'Week tile — players going ({n})',                '✓ {n} going',          1221),
    ('tile_noresp',     'Week tile — players not answered ({n})',         '– {n} no response',    1222),
    ('tile_notgoing',   'Week tile — players not going ({n})',            '✗ {n} not going',      1223),
    ('tile_ineligible', 'Week tile — said going, over the dues line ({n})', '⛔ {n} ineligible',   1224)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.t);
