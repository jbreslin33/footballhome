-- G5.214 (game/DESIGN.md §8.320): the long ball from the back goes down the kicker's own side. StatsBomb PL 15/16
-- (benchmarks_statsbomb_longball_across.py): of 10.2 open-play high passes of 30 m+ a team-match from the own third,
-- half are hit by a wide man and 84% of his end in his own wing or channel; ours went inside (his side 44%, centre
-- lane 36% v 11). A lift on that pass's share by where the kicker stands across the pitch x the lane its aim is in,
-- signed to his side; two rounds of real / ours. Seeds 1000-4000 x 8: the wide man's on his side 44 -> 77% (84),
-- end |y| 12.1 -> 18.9 m (21.0), by kicker centre / half / wide 3.6 / 2.5 / 3.2 -> 2.0 / 3.0 / 3.8 (1.9 / 3.3 / 5.0),
-- card 10/7/16 -> 12/6/15.
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'pass', 'long_lane_0_0', 0.5, 'x', 'G5.214 §8.320: 30 m+ high pass from our own third, kicker centre (|y| < 10 m), aimed at his wing — lift on its share'),
 ('physics', 'pass', 'long_lane_0_1', 0.65, 'x', 'G5.214 §8.320: 30 m+ high pass from our own third, kicker centre (|y| < 10 m), aimed at his channel — lift on its share'),
 ('physics', 'pass', 'long_lane_0_2', 0.31, 'x', 'G5.214 §8.320: 30 m+ high pass from our own third, kicker centre (|y| < 10 m), aimed at centre — lift on its share'),
 ('physics', 'pass', 'long_lane_0_3', 0.27, 'x', 'G5.214 §8.320: 30 m+ high pass from our own third, kicker centre (|y| < 10 m), aimed at far channel — lift on its share'),
 ('physics', 'pass', 'long_lane_0_4', 0.41, 'x', 'G5.214 §8.320: 30 m+ high pass from our own third, kicker centre (|y| < 10 m), aimed at far wing — lift on its share'),
 ('physics', 'pass', 'long_lane_1_0', 6.2, 'x', 'G5.214 §8.320: 30 m+ high pass from our own third, kicker half (10-20.16 m), aimed at his wing — lift on its share'),
 ('physics', 'pass', 'long_lane_1_1', 2.6, 'x', 'G5.214 §8.320: 30 m+ high pass from our own third, kicker half (10-20.16 m), aimed at his channel — lift on its share'),
 ('physics', 'pass', 'long_lane_1_2', 0.78, 'x', 'G5.214 §8.320: 30 m+ high pass from our own third, kicker half (10-20.16 m), aimed at centre — lift on its share'),
 ('physics', 'pass', 'long_lane_1_3', 0.38, 'x', 'G5.214 §8.320: 30 m+ high pass from our own third, kicker half (10-20.16 m), aimed at far channel — lift on its share'),
 ('physics', 'pass', 'long_lane_1_4', 0.74, 'x', 'G5.214 §8.320: 30 m+ high pass from our own third, kicker half (10-20.16 m), aimed at far wing — lift on its share'),
 ('physics', 'pass', 'long_lane_2_0', 7.9, 'x', 'G5.214 §8.320: 30 m+ high pass from our own third, kicker wide (20.16 m+), aimed at his wing — lift on its share'),
 ('physics', 'pass', 'long_lane_2_1', 4.0, 'x', 'G5.214 §8.320: 30 m+ high pass from our own third, kicker wide (20.16 m+), aimed at his channel — lift on its share'),
 ('physics', 'pass', 'long_lane_2_2', 0.45, 'x', 'G5.214 §8.320: 30 m+ high pass from our own third, kicker wide (20.16 m+), aimed at centre — lift on its share'),
 ('physics', 'pass', 'long_lane_2_3', 0.155, 'x', 'G5.214 §8.320: 30 m+ high pass from our own third, kicker wide (20.16 m+), aimed at far channel — lift on its share'),
 ('physics', 'pass', 'long_lane_2_4', 0.32, 'x', 'G5.214 §8.320: 30 m+ high pass from our own third, kicker wide (20.16 m+), aimed at far wing — lift on its share')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
