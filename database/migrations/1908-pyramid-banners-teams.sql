-- 1908 (2026-11-25) — 🗻 3D pyramid: the gold banners count teams as well as clubs.  Owner: "we have to
-- list clubs total and "teams" total we should count 2nd teams as anther team in toal temas but not
-- another club. try to calc that best you can with fuzzy logic and put that in the yellow banner".
-- {teams} = every table row (the same team once); {clubs} = their clubs, a II / B / Reserves side folded
-- into its club (PyramidShapeView._tally: the APSL data's club_id first, then boiled-down names).
UPDATE message_templates SET label = '3D: header over a league''s pyramid ({league}, {clubs}, {teams}, {levels})',
       body = '{league} pyramid · {clubs} clubs · {teams} teams · {levels} levels'
 WHERE kind = 'apsl_pyramid' AND tier = 'shape_side_header';
UPDATE message_templates SET label = '3D: crown over the whole pyramid ({levels}, {clubs}, {teams})',
       body = 'American pyramid · {levels} levels · {clubs} clubs · {teams} teams'
 WHERE kind = 'apsl_pyramid' AND tier = 'shape_crown';
