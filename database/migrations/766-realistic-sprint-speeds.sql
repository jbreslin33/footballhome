-- 766 (2026-10-27) — game: realistic top speeds and acceleration
-- (game/DESIGN.md §8.76, G4.79).
--
-- James 10/27: "4. yes make moveemnte realistic!" (open since G4.52:
-- "acceleration too slow").
--
-- The law was right (mono-exponential sprint, τ); the NUMBERS were not:
-- pace 50 ran 6.4 m/s and pace 100 7.4 m/s (23-27 km/h) — Lighthouse and
-- the Ukies (pace 61) topped out at 6.6 m/s. Real maximal sprint speeds
-- [Mendez-Villanueva et al. 2011, J Sports Sci — maximal sprinting speed
-- by age in academy players: ~U13 7.1, U15 7.9, U17 8.4, U18 8.6 m/s;
-- Haugen et al. 2014 — sprint speed by playing level; Premier League
-- tracking (Second Spectrum) — typical match top speeds 32-34 km/h, the
-- fastest ~36-37]: amateur adults ~7.5-8, semi-pro ~8.3-8.8, pro ~9-9.5,
-- elite 10+. Pace now maps 0 → 6.0 m/s, 50 → 8.0, 100 → 10.0, so a
-- semi-pro side at pace ~61 runs 8.4 m/s (30 km/h).
--
-- Acceleration: τ (s) — team-sport force-velocity profiles run V0/F0 ≈
-- 1.0-1.3 s [Samozino/Morin; Jiménez-Reyes et al. 2018, soccer]: 1.1 at
-- 50 (was 1.2), 0.85 at 100, 1.4 at 0. With the faster top speed the first
-- acceleration (top/τ) goes from ~5.5 to ~7.5 m/s² for our sides — 10 m in
-- ~2.0 s from a standing start, 30 m in ~4.4 s.
--
-- Teams with no pace ratings (the band demo sides) run on their rows'
-- max_speed_cms: ×1.35 puts them on the same data — U10 6.2, U14 7.5,
-- amateur 7.9, semi-pro 8.5, world 9.2 m/s on average.

BEGIN;

UPDATE game_model_params SET value = 600,
       note = 'Top speed at pace 0: 6.0 m/s (a slow adult). Maximal sprint data: amateur ~7.5-8, semi-pro ~8.3-8.8, pro ~9-9.5, elite 10+ m/s [Mendez-Villanueva 2011; Haugen 2014; PL tracking].'
 WHERE owner = 'skill' AND code = 'pace' AND param = 'base_cms';
UPDATE game_model_params SET value = 4,
       note = 'Added per pace point: 8.0 m/s at 50, 10.0 at 100.'
 WHERE owner = 'skill' AND code = 'pace' AND param = 'per_point_cms';

UPDATE game_model_params SET value = 1.4
 WHERE owner = 'skill' AND code = 'acceleration' AND param = 'tau_s_at0';
UPDATE game_model_params SET value = 1.1,
       note = 'τ at 50 — soccer force-velocity profiles V0/F0 ≈ 1.0-1.3 s [Samozino/Morin; Jiménez-Reyes 2018].'
 WHERE owner = 'skill' AND code = 'acceleration' AND param = 'tau_s_at50';
UPDATE game_model_params SET value = 0.85
 WHERE owner = 'skill' AND code = 'acceleration' AND param = 'tau_s_at100';

UPDATE game_demo_players SET max_speed_cms = round(max_speed_cms * 1.35);

COMMIT;
