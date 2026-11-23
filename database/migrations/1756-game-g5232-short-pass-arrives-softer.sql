-- G5.232 (game/DESIGN.md §8.338): a short ground pass arrives softer. Every ground pass to a man was struck to arrive
-- at 9 m/s whatever its length; DFL tracking (benchmarks_tracking_bandtime.py PASS PACE, 7 matches; the harness's
-- 30 Hz kick -> touch ruler) has the short one slower: a pass under 10 m takes 0.88-0.92 s kick to touch (ours 0.80),
-- 10-20 m 1.32-1.36 s (1.27), 20-30 m as ours. The arrival speed is now arrive_short at 5 m and under, rising evenly
-- to 9 m/s at arrive_full_m. 6 m/s / 20 m gives 0.90 / 1.34 s; the 5 Hz touch-to-touch pace 10.8 -> 9.1 m/s at
-- 5-10 m (9.3), 11.9 -> 11.2 at 10-20 m (11.6). Card 10/9/14 -> 9/12/12, goals 2.31 -> 2.31, completion 81.0 -> 80.9%,
-- take-ons 14.2 -> 15.6 (18.05). Seeds 1000-4000 x 8.
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'pass', 'arrive_short', 6, 'm/s', 'G5.232 §8.338: the speed a ground pass of 5 m or less arrives at its man, rising evenly to 9 m/s at arrive_full_m (9 = one arrival speed for every length)'),
 ('physics', 'pass', 'arrive_full_m', 20, 'm', 'G5.232 §8.338: the pass length from which a ground pass arrives at the full 9 m/s')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
