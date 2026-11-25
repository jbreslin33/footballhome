-- 1901 (2026-11-25) — 🗻 3D pyramid: a header over each league's pyramid — its clubs and levels.
-- Owner: "we need to show at top of pyramind the total amount of clubs in the pyrmaid and total
-- levels. for apsl e.g. this header would go right above level 4".  Drawn in gold above "Level N"
-- on the top level of every league's side (PyramidShapeView._banners); clubs counted once each
-- (a club's second side — II, B, Reserves, U23 — is the same club), levels = its numbered steps.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT m.category, '3D: header over a league''s pyramid ({league}, {clubs}, {levels})', 'apsl_pyramid', 'shape_side_header', NULL,
       '{league} pyramid · {clubs} clubs · {levels} levels', m.sort_order + 11, true, true, true
  FROM message_templates m
 WHERE m.kind = 'apsl_pyramid' AND m.tier = 'shape_close'
   AND NOT EXISTS (SELECT 1 FROM message_templates x WHERE x.kind = 'apsl_pyramid' AND x.tier = 'shape_side_header');
