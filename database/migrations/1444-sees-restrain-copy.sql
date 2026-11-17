-- 👁 SEES restrain controls' words (mig 1443 mechanism; owner 11/17 "we
-- just need the restraint mechanism").
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Roster Sheet', v.label, 'roster_sheet', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('card_sees_via_list',        'Card — SEES: games come from an official league list',        '📋', 1525),
    ('card_sees_restrain',        'Card — SEES: restrain button on a list pill (admins)',        '🚫', 1526),
    ('card_sees_restrain_tip',    'Card — SEES: restrain button tooltip ({team})',               'On the official list, so asked about {team} games. Tap to restrain.', 1527),
    ('card_sees_unrestrain',      'Card — SEES: lift-restraint button (admins)',                 '↺', 1528),
    ('card_sees_unrestrain_tip',  'Card — SEES: lift-restraint tooltip ({team})',                'Restrained from {team} games. Tap to ask him again.', 1529),
    ('card_sees_why_restrained',  'Card — SEES: restrained from a team''s games',                '🚫 restrained', 1530)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'roster_sheet' AND t.tier = v.tier);
