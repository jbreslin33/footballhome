-- 1862 (2026-11-24) — 🗻 Solid 3D: a sixth way to look at the pyramid — a real solid (three.js) that is
-- a MAP of the levels (level · league · how many clubs), the tables opening flat beside it.
-- Owner: "idk stil not happy with the 3d models. there has got to be a better way. threejs?" ·
-- "lets add 6th and try it".  Words only: its button, its hint, and the count under a league.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT m.category, v.label, 'apsl_pyramid', v.tier, NULL, v.body, m.sort_order, true, true, m.is_public
  FROM message_templates m
  JOIN (VALUES
    ('Spin view: the solid build (three.js)', 'shape_style_solid', '🗻 Solid 3D'),
    ('Solid view: how to use it', 'shape_hint_solid', 'Drag sideways to turn · up or down to tilt · scroll or ± to zoom · tap a level to open its tables'),
    ('Solid view: clubs on a level', 'shape_solid_clubs', '{n} clubs'),
    ('Solid view: tables and clubs on a level', 'shape_solid_tables', '{t} tables · {n} clubs'),
    ('Solid view: leagues not named on a level', 'shape_solid_more', '+{n} more')
  ) AS v(label, tier, body) ON true
 WHERE m.kind = 'apsl_pyramid' AND m.tier = 'shape_style_slope'
   AND NOT EXISTS (SELECT 1 FROM message_templates x WHERE x.kind = 'apsl_pyramid' AND x.tier = v.tier);
