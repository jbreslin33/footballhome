-- 1926 (2026-11-26): stay in pressing distance — the STEP aims goal side, not just toward his man.
-- Owner 11/25: "being able to press but the player can dribble to our goal lol is bad as we are 'chasing'" ·
-- "to be correct fully we need to prevent forward progress right?". Mig 1920 made goal side a read; this makes the
-- step act on it: from his place, the spot toward his man a reach off him — unless that spot is not goal side, then
-- the spot on his man's line to our goal, a reach off him (never past half that line). Max 6 m off his place as before.
-- Only with physics.pressdist.hold > 0 (no row = 0): goldens unchanged; the concept room / clip build see it.

INSERT INTO game_engine_behaviours (code, file, line, tag, who, what, status, concept_id, other_concepts, suggested, confidence, is_read, in_sim)
SELECT 'pd_step_goal_side', 'game/src/ai/concepts/PressingDistance.cpp', 67, 'pressing distance step goal side 11/26', 'individual',
       'The pressing-distance step ends goal side of his man: if the spot toward his man (a reach off him) would leave him level or beyond, the spot is on his man''s line to our goal, a reach off him (never past half that line). With the dial at zero the sim does not use it.',
       'concept', 164, '', NULL, 'high', false, false
 WHERE NOT EXISTS (SELECT 1 FROM game_engine_behaviours WHERE code = 'pd_step_goal_side');

UPDATE game_engine_behaviours SET line = 59, what = what || ' Goal side since mig 1926: see pd_step_goal_side.'
 WHERE code = 'pd_step_into_distance' AND what NOT LIKE '%mig 1926%';
