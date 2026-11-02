-- G5.4 (game/DESIGN.md §8.102): where a real player with time passes it, by
-- third and pressure. Share of open-play passes that gain under 3 m either way
-- (square) or lose 3 m+ (back). StatsBomb Open Data, Premier League 2015/16, 380
-- matches (benchmarks_statsbomb_direction.py). Thirds: 0 own, 1 middle, 2 final.
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('concept', 'pass-ladder', 'dir_t0_square', 0.121, 'share', 'Own third, unpressed: square.'),
 ('concept', 'pass-ladder', 'dir_t0_back',   0.159, 'share', 'Own third, unpressed: back.'),
 ('concept', 'pass-ladder', 'dir_t1_square', 0.178, 'share', 'Middle third, unpressed: square.'),
 ('concept', 'pass-ladder', 'dir_t1_back',   0.272, 'share', 'Middle third, unpressed: back.'),
 ('concept', 'pass-ladder', 'dir_t2_square', 0.249, 'share', 'Final third, unpressed: square.'),
 ('concept', 'pass-ladder', 'dir_t2_back',   0.304, 'share', 'Final third, unpressed: back.'),
 ('concept', 'pass-ladder', 'dir_t0_square_pressed', 0.161, 'share', 'Own third, pressed: square.'),
 ('concept', 'pass-ladder', 'dir_t0_back_pressed',   0.193, 'share', 'Own third, pressed: back.'),
 ('concept', 'pass-ladder', 'dir_t1_square_pressed', 0.191, 'share', 'Middle third, pressed: square.'),
 ('concept', 'pass-ladder', 'dir_t1_back_pressed',   0.311, 'share', 'Middle third, pressed: back.'),
 ('concept', 'pass-ladder', 'dir_t2_square_pressed', 0.307, 'share', 'Final third, pressed: square.'),
 ('concept', 'pass-ladder', 'dir_t2_back_pressed',   0.317, 'share', 'Final third, pressed: back.')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, note = EXCLUDED.note;
