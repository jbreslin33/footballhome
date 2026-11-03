-- G5.8 (game/DESIGN.md §8.106): a pro clears at the real rate for where he
-- is and how near the nearest outfield opponent is, rolled once on the ball;
-- losing the roll he keeps it (plays back or shields), in his own third too.
-- Rates: StatsBomb Open Data 360 freeze frames, 115 matches (free with
-- attribution), foot clearances / foot releases (passes + clearances, no
-- set pieces, no keepers). Replaces mig 951's pass-ladder clear_* shares,
-- which were read off StatsBomb's under-pressure flag that every clearance
-- carries. A clearance is hurried: clear_err_deg either side of the aim
-- (the headed clearance's 40), and struck 24 m+ off the middle it goes up
-- his own touchline. Both [FH] fits to PL 2015/16 clearance outcomes.
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('concept', 'clear-the-danger', 'rate_box_lt1_2',  0.535, 'share', 'Own box, nearest opponent under 1.2 m.'),
 ('concept', 'clear-the-danger', 'rate_box_1_2_3',  0.444, 'share', 'Own box, 1.2-3 m.'),
 ('concept', 'clear-the-danger', 'rate_box_3_6',    0.360, 'share', 'Own box, 3-6 m.'),
 ('concept', 'clear-the-danger', 'rate_box_6p',     0.134, 'share', 'Own box, 6 m+.'),
 ('concept', 'clear-the-danger', 'rate_own3_lt1_2', 0.069, 'share', 'Own third outside the box, under 1.2 m.'),
 ('concept', 'clear-the-danger', 'rate_own3_1_2_3', 0.054, 'share', 'Own third outside the box, 1.2-3 m.'),
 ('concept', 'clear-the-danger', 'rate_own3_3_6',   0.020, 'share', 'Own third outside the box, 3-6 m.'),
 ('concept', 'clear-the-danger', 'rate_own3_6p',    0.004, 'share', 'Own third outside the box, 6 m+.'),
 ('concept', 'clear-the-danger', 'rate_mid_lt1_2',  0.010, 'share', 'Midfield, under 1.2 m.'),
 ('concept', 'clear-the-danger', 'rate_mid_1_2_3',  0.005, 'share', 'Midfield, 1.2-3 m.'),
 ('concept', 'clear-the-danger', 'rate_mid_3_6',    0.002, 'share', 'Midfield, 3-6 m.'),
 ('concept', 'clear-the-danger', 'rate_mid_6p',     0,     'share', 'Midfield, 6 m+.'),
 ('concept', 'clear-the-danger', 'rate_fin3_lt1_2', 0.001, 'share', 'Their third, under 1.2 m.'),
 ('concept', 'clear-the-danger', 'rate_fin3_1_2_3', 0,     'share', 'Their third, 1.2-3 m.'),
 ('concept', 'clear-the-danger', 'rate_fin3_3_6',   0,     'share', 'Their third, 3-6 m.'),
 ('concept', 'clear-the-danger', 'rate_fin3_6p',    0,     'share', 'Their third, 6 m+.'),
 ('concept', 'clear-the-danger', 'touch_from_y_m',  24,    'm', 'Struck this far off the middle, a clearance goes up his own touchline.'),
 ('physics', 'kick', 'clear_err_deg', 40, 'deg', 'A clearance is hurried: this far either side of the aim.')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, note = EXCLUDED.note;
