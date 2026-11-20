-- G5.196 (game/DESIGN.md §8.302): the presser's challenge rate refitted. G5.147 fitted physics.press.tackle_per_s 0.75
-- (code default) to StatsBomb fouls 12.5 + tackle duels 20.3 a team-match on the old tempo; with G5.187-G5.193 (carriers at
-- a real pace, the free hold) there were fewer chances to dive: tackles 16.9, fouls 11.4, free kicks 11.1 (12.6).
-- 1.0: tackles 20.8, fouls 13.8, free kicks 12.6; 0.9: tackles 19.4, fouls 13.0, free kicks 11.9 — all three ok.
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'press', 'tackle_per_s', 0.9, 'per s', 'G5.196 §8.302: the presser in reach and goal-side dives at this rate; fitted to StatsBomb fouls 12.5 + tackle duels 20.3 (G5.147 0.75 on the old tempo)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
