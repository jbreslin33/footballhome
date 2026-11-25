-- 1904 (2026-11-25) — 🗻 3D pyramid: the crown over the whole American pyramid — its levels and clubs,
-- and how deep it goes.  Owner: "American pyramid at top. number of levels and number of clubs. so apsl
-- what set the level of clubs at 9th level so 6 levels. right? but we can also say the pyramid goes 9
-- levels deep with the APSL feeder league CASA Massachusetts."  Drawn as a gold sign floating over the
-- apex (PyramidSolid crown, facing the camera from every side); levels = the deepest numbered level,
-- clubs counted once each across every side (cups' fields left out), the deep line names the league of
-- the deepest table (pyramid_competitions.name) and the side it feeds.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT m.category, v.label, 'apsl_pyramid', v.tier, NULL, v.body, m.sort_order + v.o, true, true, true
  FROM message_templates m
 CROSS JOIN (VALUES
   ('3D: crown over the whole pyramid ({levels}, {clubs})', 'shape_crown', 'American pyramid · {levels} levels · {clubs} clubs', 12),
   ('3D: crown, how deep ({levels}, {root}, {league})', 'shape_crown_deep', 'goes {levels} levels deep with the {root} feeder league {league}', 13)
 ) AS v(label, tier, body, o)
 WHERE m.kind = 'apsl_pyramid' AND m.tier = 'shape_close'
   AND NOT EXISTS (SELECT 1 FROM message_templates x WHERE x.kind = 'apsl_pyramid' AND x.tier = v.tier);
