-- G5.212 (game/DESIGN.md §8.318): the long ball from the back is hit beyond the man, not onto him. DFL
-- (benchmarks_tracking_longball.py): a high ball of 30 m+ launched within 35 m of the kicker's goal comes down
-- +3.7 / +8.8 / +15.9 m on toward their goal from the mate nearest it at the launch (carry 30-40 / 40-50 / 50+ m);
-- ours came down on him (-0.6). The aim now takes the real offset quartiles by carry, one roll a spell.
-- Seeds 1000-4000 x 8: beyond him -0.6 -> +2.8 m (6.2), 5 m+ short 26 -> 6% (12), both sides within 2 m of the drop
-- 51 -> 39% (33), goals a team-match 2.44 -> 1.98 (1.35).
--   long_beyond 1 — the real offsets x this (0 = aimed at the man, the code's default)
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'pass', 'long_beyond', 1, 'share', 'G5.212 §8.318: a 30 m+ high ball from our own third lands beyond the man by the real DFL offsets x this (0 = to the man)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
