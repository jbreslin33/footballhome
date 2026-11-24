-- 1863 (2026-11-24) — 🗻 Solid 3D with every team on it: a seventh way to look at the pyramid.
-- Owner, on the solid build (mig 1862): "ok keep solid 3d. and add solid 3d but put all the teams".
-- Words only: its button.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT m.category, 'Spin view: the solid build with every team', 'apsl_pyramid', 'shape_style_teams', NULL, '🗻 Solid 3D + teams', m.sort_order, true, true, m.is_public
  FROM message_templates m
 WHERE m.kind = 'apsl_pyramid' AND m.tier = 'shape_style_solid'
   AND NOT EXISTS (SELECT 1 FROM message_templates x WHERE x.kind = 'apsl_pyramid' AND x.tier = 'shape_style_teams');
