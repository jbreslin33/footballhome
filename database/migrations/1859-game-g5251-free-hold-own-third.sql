-- G5.251 (game/DESIGN.md §8.357): the free hold (§8.296 — past his drawn time a free man keeps the ball until an opponent
-- closes within free_hold_m) only in his own third, not his own half. It was fitted at 559 passes a team-match; today the
-- band it reached into (52-70 m off the line attacked) held the ball 1.66 s a stint (DFL 1.29), 3 s+ 18.5% (10.8), and
-- midfield foot releases bunched with the nearest opponent 3-6 m off: 132 a team-match (StatsBomb 360: 75), 6 m+ 24 (60).
-- Seeds 1000-4000 x 8: 1.43 s, 14.5%; releases 106 / 68; passes 392 -> 416 (434), completed 75.3 -> 76.3% (77.5).
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'tempo', 'free_hold_own_m', 35, 'm', 'G5.251 §8.357: the free hold applies within this of his own goal line (code default 52.5 = his own half)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
