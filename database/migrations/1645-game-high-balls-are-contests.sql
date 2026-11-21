-- G5.210 (game/DESIGN.md §8.316): a high ball the race read says they win is played at its full real share, and the
-- longest pass aimed is the kicker's own range. New benchmarks_statsbomb_ownthird_dir.py (StatsBomb PL 15/16): from
-- their own third real outfielders fail 14.4 passes of 5 m+ a team-match, 11.4 of them ending beyond that third (high
-- balls into a contest: 30-40 m 55-60% not completed, 50 m+ 82-85%); ours 6.8 / 4.4 — the read kept the safe long
-- balls and the rest went short and central. Seeds 1000-4000 x 8: not completed 6.8 -> 8.2, high 10.3 -> 13.4 (16.2),
-- ending in our own third centre 39.5 -> 36.1 (27.2); possessions won within 18 m of the goal attacked 1.59 -> 1.19.
--   high_risk_weight 1 — a high pass the read says they win, x this of its share (was the code's 0.6, G5.73)
--   reach_max_m 55     — the longest pass he aims, m (was 50 in code; still capped by his kick range)
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'pass', 'high_risk_weight', 1, 'share', 'G5.210 §8.316: a high pass the race read says they win, at this share of its weight (1 = the read never picks the high balls)'),
 ('physics', 'pass', 'reach_max_m', 55, 'm', 'G5.210 §8.316: the longest pass a man aims (capped by his kick range)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
