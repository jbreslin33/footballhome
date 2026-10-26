-- 700 (2026-10-26) — game: pressed with no pass on, keep it
-- (game/DESIGN.md §8.56, G4.60).
--
-- The phase harness (§8.55) showed Lighthouse, attacking into the
-- Ukies' mid-block, losing 59% of its balls to the touch-tight clear: a
-- hoof upfield from halfway. James 10/26, on what a closed-down player
-- does with no pass on: shield and turn back, play it back to a centre
-- back or the keeper, hoof it only in his own third — "yes that is right".

INSERT INTO game_concepts (id, name, title, family, moment, kind, taught_from, status, cue_answer, lacking, principle_id) VALUES
 (161, 'keep-it-under-pressure', 'Pressed with no pass: keep it', 'individual', 'in_possession', 'core', 'u10', 'wired',
  'Closed down and nothing on forward: put your body between him and the ball and turn away, back toward your own goal, then play it back to a centre back or the keeper. Kick it away only in your own third.',
  'Closed down at halfway, he boots it up the pitch to nobody: the ball comes straight back.', 3)
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT c, id, cite FROM game_sources, (VALUES
  (161, 'fh', 'James 10/26: shield and turn back, play it back to a CB or the keeper, hoof only in your own third'),
  (161, 'coaching-standard', 'shield the ball: body between man and ball, turn away from pressure; if you cannot go forward, go back (FA / US Soccer possession principles)')
) AS v(c, code, cite)
WHERE game_sources.code = v.code
ON CONFLICT DO NOTHING;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'keep-it-under-pressure', 'own_third_m', 35::numeric, 'm', 'Within this of his own goal line a pressed man may still kick it away.'),
 ('concept', 'keep-it-under-pressure', 'back_pass_max_m', 30, 'm', 'Longest pass back he plays to a teammate goal-side of him.'),
 ('concept', 'keep-it-under-pressure', 'shield_step_m', 3, 'm', 'Shielding, he carries the ball this far away from the presser each look.'),
 ('concept', 'keep-it-under-pressure', 'shield_speed_share', 0.5, 'share', 'Shielding pace as a share of his top speed — he protects it, he does not run.')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);
