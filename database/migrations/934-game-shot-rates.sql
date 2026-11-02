-- Mig 934 (G5.4, game/DESIGN.md §8.102): how often a real player shoots, by
-- spot and pressure, as a share of his open-play releases. StatsBomb Open Data,
-- Premier League 2015/16, all 380 matches (benchmarks_statsbomb_decisions.py).
-- The Brain rolls these instead of its range rule; no rows = the old rule.
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('concept', 'shot-selection', 'rate_b0_central_free', 0.877, 'share', 'Central, under 6 m, free: 306 shots in 349 releases.'),
 ('concept', 'shot-selection', 'rate_b0_central_pressed', 0.866, 'share', 'Central, under 6 m, pressed: 200 shots in 231 releases.'),
 ('concept', 'shot-selection', 'rate_b1_central_free', 0.738, 'share', 'Central, under 11 m, free: 1238 shots in 1677 releases.'),
 ('concept', 'shot-selection', 'rate_b1_central_pressed', 0.686, 'share', 'Central, under 11 m, pressed: 846 shots in 1234 releases.'),
 ('concept', 'shot-selection', 'rate_b2_wide_free', 0.026, 'share', 'Wide, under 16 m, free: 10 shots in 384 releases.'),
 ('concept', 'shot-selection', 'rate_b2_wide_pressed', 0.007, 'share', 'Wide, under 16 m, pressed: 1 shots in 151 releases.'),
 ('concept', 'shot-selection', 'rate_b2_central_free', 0.480, 'share', 'Central, under 16 m, free: 1654 shots in 3443 releases.'),
 ('concept', 'shot-selection', 'rate_b2_central_pressed', 0.287, 'share', 'Central, under 16 m, pressed: 482 shots in 1678 releases.'),
 ('concept', 'shot-selection', 'rate_b3_wide_free', 0.070, 'share', 'Wide, under 22 m, free: 213 shots in 3042 releases.'),
 ('concept', 'shot-selection', 'rate_b3_wide_pressed', 0.033, 'share', 'Wide, under 22 m, pressed: 38 shots in 1155 releases.'),
 ('concept', 'shot-selection', 'rate_b3_central_free', 0.423, 'share', 'Central, under 22 m, free: 1914 shots in 4522 releases.'),
 ('concept', 'shot-selection', 'rate_b3_central_pressed', 0.190, 'share', 'Central, under 22 m, pressed: 336 shots in 1771 releases.'),
 ('concept', 'shot-selection', 'rate_b4_wide_free', 0.026, 'share', 'Wide, under 30 m, free: 285 shots in 11140 releases.'),
 ('concept', 'shot-selection', 'rate_b4_wide_pressed', 0.012, 'share', 'Wide, under 30 m, pressed: 42 shots in 3485 releases.'),
 ('concept', 'shot-selection', 'rate_b4_central_free', 0.181, 'share', 'Central, under 30 m, free: 1486 shots in 8219 releases.'),
 ('concept', 'shot-selection', 'rate_b4_central_pressed', 0.061, 'share', 'Central, under 30 m, pressed: 173 shots in 2824 releases.'),
 ('concept', 'shot-selection', 'rate_b5_wide_free', 0.001, 'share', 'Wide, under 45 m, free: 31 shots in 41318 releases.'),
 ('concept', 'shot-selection', 'rate_b5_wide_pressed', 0.001, 'share', 'Wide, under 45 m, pressed: 7 shots in 10966 releases.'),
 ('concept', 'shot-selection', 'rate_b5_central_free', 0.006, 'share', 'Central, under 45 m, free: 125 shots in 19532 releases.'),
 ('concept', 'shot-selection', 'rate_b5_central_pressed', 0.002, 'share', 'Central, under 45 m, pressed: 10 shots in 4948 releases.')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, note = EXCLUDED.note;
