-- 1418 (2026-11-16) — ✅ Present tally atop an event's player list.
-- Owner: "it should show total present on calendar regardless if they set
-- going. it can show as a tally at top 3 present going, 2 preston no repson,
-- 5 total. or somethnig like that".
-- Page only (EventScreen._comingHtml presentTally): from the event's day on,
-- everyone marked Present / Late whatever they answered, split by answer;
-- coaches apart (never in the player total). Words only.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Event — present tally: total',          'present_total',      '✅ {n} present',           1340),
    ('Event — present tally: going',          'present_going',      '{n} going',                1341),
    ('Event — present tally: invited',        'present_invited',    '{n} invited',              1342),
    ('Event — present tally: no response',    'present_noresp',     '{n} no response',          1343),
    ('Event — present tally: said not going', 'present_notgoing',   '{n} said not going',       1344),
    ('Event — present tally: injured',        'present_injured',    '{n} injured',              1345),
    ('Event — present tally: ineligible',     'present_ineligible', '{n} ineligible (dues)',    1346),
    ('Event — present tally: other',          'present_other',      '{n} inactive / suspended', 1347),
    ('Event — present tally: not on list',    'present_offlist',    '{n} not on the list',      1348),
    ('Event — present tally: coaches',        'present_coaches',    '+ {n} coaches',            1349)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
