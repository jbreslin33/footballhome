-- 1371 — Game G5.122 (game/DESIGN.md §8.223): the keeper against a shot, refit.
--
-- With G5.122's keeper depth by the shot's distance x our men goal-side (the real medians at the
-- strike, in code: Possession.cpp keeper_gs_depth, StatsBomb PL 2015/16 freeze frames,
-- benchmarks_statsbomb_finish.py), his reach against their shot refit to the real share of
-- on-target shots saved, 70.4%. 8 seeds x 8 rotating fixtures: 0.7 m 59.5% (4 seeds), 0.9 m 68.1%;
-- without the depth table 0.7 m read 47.9% (G5.37's 71% had drifted as the shots moved),
-- 1.1 m 72.7% but flat by goal-side. fh_game_scratch and the live game DB alike.

BEGIN;
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
  ('physics', 'keeper', 'shot_reach_m', 0.9, 'm',
   'G5.122 §8.223: against their shot (12 m/s+) he takes it this close; refit with the goal-side depth table to the real 70.4% of on-target shots saved (StatsBomb PL 15/16) (mig 1371; was 0.7, mig 1126)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
COMMIT;
