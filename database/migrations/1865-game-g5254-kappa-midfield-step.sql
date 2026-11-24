-- G5.254 (game/DESIGN.md §8.360): one proportional step on the pass table's presence correction (physics.pass.kappa_<o>_<d>,
-- §8.159) for the midfield and own-third origins: each cell x real share ÷ ours as played (StatsBomb PL 15/16 PASS POLICY v
-- fh-game-match PASS POLICY as played, seeds 1000-4000 x 8). The central midfielder's ball to the man beside him ran 35-52 m
-- out +8.7 passes a team-match over real, 52-70 m +10.8, own third +5.8 (HOW A STINT BEGAN, §8.359: received passes the
-- midfield surplus). After: +4.4 / +6.9 / +2.2; passes into 35-52 / 52-70 m centre +15.7 / +15.0 -> +6.9 / +8.4.
-- Origins: 4 = 35-52 centre, 5 = 35-52 wide, 6 = 52-70 centre, 8 = 70+ centre; destinations as the table (2..9).
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'pass', 'kappa_4_2', 0.993, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played'),
 ('physics', 'pass', 'kappa_4_3', 2.03, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played'),
 ('physics', 'pass', 'kappa_4_4', 0.568, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played'),
 ('physics', 'pass', 'kappa_4_5', 1.263, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played'),
 ('physics', 'pass', 'kappa_4_6', 0.554, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played'),
 ('physics', 'pass', 'kappa_4_7', 1.59, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played'),
 ('physics', 'pass', 'kappa_6_2', 1.90, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played'),
 ('physics', 'pass', 'kappa_6_3', 3.28, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played'),
 ('physics', 'pass', 'kappa_6_4', 0.69, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played'),
 ('physics', 'pass', 'kappa_6_5', 1.04, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played'),
 ('physics', 'pass', 'kappa_6_6', 0.61, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played'),
 ('physics', 'pass', 'kappa_6_7', 1.25, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played'),
 ('physics', 'pass', 'kappa_6_8', 1.18, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played'),
 ('physics', 'pass', 'kappa_8_4', 0.71, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played'),
 ('physics', 'pass', 'kappa_8_5', 1.46, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played'),
 ('physics', 'pass', 'kappa_8_6', 0.785, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played'),
 ('physics', 'pass', 'kappa_8_7', 1.23, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played'),
 ('physics', 'pass', 'kappa_8_8', 0.70, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played'),
 ('physics', 'pass', 'kappa_8_9', 2.02, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played'),
 ('physics', 'pass', 'kappa_5_2', 0.995, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played'),
 ('physics', 'pass', 'kappa_5_3', 1.38, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played'),
 ('physics', 'pass', 'kappa_5_4', 0.533, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played'),
 ('physics', 'pass', 'kappa_5_6', 0.595, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played'),
 ('physics', 'pass', 'kappa_5_7', 1.605, 'x', 'G5.254 §8.360: one IPF step, real share ÷ ours as played')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
