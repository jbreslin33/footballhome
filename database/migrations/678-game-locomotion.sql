-- 678 (2026-10-24) — game: locomotion physics + the keeper dive
-- (game/DESIGN.md §8.47, G4.51).
--
-- The World set vel = desire × max_speed: 0 → top speed in one tick and
-- free 180° turns — the root of the escort, the 3-14% duels and the shot
-- flood (§8.46 audit). Bodies now follow the mono-exponential sprint law
-- (core::Locomotion); keepers dive instead of running at shots. New owner
-- 'physics' for World-side numbers.

ALTER TABLE game_model_params DROP CONSTRAINT game_model_params_owner_check;
ALTER TABLE game_model_params ADD CONSTRAINT game_model_params_owner_check
    CHECK (owner = ANY (ARRAY['skill'::text, 'concept'::text, 'technique'::text, 'physics'::text]));

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('physics', 'locomotion', 'tau_s', 1.2::numeric, 's',
  'Sprint time constant: v(t) = top·(1 − e^(−t/τ)) [Furusawa, Hill & Parkinson 1927; Samozino/Morin sprint profiling — team-sport athletes ≈ 1.0-1.3 s].'),
 ('physics', 'locomotion', 'max_accel_mps2', 7, 'm/s²',
  'Cap on any change of velocity (braking, cutting, reversing). Team-sport peak decelerations run ~5-9 m/s² [Harper et al. 2019 review]; mid value, to refine.'),
 ('physics', 'locomotion', 'dribble_pct', 88, '%',
  'A carrier''s top speed as a share of his own: ball-at-feet sprints run ~10-15% slower than free sprints (dribble-sprint tests). Source to pin.'),
 ('physics', 'keeper_dive', 'speed_mps', 4, 'm/s',
  'Lateral launch speed of a keeper''s dive. With air_ms 600 + 1.2 m reach he covers ~3.6 m: a corner from the centre, just. [FH] estimate — dive kinematics source to pin.'),
 ('physics', 'keeper_dive', 'air_ms', 600, 'ms',
  'Time airborne: ballistic, no steering.'),
 ('physics', 'keeper_dive', 'ground_ms', 800, 'ms',
  'Down on the turf after landing before he can get up — the rebound window.')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);
