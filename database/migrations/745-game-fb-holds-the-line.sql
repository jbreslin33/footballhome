-- 745 (2026-10-27) — game: Lighthouse's second tactic (shadow the line) —
-- our full-back doesn't follow his winger up the field (game/DESIGN.md
-- §8.63, answer (a)).
--
-- James 10/27: "on the cover shadow winger to fb by our winger yes you keep
-- cover shadow. reason is our fb is already playing for long ball and "off"
-- coverage so to follow a winger up the field is too much to ask."
--
-- Their winger drops short: our winger keeps the shadow on the full-back →
-- winger line (as built), and our full-back, playing off for the long ball,
-- stops at our highest centre-back plus ahead_of_line_m.

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'play-off-long-ball', 'ahead_of_line_m', 0::numeric, 'm', 'Playing off, he never goes further up than our highest centre-back plus this — he doesn''t follow a winger who drops short.')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);

UPDATE game_concepts
   SET cue_answer = 'Our winger shadows the ground ball to your winger, so play off him goal-side and guard the ball over the top. If he drops short, let him go — stay with the back line; our winger keeps the shadow.'
 WHERE id = 170 AND name = 'play-off-long-ball';
