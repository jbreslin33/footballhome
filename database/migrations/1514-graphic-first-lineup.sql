-- 1514 (2026-11-18) — Graphic-first lineup for coaches and admins.
-- Owner 11/18: "i think if we can do the graphic as most of the work of
-- setting lineup and attendance then we do it imo. we can always have a
-- more 'text' based option that can be turned on in hamburger? and then
-- stays on over sessions until turned off" + "i picture if we click a
-- player during start of practice or game it adds in attendance option".
--
-- Every name on the live card is a tap (the move sheet, ✅ attendance on top
-- from game day); an empty spot asks who plays there; Formation / Match
-- opponent / availability / split squad are ☰ items; 📝 Text view brings
-- back the card lists.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Event ☰ — text view switch',          'menu_text_view',  '📝 Text view',                       1423),
    ('Event ☰ — formation',                 'menu_formation',  '📐 Formation · {formation}',         1424),
    ('Event ☰ — match opponent',            'menu_matchup',    '🆚 Match opponent',                  1425),
    ('Event ☰ — show availability',         'menu_avail_show', '👁 Show availability',               1426),
    ('Event ☰ — hide availability',         'menu_avail_hide', '👁 Hide availability',               1427),
    ('Formation sheet — title',             'sheet_formation', '📐 Formation',                       1428),
    ('Empty spot sheet — title',            'fill_title',      'Who plays #{number} · {position}?',  1429),
    ('Empty spot sheet — going, unplaced',  'fill_unplaced',   'Going · not placed',                 1430),
    ('Empty spot sheet — bench',            'fill_bench',      'Bench',                              1431),
    ('Empty spot sheet — alternate',        'fill_alt',        'Alternate',                          1432),
    ('Empty spot sheet — no response',      'fill_noresp',     'No response',                        1433)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
