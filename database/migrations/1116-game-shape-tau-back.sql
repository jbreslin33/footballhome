-- 1116 — Game G5.32 (game/DESIGN.md §8.130): holding shape without the ball, a spot
-- goal-side of him he closes in 2.5 s, not the shift's 4 s. Fitted to DFL tracking
-- (benchmarks_tracking_recover.py: the side without the ball runs back 5+ m/s 2.8% of the
-- time with the ball 40 m+ from its goal; the block's real spot by role and ball band).
-- fh_game_scratch first; the live game DB with the ship (game/ship/README.md).

BEGIN;
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
  ('physics', 'body', 'shape_tau_back_s', 2.5, 's', 'G5.32 §8.130: without the ball, his spot goal-side of him: closed in this, not shape_tau_s (DFL fit) (mig 1116)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
COMMIT;
