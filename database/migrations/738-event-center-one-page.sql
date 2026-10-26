-- 738: Event Center — one page, type pills (owner 2026-10-26: "instead of
-- game center it could be event center … all in one with pills").
-- 🏟️ Games opens Game Center; 🏃 Practices / ⚽ Pickup / 📅 All open the
-- event list (screens/event-center.js).  One role-picker tile replaces the
-- Game Center and Attendance tiles.  Copy for lib/event-kind-switch.js and
-- the tile.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', l, 'event_center', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('title',          'Page title',                         '📋 Event Center', 1180),
    ('tile_title',     'Role picker tile',                   'Event Center', 1181),
    ('tile_sub',       'Line under the role picker tile',    'Games, practices and pickup — squads, who''s coming, attendance, groups', 1182),
    ('list_sub',       'Line under the title on the event list', 'Pick a day, then the practice or pickup — who''s coming, attendance, groups, invites', 1183),
    ('pill_match',     'Type pill — games',                  '🏟️ Games', 1184),
    ('pill_practice',  'Type pill — practices',              '🏃 Practices', 1185),
    ('pill_pickup',    'Type pill — pickup',                 '⚽ Pickup', 1186),
    ('pill_all',       'Type pill — everything',             '📅 All', 1187)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.t);
