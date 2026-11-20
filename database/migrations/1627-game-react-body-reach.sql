-- G5.200 (game/DESIGN.md §8.306): a kick inside a man's reaction hits a body 0.6 m wide, not 0.9. G5.165 made their kick
-- inside his reaction reach only his body (kPlayerRadius 0.45 m, the collision radius) — charged down by his distance off
-- the passer 0-1 / 1-2 m: 14-20 / 9-12% (StatsBomb 360: 10.2 / 6.6), and the pass off a shin near our box is a second
-- ball for their quick shot (§8.305).
--   react_body_m 0.3 — the body's reach to a kick inside his reaction (World capture and Reads::race alike)
-- 0-1 / 1-2 m now 8.5 / 6.6%. Rows, not code defaults: goldens unchanged.
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'ball', 'react_body_m', 0.3, 'm', 'G5.200 §8.306: inside his reaction a kick touches him within this of his centre (0 = kPlayerRadius 0.45)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
