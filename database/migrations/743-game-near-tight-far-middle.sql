-- 743 (2026-10-26) — game: mark by distance from the ball (game/DESIGN.md
-- §8.65, G4.67). Wires near-tight-far-zone (122, queued since the
-- curriculum import) and places it at U-14.
--
-- James 10/26: "marking should be proximal to ball. so further away from
-- ball the more you protect middle … closer to ball the more tight" / "that
-- will make our fb play more central on build out by ukies".
--
-- The ball within near_m of his man: tight_m off him, goal-side and
-- ball-side. Out at far_m: loose_m off him, goal-side and toward the middle.
-- In between, both the gap and the direction blend on a straight line.

UPDATE game_concepts
   SET status = 'wired', taught_from = 'u14',
       cue_answer = 'The nearer your man is to the ball, the tighter you mark him — goal-side and ball-side. The further away, the more you drop off him toward the middle and protect it.',
       lacking = 'The same gap everywhere: tight on a man 40 m from the ball while the middle is open, or loose next to the ball.'
 WHERE id = 122 AND name = 'near-tight-far-zone';

INSERT INTO game_concept_links (concept_id, other_id, kind) VALUES
 (122, 158, 'refines'), (122, 160, 'requires')
ON CONFLICT DO NOTHING;

INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT 122, id, 'James 10/26: "marking should be proximal to ball. so further away from ball the more you protect middle … closer to ball the more tight"'
  FROM game_sources WHERE code = 'fh'
ON CONFLICT DO NOTHING;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'near-tight-far-zone', 'near_m', 10::numeric, 'm', 'His man within this of the ball: as tight as he gets.'),
 ('concept', 'near-tight-far-zone', 'far_m', 35, 'm', 'His man this far from the ball or more: as far off him, toward the middle, as he gets.'),
 ('concept', 'near-tight-far-zone', 'tight_m', 1, 'm', 'Gap to his man next to the ball (goal-side, ball-side).'),
 ('concept', 'near-tight-far-zone', 'loose_m', 6, 'm', 'Gap to his man far from the ball (goal-side, toward the middle).')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);

-- Lighthouse marks this way (James 10/26). It inherited Bielsa's 20 (Bielsa
-- marks tight everywhere), which held it to one second in five; both
-- Lighthouse tactics inherit this row.
INSERT INTO game_model_concepts (model_id, concept_id, demand, citation)
SELECT m.id, 122, 90, 'Tight near the ball, protect the middle away from it (James 10/26).'
  FROM game_models m WHERE m.name = 'Lighthouse APSL'
ON CONFLICT (model_id, concept_id) DO UPDATE SET demand = EXCLUDED.demand, citation = EXCLUDED.citation;
