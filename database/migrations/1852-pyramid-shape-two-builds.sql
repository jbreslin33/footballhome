-- 1852 (2026-11-24) — 🔺 Spin the pyramid: two builds to compare, and a way to the flat chart.
-- Owner: "the pyramid shape is causling problems. it is blurry and it don't lets rotatate it
-- straigt. maybe we need 2 types of pyramids and we can see wich one is btter. and the 2d one".
-- · "a boxy one like 3d cube and a pyramide one like 3d pyramind and hte old chool 2d view. we
-- would be able to tooggle on that screen not in hamburger".
-- Words only: the three buttons at the top right of the shape and of the 2D chart.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT m.category, v.label, 'apsl_pyramid', v.tier, NULL, v.body, m.sort_order + v.n, true, true, m.is_public
  FROM message_templates m
  JOIN (VALUES
    (1, 'Spin view: the stepped build', 'shape_style_step', '🧊 Boxy 3D'),
    (2, 'Spin view: the sloped build', 'shape_style_slope', '🔺 Pyramid 3D'),
    (3, 'Spin view: go to the flat chart', 'shape_style_flat', '▦ 2D chart')
  ) AS v(n, label, tier, body) ON true
 WHERE m.kind = 'apsl_pyramid' AND m.tier = 'shape_hint'
   AND NOT EXISTS (SELECT 1 FROM message_templates x WHERE x.kind = 'apsl_pyramid' AND x.tier = v.tier);
