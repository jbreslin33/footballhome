-- 1291 — Game G5.97 (game/DESIGN.md §8.198): a man with their pass in reach plays it.
--
-- physics.tempo.cut_share was 0.1: an outfielder within reach (0.5 m) of their moving pass took
-- it one roll in ten and watched the rest roll by — fitted in G5.4 to 7.2 interceptions a team.
-- Traced (harness CONTROL SPELLS): 41% of our ball changes by proximity were such a man, nearest
-- the ball within 1.5 m for 0.4 s+, never touching it (chasers 105, pressers 66 in 2 matches).
-- At 1 (every ball in reach is played): balls changing side in play, the loser on it 1 s+,
-- 75-81 → 134-136 a team-match (real DFL 148.4), given straight back inside 3 s 13-18 → 28-31%
-- (32.1) — benchmarks_tracking_rewin.py. fh_game_scratch and the live game DB alike.

BEGIN;
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
  ('physics', 'tempo', 'cut_share', 1, 'share',
   'G5.97 §8.198: a man with their moving pass in reach plays it (was 0.1, G5.4 fit to 7.2 interceptions); REWIN 134-136 v real 148.4 (mig 1291)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
COMMIT;
