-- 666 (2026-10-23) — game: the libero holds the line, moves into the ball's
-- channel (game/DESIGN.md §8.45).
--
-- James: "in defensive phases libero should stay with line until ball
-- carrier can play long forward. that is standard." / "he also moves into
-- ball channel. channels 2 3 and 4 … avoids channels 1 and 5 unless
-- absolute needed".
--
-- Five equal channels across 68 m (13.6 m each): 2-4 span |y| <= 20.4 m.
-- He follows the ball fully inside them and stops a step short of
-- channel 5's line; the long ball dropping out wide (met where it lands)
-- is the "absolutely needed". The line rule needs a new param:
-- level_offset_m, how far goal-side of the deepest teammate he stands while
-- the ball is covered.

UPDATE game_model_params SET value = 1.0,
       note = 'He moves into the ball''s channel — follows its lateral position fully, within channels 2-4.'
 WHERE owner = 'concept' AND code = 'libero' AND param = 'lateral_follow';
UPDATE game_model_params SET value = 19,
       note = 'Channels 2-4 only (5 x 13.6 m across 68 m → |y| <= 20.4): he stops a step inside channel 4. Wide = only to meet a long ball.'
 WHERE owner = 'concept' AND code = 'libero' AND param = 'lateral_max_m';
INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT 'concept', 'libero', 'level_offset_m', 0.5, 'm',
       'While the ball is covered he is part of the line, this far goal-side of the deepest teammate; sweeping depth only once their carrier can play long.'
 WHERE NOT EXISTS (SELECT 1 FROM game_model_params WHERE owner = 'concept' AND code = 'libero' AND param = 'level_offset_m');
