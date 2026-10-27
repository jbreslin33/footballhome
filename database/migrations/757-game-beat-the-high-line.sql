-- 757 (2026-10-27) — game: beat the high line (180) — the keeper's
-- distribution reads it, or plays short (game/DESIGN.md §8.73, G4.75).
--
-- James 10/27: "why does ukie keeper go deep every time lol. its high line
-- i get it. but that is what a pro player would do. semi pro and amateur
-- and youth are dumber lol." / "high line go over top number 1 is a
-- concept but players should be rated on understanding it, percieving it,
-- ability to carry it out, etc"
--
-- Understanding = this concept (taught from semipro: below it nobody reads
-- it; a semipro at his quality, a pro and world better); perceiving = his
-- picture (scanning, anticipation); carrying it out = the lofted kick (his
-- passing error and range). Not read: the keeper's short, simple ball to an
-- open man within keeper_short_m — long only when nobody is open.

INSERT INTO game_concepts (id, name, title, family, moment, kind, taught_from, status, cue_answer, lacking, principle_id) VALUES
 (180, 'beat-the-high-line', 'Beat the high line', 'individual', 'in_possession', 'core', 'semipro', 'wired',
  'Their last defender is a long way off his goal line: put it over him, into the space behind, for our most advanced man to run onto.',
  'Plays it short into their press — or boots it anywhere — without seeing the space behind their line.',
  (SELECT id FROM game_principles WHERE code = 'ip-progress'))
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT 180, id, 'James 10/27: "high line go over top number 1 is a concept but players should be rated on understanding it, percieving it, ability to carry it out" — a pro reads it; semipro, amateur and youth less'
  FROM game_sources WHERE code = 'fh'
ON CONFLICT DO NOTHING;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'beat-the-high-line', 'high_m', 30::numeric, 'm', 'Their last outfield defender this far or more off his goal line is a high line.'),
 ('concept', 'beat-the-high-line', 'behind_m', 8, 'm', 'The ball drops this far behind him (never inside 6 m of their goal line).'),
 ('concept', 'beat-the-high-line', 'keeper_short_m', 25, 'm', 'Not read: the keeper''s short ball reaches an open man this far away (a split centre-back).')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);
