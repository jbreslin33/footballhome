-- G5.250 (game/DESIGN.md §8.356): the short pass's direction rows, a second step of real ÷ ours (StatsBomb PL 15/16).
-- After G5.249 a pass under 20 m struck 52-70 m off the line attacked ran forward / lateral / back 26.7 / 47.6 / 16.6 a
-- team-match v 26.8 / 38.3 / 13.3; 35-52 m 24.2 / 42.8 / 18.5 v 25.8 / 40.2 / 16.0; 70 m+ 16.7 / 22.8 / 6.5 v 21.9 / 22.0 / 6.5.
-- Seeds 1000-4000 x 8: 52-70 m 27.4 / 44.1 / 16.2; 35-52 m 25.1 / 42.9 / 17.1; 70 m+ 19.1 / 22.8 / 6.8.
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'pass', 'short_dir_2_0', 1.20, 'x', 'G5.250 §8.356: a pass under 20 m struck 35-52 m off the line attacked, forward (was 1.13)'),
 ('physics', 'pass', 'short_dir_2_1', 0.81, 'x', 'G5.250 §8.356: … 35-52 m, lateral (was 0.86)'),
 ('physics', 'pass', 'short_dir_2_2', 0.68, 'x', 'G5.250 §8.356: … 35-52 m, back (was 0.79)'),
 ('physics', 'pass', 'short_dir_3_1', 0.53, 'x', 'G5.250 §8.356: … 52-70 m, lateral (was 0.66)'),
 ('physics', 'pass', 'short_dir_3_2', 0.51, 'x', 'G5.250 §8.356: … 52-70 m, back (was 0.64)'),
 ('physics', 'pass', 'short_dir_4_0', 1.89, 'x', 'G5.250 §8.356: … 70 m+, forward (was 1.44)'),
 ('physics', 'pass', 'short_dir_4_1', 0.77, 'x', 'G5.250 §8.356: … 70 m+, lateral (was 0.80)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
