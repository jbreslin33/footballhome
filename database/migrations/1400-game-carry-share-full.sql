-- 1400 — Game G5.130 (game/DESIGN.md §8.231): the carrier runs at his own dribble pace.
--
-- tempo.carry_share scaled a carrier's wish to 0.6 for his whole spell on the ball (G5.4's fit, when his
-- feet still walked at the man he'd pass to — fixed G5.127). With the carry kept and its line real, 0.6
-- left our carries at 2.5 m/s (StatsBomb PL 15/16 free middle third 3.42, pressed 3.76). 1.0 = his body's
-- dribble share of top speed only: 3.3-3.9 m/s by third (2.6-3.8), passes ~500 → 474-483 a team-match
-- (434), spells reaching 0-18 ~21 → 23-25 (30.7). Seeds 1000-4000 x 8. fh_game_scratch and the live DB.

BEGIN;
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
  ('physics', 'tempo', 'carry_share', 1.0, 'share',
   'G5.130 §8.231: the carrier''s wish during his spell on the ball, x his dribble pace — 1.0, real carry speed (StatsBomb PL 15/16 3.4-3.8 m/s) (mig 1400; was 0.6)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
COMMIT;
