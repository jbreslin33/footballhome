-- G5.225 (game/DESIGN.md §8.331): a man on the ball near his own goal hardly moves. DFL BAND TIME
-- (benchmarks_tracking_bandtime.py), the man's own speed on the ball, med: 2.1 m/s within 35 m of his line, 2.8 the
-- next 17.5 m, 3.2-3.8 beyond; ours 3.3 / 3.0 — the carry pace is one draw from every real spell wherever he is.
-- His drawn pace x this by where he stands. Seeds 1000-4000 x 8: his speed in his own third 3.3 -> 2.8, s on a man
-- there 274 -> 290 a team-match (324), carries of 10 m+ 42.1 -> 38.3 (34.6).
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'tempo', 'carry_pace_own3', 0.64, 'x', 'G5.225 §8.331: the carrier''s drawn pace x this within 35 m of his own goal line (1 = off)'),
 ('physics', 'tempo', 'carry_pace_own_mid', 0.93, 'x', 'G5.225 §8.331: … 35-52.5 m off his own goal line')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
