-- G5.258 / G5.259 (game/DESIGN.md §8.364-8.365): two carrier-side capabilities from THE TACKLER'S ANGLE (§8.363) —
-- real carriers lose it off their feet from the side and behind nearly as often as from the front (DFL); ours half or
-- less. Both are in World and both are OFF: no rows physics.dribble.press_err_* / physics.steal.nick_* (0).
--   dribble_touch_under_pressure: his dribble touch with a man inside 1.5 m is knocked off its line and runs on, a roll a
--     touch by where that man stands. Trial: heavy-touch losses overshoot (1.4 -> 6.6 at 0.10 / 0.15, real 4.1) while
--     the side / behind off-feet rates do not move — a miscontrol, not a dispossession.
--   dispossess_by_angle: a man within 1.5 m of the carrier takes it off his feet, no tackle, no foul (StatsBomb
--     Dispossessed 13.8 a team-match), a rate a second by where he stands.
INSERT INTO game_engine_behaviours (code, file, line, tag, who, what, status, concept_id, other_concepts, suggested, confidence, is_read, in_sim)
SELECT v.code, 'game/src/core/World.cpp', 1, 'carrier under pressure 11/24', 'individual', v.what, 'unnamed', NULL, v.other, NULL, 'high', false, false
  FROM (VALUES
    ('dribble_touch_under_pressure', 'press-the-bad-touch',
     'With an opponent inside 1.5 m, the carrier''s dribble touch can be knocked off its line and run on — more likely when the man is beside or behind him, who cannot be shielded or seen. A chance a touch by where that man stands (physics.dribble.press_err_front / _side / _behind); with no rows it is 0 and the touch is as fitted.'),
    ('dispossess_by_angle', 'engage-or-contain',
     'A defender within 1.5 m of the carrier gets a foot to the ball and takes it off him without a tackle or a foul — from beside or behind as well as in front. A rate a second by where he stands (physics.steal.nick_front / _side / _behind_per_s); with no rows it is 0 and only a man touch-tight on the ball can take it.')
  ) AS v(code, other, what)
ON CONFLICT (code) DO NOTHING;

-- G5.259 rows: dispossessed by angle at the StatsBomb count. One step (0.05 / 0.13 / 0.19 a s, the DFL rate gaps) put
-- carry losses off the feet at 12.5 a team-match (StatsBomb PL 15/16 8.0); x0.37 = 8.4. Seeds 1000-4000 x 8 v G5.254:
-- side / behind off-feet rates 0.27-0.35 / 0.16-0.29 -> 0.32-0.39 / 0.21-0.30 (DFL 0.43-0.47 / 0.39-0.47); off his feet
-- in their wide last third 5.5 -> 6.4 (11.4); fouls 14.1 -> 12.8 (12.5); passes 415 -> 433 (434). Cost: take-on success
-- 57.7 -> 50.7% (58.7) — the man beside him in the duel. The touch error stays at zero (no rows).
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'steal', 'nick_front_per_s', 0.02, '/s', 'G5.259 §8.365: a man within 1.5 m in front of the carrier takes it off his feet, a rate a second'),
 ('physics', 'steal', 'nick_side_per_s', 0.05, '/s', 'G5.259 §8.365: … beside him'),
 ('physics', 'steal', 'nick_behind_per_s', 0.07, '/s', 'G5.259 §8.365: … behind him')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
UPDATE game_engine_behaviours SET in_sim = true WHERE code = 'dispossess_by_angle';
