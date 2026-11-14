-- 1368 (2026-11-14) — Event Center slice 4: panels + 👀 See as
-- (docs/event-center-design.md).  Owner: "the coach screen should just be
-- more enhanced then player/parent. the admin just more enhanced then coach".
--
-- Every Event Center pill is now a list of Panels, each with the lowest
-- viewer tier that gets it (frontend/js/lib/panel.js).  A coach or admin can
-- drop to a lower tier on the open event to see exactly what that tier sees
-- (no server change: the screen swaps its Viewer).  These are the bar's words.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('See as — button: player view',  'see_as_player', '👀 See as player', 1320),
    ('See as — button: coach view',   'see_as_coach',  '👀 See as coach',  1321),
    ('See as — banner while viewing as {tier}', 'see_as_on', '👀 Viewing as {tier} — this is what they see', 1322),
    ('See as — button: back to my view', 'see_as_back', '↩ Back to my view', 1323),
    ('See as — tier word: player',    'tier_player',   'a player',          1324),
    ('See as — tier word: coach',     'tier_coach',    'a coach',           1325)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
