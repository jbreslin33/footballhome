-- 1292 — Game G5.99 (game/DESIGN.md §8.200): a defender goes for their pass only when he wins it clearly.
--
-- Our first man to their pass chased it whenever the race read put him no later than their receiver.
-- Real (benchmarks_tracking_passrace.py, DFL): one crude race on every open-play flat pass — passes
-- their man wins by 0-0.2 / 0.2-0.4 / 0.4-0.7 / 0.7+ s still complete 92.6 / 92.1 / 89.2 / 80.1%; ours
-- 77 / 75 / 66 / 63%. At 1.0 s: 85 / 86 / 83 / 75%, settled losses 86-89 → 58-61 a team-match (58.1);
-- 1.5 s no closer. Fit on seeds 1000 / 2000 / 3000. fh_game_scratch and the live game DB alike.

BEGIN;
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
  ('physics', 'block', 'cut_margin_s', 1.0, 's',
   'G5.99 §8.200: our first man goes for their pass only if he wins its race by this much; else he keeps his job and the presser steps to their man (mig 1292)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
COMMIT;
