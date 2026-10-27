-- 752 (2026-10-27) — game: playing off, our full-back attacks their ball in
-- the air (game/DESIGN.md §8.67, G4.69).
--
-- James 10/27: "our full back needs to be agressive in reading the type of
-- pass when he is in the off coverage tactic. he does not 'wait' for ball to
-- reach. he reads pass. in the air he chases it and trys to recive facing
-- their goal to play forward. its bad to be running backwards toward own
-- goal but that is 2nd option. but if on ground he does normal intercept, no
-- turn, contain"

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'play-off-long-ball', 'face_up_m', 1.5::numeric, 'm', 'Their ball in the air for his man: he goes this far past where he can first take it, along its path, so it comes onto him facing their goal.')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);

UPDATE game_concepts
   SET cue_answer = 'Our winger shadows the ground ball to your winger, so play off him goal-side and guard the ball over the top. Read the pass on the kick: in the air, attack it and take it facing their goal (running back for it is the second option); on the ground, your 3 rules — intercept, no turn, contain. If he drops short you can step, but you won''t get tight — our winger keeps the shadow.'
 WHERE id = 170 AND name = 'play-off-long-ball';
