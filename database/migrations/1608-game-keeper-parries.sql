-- G5.192 (game/DESIGN.md §8.298): a keeper parries most of the shots he saves. StatsBomb PL 15/16 Goal Keeper saves,
-- 2.95 a team-match: held 39.5%, touched out 22.8, in play 30.0 (danger 17.6 / safe 12.4), saved twice 7.7. Ours held
-- every shot under his control speed (parried 0-3% by aimed cell), so no corners came off saves (real 0.60 a team-match).
--   parry_share 0.6 — a shot he would hold is parried; parry_out_share 0.38 (code default) of those pushed behind his
--                     line wide of the post, the rest away into play (G4.14's parry)
-- Rows, not code defaults: goldens unchanged.
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'keeper', 'parry_share', 0.6, 'share', 'G5.192 §8.298: a shot the keeper would hold is parried at this share (StatsBomb PL 15/16: 60.5% of saves not held); 0 = off')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
