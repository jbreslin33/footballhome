-- G5.244 (game/DESIGN.md §8.350): which side a blocked pass leaves the blocker — toward the nearer touchline at the real
-- share, by the block's metres off that line (StatsBomb PL 15/16, 380 matches, game/scripts/benchmarks_statsbomb_blockzone.py
-- WHICH WAY OFF THE BLOCK: toward it / away 62 / 24, 60 / 31, 57 / 35, 51 / 38% at 0-5 / 5-10 / 10-20 / 20+ m; the share
-- of the two). It was a coin (World::deflectOffBody); the pace and the turn off the body stay §8.269-8.270's.
-- Seeds 1000-4000 x 8: a pass blocked within 5 m of the touchline then a throw-in 30 -> 45% (54); blocked passes out
-- 11.9 -> 16.7% (35.8); the next touch in play 9.1 -> 8.4 m (8.9); throw-ins 18.4 -> 20.2 a team-match (23.1).
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'block', 'out_0', 0.72, 'share', 'G5.244 §8.350: a blocked pass leaves toward the nearer touchline — the block 0-5 m off it (StatsBomb 62 toward / 24 away)'),
 ('physics', 'block', 'out_5', 0.66, 'share', 'G5.244 §8.350: … 5-10 m off it (60 / 31)'),
 ('physics', 'block', 'out_10', 0.62, 'share', 'G5.244 §8.350: … 10-20 m off it (57 / 35)'),
 ('physics', 'block', 'out_20', 0.57, 'share', 'G5.244 §8.350: … 20 m+ off it (51 / 38)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
