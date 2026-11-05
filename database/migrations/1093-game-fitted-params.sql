-- 1093 — Game G5.23 (game/DESIGN.md §8.121): the fitted numbers the clean game reads, as rows.
-- They lived only in harness configs (GAME_PARAMS K1 / E4 / H1C); every other key in those
-- configs fed code that is now deleted. Fitted to real data: StatsBomb PL 2015/16 (time on
-- the ball, carries, crosses cut out) and DFL tracking (shape pace near goal, the slide across).
-- fh_game_scratch first; the live game DB with the ship (game/ship/README.md).

BEGIN;
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
  ('physics', 'body', 'shape_danger_m', 40, 'm', 'G5.10 §8.108: their ball inside this of our goal, shape at the defending pace (DFL) (mig 1093)'),
  ('physics', 'body', 'shape_danger_sprint', 1, 'flag', 'G5.10: no cap there at all (mig 1093)'),
  ('physics', 'tempo', 'cut_share_box', 1, 'share', 'G5.11 §8.108: box defenders cut out low crosses (StatsBomb 68%) (mig 1093)'),
  ('physics', 'tempo', 'box_reach_m', 1, 'm', 'G5.11: a box defender reaches out a leg (mig 1093)'),
  ('physics', 'shape', 'ours_shift_y', 0.47, 'share', 'G5.14 §8.111: in possession the shape slides with the ball across (DFL fit) (mig 1093)'),
  ('physics', 'body', 'shape_tau_ours_s', 1.0, 's', 'G5.14: with our ball the shape closes its gap in this (DFL) (mig 1093)'),
  ('physics', 'tempo', 'hold_one_touch', 0.277, 'share', 'G5.18 §8.115: real time on the ball (StatsBomb PL 15/16 hold curves) (mig 1093)'),
  ('physics', 'tempo', 'hold_under1', 0.453, 'share', 'G5.18 §8.115: real time on the ball (StatsBomb PL 15/16 hold curves) (mig 1093)'),
  ('physics', 'tempo', 'hold_under2', 0.730, 'share', 'G5.18 §8.115: real time on the ball (StatsBomb PL 15/16 hold curves) (mig 1093)'),
  ('physics', 'tempo', 'hold_under4', 0.921, 'share', 'G5.18 §8.115: real time on the ball (StatsBomb PL 15/16 hold curves) (mig 1093)'),
  ('physics', 'tempo', 'hold_pressed_one_touch', 0.436, 'share', 'G5.18 §8.115: real time on the ball (StatsBomb PL 15/16 hold curves) (mig 1093)'),
  ('physics', 'tempo', 'hold_pressed_under1', 0.657, 'share', 'G5.18 §8.115: real time on the ball (StatsBomb PL 15/16 hold curves) (mig 1093)'),
  ('physics', 'tempo', 'hold_pressed_under2', 0.829, 'share', 'G5.18 §8.115: real time on the ball (StatsBomb PL 15/16 hold curves) (mig 1093)'),
  ('physics', 'tempo', 'hold_pressed_under4', 0.949, 'share', 'G5.18 §8.115: real time on the ball (StatsBomb PL 15/16 hold curves) (mig 1093)'),
  ('physics', 'tempo', 'hold_pressed_m', 2.5, 'm', 'G5.18 §8.115: real time on the ball (StatsBomb PL 15/16 hold curves) (mig 1093)'),
  ('physics', 'tempo', 'hold_strict', 1, 'flag', 'G5.18 §8.115: real time on the ball (StatsBomb PL 15/16 hold curves) (mig 1093)'),
  ('physics', 'tempo', 'carry_share', 0.6, 'share', 'G5.18 §8.115: on the ball inside his hold, speed share (StatsBomb carries) (mig 1093)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
COMMIT;
