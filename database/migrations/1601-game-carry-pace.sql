-- G5.187 (game/DESIGN.md §8.293): the man on the ball carries at a real pace. Until now he wanted his full
-- dribble speed on 96-97% of ticks (CARRY DIAG wanted 7.86 m/s) and carried 3.96-4.38 m/s in every third (real
-- StatsBomb carries 2.63-3.76): carries 10 m+ 59.1 a team-match v 34.6. The pace governor built in G5.131 /
-- G5.136 (§8.232, §8.239), on:
--   carry_pace 2       — one draw a spell from the pooled real carrier-pace spread (DFL, every spell 1.6 s+)
--   carry_pace_free_m 3 — an opponent within 3 m and he goes at his full dribble share (the take-on burst)
-- Rows, not code defaults: goldens unchanged; delete the rows to go back.
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'tempo', 'carry_pace', 2, 'switch', 'G5.187 §8.293: the carrier''s pace — one draw a spell from the pooled real spread (DFL); 0 = off, 1 = by receipt band'),
 ('physics', 'tempo', 'carry_pace_free_m', 3, 'm', 'G5.187 §8.293: an opponent this close and the carrier goes at his full dribble share (the take-on burst)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
