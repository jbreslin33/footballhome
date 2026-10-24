-- 679 (2026-10-24) — game: every player's own body (game/DESIGN.md §8.48,
-- G4.52).
--
-- James: "all players should have different rates of acceleration and
-- speed … with or without ball" / "we want to not use global dampings".
-- G4.51's locomotion numbers were one value for everybody. They become
-- the player's attributes: acceleration (τ), deceleration (braking),
-- agility (turning), dribbling (top speed with the ball) and goalkeeping
-- (dive speed). The rows below say what a rating of 0 / 50 / 100 MEANS —
-- the population — never what anyone has. Each player's ratings are drawn
-- from a bell curve by game/scripts/draw_bodies.py (source 'derived'),
-- for James to correct.

-- The new attribute (FM's Dribbling; USSF "dribbling at speed").
INSERT INTO game_attributes (code, name, category, description, scales, sort_order, status)
VALUES ('dribbling', 'Dribbling', 'technical',
        'Running with the ball: how little of his speed he loses with it at his feet.',
        'top speed with the ball: 80% of his own at 0 … 88% at 50 … 95% at 100', 45, 'wired')
ON CONFLICT (code) DO NOTHING;

UPDATE game_attributes SET status = 'wired',
       scales = 'sprint time constant τ: 1.5 s at 0 … 1.2 at 50 … 0.9 at 100 (63% of top speed after τ)'
 WHERE code = 'acceleration';
UPDATE game_attributes SET status = 'wired',
       scales = 'braking limit: 5 m/s² at 0 … 7 at 50 … 9 at 100'
 WHERE code = 'deceleration';
UPDATE game_attributes SET status = 'wired',
       scales = 'turning / cutting limit (sideways): 4 m/s² at 0 … 6 at 50 … 8 at 100'
 WHERE code = 'agility';
UPDATE game_attributes
   SET scales = scales || '; dive launch 3 m/s at 0 … 4 at 50 … 5 at 100'
 WHERE code = 'goalkeeping' AND scales NOT LIKE '%dive%';

-- G4.51's one-for-everybody numbers, retired (the dive timings stay
-- shared: air and ground time are the physics of the jump).
DELETE FROM game_model_params
 WHERE owner = 'physics' AND (code, param) IN
       (('locomotion', 'tau_s'), ('locomotion', 'max_accel_mps2'),
        ('locomotion', 'dribble_pct'), ('keeper_dive', 'speed_mps'));

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('skill', 'acceleration', 'tau_s_at0', 1.5::numeric, 's', 'τ at rating 0 — team-sport sprint profiles run ≈ 1.0-1.3 s [Samozino/Morin]; the ends stretch it for the slowest and quickest.'),
 ('skill', 'acceleration', 'tau_s_at50', 1.2, 's', 'τ at 50.'),
 ('skill', 'acceleration', 'tau_s_at100', 0.9, 's', 'τ at 100.'),
 ('skill', 'deceleration', 'brake_mps2_at0', 5, 'm/s²', 'Braking limit at 0 — team-sport peak decelerations ~5-9 m/s² [Harper et al. 2019].'),
 ('skill', 'deceleration', 'brake_mps2_at50', 7, 'm/s²', 'At 50.'),
 ('skill', 'deceleration', 'brake_mps2_at100', 9, 'm/s²', 'At 100.'),
 ('skill', 'agility', 'turn_mps2_at0', 4, 'm/s²', 'Sideways (turning) limit at 0. [FH] estimate — curved-sprint / cutting source to pin.'),
 ('skill', 'agility', 'turn_mps2_at50', 6, 'm/s²', 'At 50.'),
 ('skill', 'agility', 'turn_mps2_at100', 8, 'm/s²', 'At 100.'),
 ('skill', 'dribbling', 'share_at0', 0.80, 'share', 'Top speed with the ball at 0 — ball-at-feet sprints run ~10-15% slower than free sprints (dribble-sprint tests); source to pin.'),
 ('skill', 'dribbling', 'share_at50', 0.88, 'share', 'At 50.'),
 ('skill', 'dribbling', 'share_at100', 0.95, 'share', 'At 100.'),
 ('skill', 'goalkeeping', 'dive_mps_at0', 3, 'm/s', 'Dive launch at 0. [FH] estimate — dive kinematics source to pin.'),
 ('skill', 'goalkeeping', 'dive_mps_at50', 4, 'm/s', 'At 50: with 0.6 s air + 1.2 m reach he covers ~3.6 m, a corner from the centre.'),
 ('skill', 'goalkeeping', 'dive_mps_at100', 5, 'm/s', 'At 100.')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);
