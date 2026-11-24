-- G5.249 (game/DESIGN.md §8.355): the pass chooser's two margin lifts refitted on today's game (real ÷ ours, StatsBomb PL
-- 15/16) — they were what raised a central midfielder's ball to the central man beside him from the table's 35% to 47-49%
-- (THE CHOOSER'S CHAIN, §8.354).
--   len_lift (§8.236, fitted when ours ran long: 0-10 m 64-68 a team-match v 99): today 137 / 156 / 61 / 30 / 13.5 / 8.5
--   by 10 m v 118 / 176 / 73 / 28 / 12.7 / 7.1 — two steps of real ÷ ours.
--   short_dir (§8.249's rows, unset until now): a pass under 20 m by the kick's band off the line attacked x forward /
--   lateral / back; 52-70 m out ours 25.9 / 58.0 / 20.7 a team-match v 26.8 / 38.3 / 13.3, 35-52 22.8 / 46.7 / 20.2 v
--   25.8 / 40.2 / 16.0, 70+ 15.2 / 27.4 / 7.1 v 21.9 / 22.0 / 6.5. The two bands nearest their goal are short by volume,
--   not direction: left at 1.
-- Seeds 1000-4000 x 8: short passes 52-70 m out 26.7 / 47.6 / 16.6; lengths 120 / 157 / 70 / 30 / 12.6 / 7.9; a central
-- midfielder's same-zone ball 48.2 -> 42.3% (35.8); the next stint one band up from 52-70 m 14.8 -> 16.2% (19.1).
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'pass', 'len_lift_0', 1.625, 'x', 'G5.249 §8.355: a mate''s weight by the pass''s length 0-10 m (was 2.08, §8.236)'),
 ('physics', 'pass', 'len_lift_1', 0.891, 'x', 'G5.249 §8.355: … 10-20 m (was 0.755)'),
 ('physics', 'pass', 'len_lift_2', 0.580, 'x', 'G5.249 §8.355: … 20-30 m (was 0.44)'),
 ('physics', 'pass', 'len_lift_3', 0.325, 'x', 'G5.249 §8.355: … 30-40 m (was 0.34)'),
 ('physics', 'pass', 'len_lift_4', 0.80, 'x', 'G5.249 §8.355: … 40-50 m (was 0.85)'),
 ('physics', 'pass', 'len_lift_5', 0.835, 'x', 'G5.249 §8.355: … 50 m+ (was 1)'),
 ('physics', 'pass', 'short_dir_2_0', 1.13, 'x', 'G5.249 §8.355: a pass under 20 m struck 35-52 m off the line attacked, forward (within 45 deg) — StatsBomb ÷ ours'),
 ('physics', 'pass', 'short_dir_2_1', 0.86, 'x', 'G5.249 §8.355: … 35-52 m, lateral'),
 ('physics', 'pass', 'short_dir_2_2', 0.79, 'x', 'G5.249 §8.355: … 35-52 m, back'),
 ('physics', 'pass', 'short_dir_3_0', 1.03, 'x', 'G5.249 §8.355: … 52-70 m, forward'),
 ('physics', 'pass', 'short_dir_3_1', 0.66, 'x', 'G5.249 §8.355: … 52-70 m, lateral'),
 ('physics', 'pass', 'short_dir_3_2', 0.64, 'x', 'G5.249 §8.355: … 52-70 m, back'),
 ('physics', 'pass', 'short_dir_4_0', 1.44, 'x', 'G5.249 §8.355: … 70 m+, forward'),
 ('physics', 'pass', 'short_dir_4_1', 0.80, 'x', 'G5.249 §8.355: … 70 m+, lateral'),
 ('physics', 'pass', 'short_dir_4_2', 0.92, 'x', 'G5.249 §8.355: … 70 m+, back')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
