-- G5.239 (game/DESIGN.md §8.345): the presser's stand-off for a ball 70 m+ off our line, split touchline / middle at
-- the real quartiles (DFL, benchmarks_tracking_deepwide.py: the other side's nearest man by a touchline p25 / med / p75
-- 2.9 / 5.3 / 8.8 m, in the middle 4.9 / 8.9 / 13.5; the band's one row 3.7 / 8.0 / 13.3 was the two blended). G5.218's
-- code (§8.324), left off then on a card move that was run noise. On the full-back by his touchline in his own third
-- (benchmarks_tracking_fbline.py; seeds 1000-4000 x 8): his presser 1 s on 7.0 -> 5.7 m off (5.3), closed 1.7 -> 2.3 m
-- (3.3), inside 3 m 11 -> 17% (24); his stints' p75 2.6 -> 2.0 s (1.8); his forward ground pass 2.9 tried / 0.4 lost
-- -> 3.3 / 0.6 (5.3 / 1.6); the ball won within 18-35 m of our goal 4.9 -> 3.7 a team-match (1.47).
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'press', 'stand_off_deep_w_p25', 2.9, 'm', 'G5.239 §8.345: the presser''s stand-off, their ball 70 m+ off our line and within 14 m of a touchline — DFL p25'),
 ('physics', 'press', 'stand_off_deep_w_p50', 5.3, 'm', 'G5.239 §8.345: … median'),
 ('physics', 'press', 'stand_off_deep_w_p75', 8.8, 'm', 'G5.239 §8.345: … p75'),
 ('physics', 'press', 'stand_off_deep_c_p25', 4.9, 'm', 'G5.239 §8.345: the presser''s stand-off, their ball 70 m+ off our line in the middle — DFL p25'),
 ('physics', 'press', 'stand_off_deep_c_p50', 8.9, 'm', 'G5.239 §8.345: … median'),
 ('physics', 'press', 'stand_off_deep_c_p75', 13.5, 'm', 'G5.239 §8.345: … p75')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
