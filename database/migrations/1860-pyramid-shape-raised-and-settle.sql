-- 1860 (2026-11-24) — 🔺 Spin the pyramid: two more builds of the sloped pyramid to compare.
-- Owner: "its just that the slant makes it hard ter read sould we have it rotate as a pyramind
-- but when we stop and realeast it settings flat? or the text is raised 2d flat?" · "maybe 2
-- more versions. 3d pyramind raised text. 3d pyramid roate as pyramid but settle 2d".
-- Words only: the two new buttons beside 🧊 Boxy 3D / 🔺 Pyramid 3D / ▦ 2D chart (mig 1852).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT m.category, v.label, 'apsl_pyramid', v.tier, NULL, v.body, m.sort_order, true, true, m.is_public
  FROM message_templates m
  JOIN (VALUES
    ('Spin view: the sloped build with upright tables', 'shape_style_raised', '🔺 Raised text'),
    ('Spin view: the sloped build that lies flat at rest', 'shape_style_settle', '🔺 Settles flat')
  ) AS v(label, tier, body) ON true
 WHERE m.kind = 'apsl_pyramid' AND m.tier = 'shape_style_slope'
   AND NOT EXISTS (SELECT 1 FROM message_templates x WHERE x.kind = 'apsl_pyramid' AND x.tier = v.tier);
