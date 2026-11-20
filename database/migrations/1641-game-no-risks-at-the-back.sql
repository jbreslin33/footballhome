-- G5.205 (game/DESIGN.md §8.311): from our own third a pass the race read says they win is played at 0.05 of its share,
-- not risk_weight's 0.25 [FH coaching: no risks at the back]. G5.202's code (§8.308), judged then on regains alone. New
-- benchmarks_statsbomb_ownthird.py: real own-third ground passes 5 m+ lose 1.73 a team-match (3.5%); ours 3.55 (4.8%),
-- nearly all played with 2+ mates safe to feet. Seeds 1000-4000 x 8: lost 3.55 -> 2.53; won within 35 m 6.34 -> 5.70.
--   risk_own3 0.05 — an unsafe pass's weight from our third (0 = risk_weight everywhere)
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'pass', 'risk_own3', 0.05, 'share', 'G5.205 §8.311: from our own third (< 35 m) a pass the race read says they win, at this share (0 = risk_weight)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
