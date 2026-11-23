-- G5.219 (game/DESIGN.md §8.325): their ball deep in their own third and by a touchline — the block steps up on it.
-- DFL (benchmarks_tracking_deepwide.py THE OTHER SIDE BY ROLE): behind such a ball a real side stands, metres on from
-- it, ST 1.1 / AM 5.9 / WIDE 9.0 / DM-CM 18.3 / FB 26.2 / CB 33.0; ours 6.3 / 10.3 / 11.3 / 25.1 / 29.7 / 35.6 (the
-- block spot table is by the ball's depth alone). Each role's spot that gap higher, full from 70 m off our line and
-- 20.16 m off the centre line, faded in over the 5 m and 8 m before. Seeds 1000-4000 x 8: 4.7 / 7.8 / 10.2 / 21.4 /
-- 27.6 / 33.9; the wide man's long ball down his wing not completed 61 -> 67% (72). Twice the remaining gap on top
-- (trial 2) moved the block ~1 m more and took goals 2.16 -> 2.53: not taken.
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'block', 'wide_up_st', 5.2, 'm', 'G5.219 §8.325: their ball 70 m+ off our line and by a touchline — the striker''s block spot this much higher'),
 ('physics', 'block', 'wide_up_am', 4.4, 'm', 'G5.219 §8.325: … the AM''s'),
 ('physics', 'block', 'wide_up_wide', 2.3, 'm', 'G5.219 §8.325: … the wide man''s'),
 ('physics', 'block', 'wide_up_dm', 6.8, 'm', 'G5.219 §8.325: … the DM / CM''s'),
 ('physics', 'block', 'wide_up_fb', 3.5, 'm', 'G5.219 §8.325: … the full-back''s'),
 ('physics', 'block', 'wide_up_cb', 2.6, 'm', 'G5.219 §8.325: … the centre-back''s')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
