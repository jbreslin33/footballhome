-- 🎯 Tactics pill: ⛶ Big (full-screen view) and the pitch's orientation
-- choice, ↕ Upright / ↔ Sideways (owner 2026-11-07: "player number pills
-- need to be smaller and we also need a large full screen tactical page …
-- should be choice of orientations").  Copy only; the pitch work is
-- frontend (components/tactics-pitch.js, screens/game-center.js).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', l, 'tactics', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('big',              'Game Center — 🎯 Tactics: open the full-screen view', '⛶ Big',      1250),
    ('big_close',        'Game Center — 🎯 Tactics: leave the full-screen view', '✕ Close',   1251),
    ('orient_portrait',  'Game Center — 🎯 Tactics: pitch upright (our goal at the bottom)', '↕ Upright', 1252),
    ('orient_landscape', 'Game Center — 🎯 Tactics: pitch sideways (our goal on the left)',  '↔ Sideways', 1253)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'tactics' AND m.tier = v.t);
