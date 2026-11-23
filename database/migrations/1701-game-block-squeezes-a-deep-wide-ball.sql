-- G5.221 (game/DESIGN.md §8.327): the block squeezes while their ball stays deep (70 m+ off our line) and by a
-- touchline. DFL by the spell's age (benchmarks_tracking_deepwide.py, 0-2 / 2-5 / 5+ s): real lines climb — CB 47.7 /
-- 48.2 / 51.5 m off their own line, ST 79.1 / 81.3 / 85.3 — while ours held (44.5) as the ball was worked back, every
-- line 5 m further off it by 5 s. Each role's block spot climbs this many m a second while the ball stays there, for
-- squeeze_max_s. Seeds 1000-4000 x 8 at 5 s+: men round the ball 1.72 -> 2.59 (4.08), ST m on from it 8.7 -> 3.7
-- (-2.4), CB 38.9 -> 35.4 (31.4). The 5 s+ real bin is thin (4.8% of frames, 7 matches).
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'block', 'squeeze_cb', 0.5, 'm/s', 'G5.221 §8.327: their ball deep and by a touchline — the centre-back''s block spot climbs this fast while it stays there'),
 ('physics', 'block', 'squeeze_fb', 0.7, 'm/s', 'G5.221 §8.327: … the full-back''s'),
 ('physics', 'block', 'squeeze_dm', 0.7, 'm/s', 'G5.221 §8.327: … the DM / CM''s'),
 ('physics', 'block', 'squeeze_am', 1.4, 'm/s', 'G5.221 §8.327: … the AM''s'),
 ('physics', 'block', 'squeeze_wide', 0.7, 'm/s', 'G5.221 §8.327: … the wide man''s'),
 ('physics', 'block', 'squeeze_st', 1.0, 'm/s', 'G5.221 §8.327: … the striker''s'),
 ('physics', 'block', 'squeeze_max_s', 7, 's', 'G5.221 §8.327: the squeeze stops climbing after this long')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
