-- 830 (2026-10-29) — game: stay onside (concept 184, G4.91,
-- game/DESIGN.md §8.89).
--
-- James 10/29: "yes" (attackers come back onside when the ball isn't on).
-- Measured (fh-game-match, 5 matches LH APSL v Ukies): 1,075 men a match
-- stood in an offside position at a kick, on a third of all kicks; 41% of
-- them 8 m+ past the line, 74% 3 m+. Doing: holding shape 35% (the
-- possession shape put the front men past their back line), the run in
-- behind 32% (he got there and stayed), give and go 12%, blind-side run 10%.
-- Pro offsides called: 1.96 a team a match (mig 825). No concept said
-- "stay onside" — runs (5) and blind-side-run (30) only say it of their own
-- run. A core concept every level that knows offside plays, and every
-- top-level model asks for (mig 762).

BEGIN;

INSERT INTO game_concepts (id, name, title, family, moment, taught_from, status, cue_answer, lacking, principle_id) VALUES
 (184, 'stay-onside', 'Stay onside', 'individual', 'in_possession', 'u14', 'wired',
  'Our ball and you''re off it: wherever your job takes you, not past their offside line (their second-last man, the keeper counts; the ball; halfway) — onto it, half a metre short: on the last defender''s shoulder.',
  'Stands or keeps running past their line: every ball to him is offside, and he is out of the game until he walks back.',
  (SELECT id FROM game_principles WHERE code = 'ip-shape'))
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT 184, s.id, v.cit FROM (VALUES
 ('fh', 'James 10/29: "do we have offsides lol" → attackers come back onside (G4.91). Placed at u14 [FH]: offside is in the youth game from 9v9.'),
 ('ifab-lotg', 'Law 11.1: offside position — any part of the head, body or feet in the opponents'' half and nearer their goal line than both the ball and the second-last opponent.')
) AS v(code, cit) JOIN game_sources s ON s.code = v.code
ON CONFLICT DO NOTHING;

INSERT INTO game_concept_techniques (concept_id, technique_id)
SELECT 184, t.id FROM game_techniques t WHERE t.code IN ('run-off-shoulder', 'run-curved-onside')
ON CONFLICT DO NOTHING;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT 'concept', 'stay-onside', 'margin_m', 0.5, 'm',
       'He holds this far short of their offside line (the same half metre the run in behind rides).'
 WHERE NOT EXISTS (SELECT 1 FROM game_model_params WHERE owner = 'concept' AND code = 'stay-onside' AND param = 'margin_m');

-- Every top-level model asks for it: it is the law, not a style.
INSERT INTO game_model_concepts (model_id, concept_id, demand, citation)
SELECT m.id, 184, CASE WHEN m.name = 'Curriculum' THEN 100 ELSE 90 END,
       'G4.91: the law, not a style — every coach asks for it [FH].'
  FROM game_models m
 WHERE m.parent_id IS NULL
ON CONFLICT (model_id, concept_id) DO NOTHING;

COMMIT;
