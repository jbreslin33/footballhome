-- G5.216 (game/DESIGN.md §8.322): with the ball deep and wide (within 35 m of our line, 20.16 m+ off the centre line)
-- the striker pulls out to that wing. DFL (benchmarks_tracking_deepwide.py): the striker nearest the ball's touchline
-- is in the wing lane 26% of such frames, at 24.2 m off the centre line and 57.5 m off their goal line; ours 4%.
-- A roll a striker a spell; a deep wide spell is short and he has ~15 m to cross, so the frame share comes out well
-- under the roll: 0.5 -> 11.5%, 1 -> 18.7% (seeds 1000-4000 x 8). At 1: his median across +8.7 -> +11.5 m (11.7),
-- centre lane 38 -> 28% (30), card 12/6/15 -> 12/8/13.
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'drift', 'deep_st_p', 1, 'share', 'G5.216 §8.322: the ball within 35 m of our line and wide — the striker''s roll (a spell) to go out to that wing (0 = off)'),
 ('physics', 'drift', 'deep_st_m', 57.5, 'm', 'G5.216 §8.322: his spot there, m off their goal line (DFL)'),
 ('physics', 'drift', 'deep_st_y', 24.2, 'm', 'G5.216 §8.322: his spot there, m off the centre line (DFL)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
