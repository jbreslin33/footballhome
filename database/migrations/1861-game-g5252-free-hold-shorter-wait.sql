-- G5.252 (game/DESIGN.md §8.358): the free hold's extra wait 3 s -> 1.5 s (with the code change: a receipt drawn as a
-- first-time ball is played first time, free or not). In his own third a man's time on the ball ran 2.1 s med, p90 5.4
-- (StatsBomb PL 15/16 free receipts 1.3 / 4.3), first time 7.5% (24.5), 10 m+ from the receipt 27.7% (15.9).
-- Seeds 1000-4000 x 8: 1.8 / 4.5 s, 28.6%, 16.2%; own-third releases with nobody inside 6 m 7.8 -> 26.2 (22.4), their
-- nearest 3-6 m 42.0 -> 30.9 (24.1); passes 416 -> 426 (434).
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'tempo', 'free_hold_max_s', 1.5, 's', 'G5.252 §8.358: past his drawn time a free man in his own third waits at most this long for a man to close (code default 3)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
