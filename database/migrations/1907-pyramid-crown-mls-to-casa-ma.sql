-- 1907 (2026-11-25) — 🗻 3D pyramid crown: the deep line runs top to bottom.  Owner: "goes 9 levels deep
-- from mls division 1 to CASA Massachusets at divion 9".  {top} = the side of the level-1 table (MLS),
-- {top_n} its division, {league} the deepest table's competition, {levels} its division.
-- The Massachusetts league goes by "CASA Massachusetts" (owner's name for it; was "Casa League of
-- Massachusetts") — the same pattern as the other CASA leagues' names.
UPDATE message_templates
   SET label = '3D: crown, how deep ({levels}, {top}, {top_n}, {league})',
       body  = 'goes {levels} levels deep, from {top} at division {top_n} to {league} at division {levels}'
 WHERE kind = 'apsl_pyramid' AND tier = 'shape_crown_deep';
UPDATE pyramid_competitions SET name = 'CASA Massachusetts' WHERE id = 12 AND name = 'Casa League of Massachusetts';
