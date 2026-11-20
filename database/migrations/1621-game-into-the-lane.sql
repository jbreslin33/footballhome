-- G5.197 (game/DESIGN.md §8.303): "get in line of the shot". Real shots have an outfielder a median 0.56 m off the
-- ball-goal line (StatsBomb PL 15/16 freeze frames, 1+ within 1 m 71%); ours 3.4 m (27%), blocked 16.3% (29.1).
--   lane_m 3 — their man on the ball within lane_range_m (30, code default) of our goal centre: a holder / marker of ours
--              goal-side of him and within 3 m of the ball-goal line moves onto it (Brain::intoTheLane)
-- 5 m tried: no more blocks, goals back up, the card down. Rows, not code defaults: goldens unchanged.
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'block', 'lane_m', 3, 'm', 'G5.197 §8.303: a holder / marker goal-side of their carrier (within 30 m of our goal) this close to the ball-goal line steps onto it; 0 = off')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
