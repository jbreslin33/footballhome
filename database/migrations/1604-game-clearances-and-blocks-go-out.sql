-- G5.188 (game/DESIGN.md §8.294): the ball goes out off a defender as it does in real football. Ball in play had
-- risen to 63.7% (DFL 55.2) — passes a minute in play 9.6 (8.2) but 570 a team-match (434) — because nothing a
-- defender touched went out: foot clearances 0% corners and near-0 throw-ins (StatsBomb PL 15/16 foot: 0-6 m inside
-- 19 / 23%, 6-18 6 / 16%, wide 42-50% throw-ins), blocked balls died 9 m on (real 13) and stayed in.
--   clear_out 1 — a foot clearance goes behind / over his touchline at the real share by spot (Possession, code
--                 table from benchmarks_statsbomb_clearcorner.py); the rest upfield as before
--   block.keep  — the restitution straight into a body, 0.3 → 0.4 (the oblique model of §8.270 keeps the rest)
-- Rows, not code defaults: goldens unchanged; delete the rows to go back.
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'onball', 'clear_out', 1, 'switch', 'G5.188 §8.294: a foot clearance goes out (corner / throw-in) at the real share by spot (StatsBomb PL 15/16 foot clearances)'),
 ('physics', 'block', 'keep', 0.4, 'share', 'G5.188 §8.294: restitution of a ball hit straight into a body (G4.25 0.3); fitted to real blocked-ball next touch 7 / 13 / 21 m')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
