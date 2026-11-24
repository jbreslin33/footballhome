-- 1864 (2026-11-24) — 🗻 Solid 3D + standings: an eighth way to look at the pyramid — the solid with
-- every table in full (pos · club · GP · GD · Pts, zone colours) and the promotion / relegation
-- arrows drawn on its walls.  Owner: "build on that version and do one with the arrows and
-- stadings. the solid wiht text stanings and pro/rel".  Words only: its button.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT m.category, 'Spin view: the solid build with standings and arrows', 'apsl_pyramid', 'shape_style_standings', NULL, '🗻 Solid 3D + standings', m.sort_order, true, true, m.is_public
  FROM message_templates m
 WHERE m.kind = 'apsl_pyramid' AND m.tier = 'shape_style_teams'
   AND NOT EXISTS (SELECT 1 FROM message_templates x WHERE x.kind = 'apsl_pyramid' AND x.tier = 'shape_style_standings');
