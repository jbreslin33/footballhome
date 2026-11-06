-- 1126 — Game G5.37 (game/DESIGN.md §8.135): the keeper against a shot.
--
-- Against their ball at shot speed (12 m/s+) a keeper takes it only within 0.7 m of his body;
-- any other ball (a back pass, a loose ball, a cross) at his full 1.2 m. Fitted to the real
-- share of on-target shots saved — StatsBomb PL 2015/16 open play: 70.4%
-- (benchmarks_statsbomb_placement.py); the game at 0.7 m, 32 rotating fixtures: 71%, with the
-- shot's crossing point drawn from the real one and the keeper paying his reaction time on the
-- strike. At 1.2 m he kept 87%; one 0.5 m reach for every ball let back passes roll in.
-- fh_game_scratch and the live game DB alike.

BEGIN;
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
  ('physics', 'keeper', 'shot_reach_m', 0.7, 'm',
   'G5.37 §8.135: against their shot (12 m/s+) he takes it this close; fit to the real 70.4% of on-target shots saved (StatsBomb PL 15/16) (mig 1126)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
COMMIT;
