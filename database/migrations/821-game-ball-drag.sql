-- 821 (2026-10-29) — game: the ball feels the air (G4.87, game/DESIGN.md
-- §8.85). Until now a ball in flight felt only gravity: a 30 m loft came
-- down at the 17 m/s it was struck, over every player's control speed.
-- core::BallFlight applies aerodynamic drag while the ball is airborne,
-- F_D = ½ ρ A v² C_D [Goff & Carré 2009], and solves the aimed loft's launch
-- speed and flight time WITH it — one law for the World that strikes the
-- ball and the Brain that reads it. Numbers as Goff & Carré measured them.

INSERT INTO game_sources (code, kind, title, url, verified) VALUES
  ('goff-carre-2009', 'analysis',
   'Goff & Carré (2009), Trajectory analysis of a soccer ball, Am J Phys 77(11):1020-1027',
   'https://doi.org/10.1119/1.3197187', true)
ON CONFLICT (code) DO NOTHING;

INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
  ('physics', 'ball', 'drag_coeff', 0.2, '',
   'Drag coefficient C_D of a no-spin ball in flight. Goff & Carré 2009: 0.2 at ~18 m/s launch (Re 2.6e5), 0.17 at 19.4. Below the drag crisis (~15-21 m/s, Asai et al.) real C_D roughly doubles — not modelled.'),
  ('physics', 'ball', 'air_density_kgm3', 1.2, 'kg/m3', 'Air density ρ (Goff & Carré 2009).'),
  ('physics', 'ball', 'diameter_m', 0.218, 'm', 'Ball diameter (Goff & Carré 2009: A ≈ 0.0375 m²).'),
  ('physics', 'ball', 'mass_kg', 0.424, 'kg', 'Ball mass (Goff & Carré 2009; Law 2 allows 0.41-0.45).')
ON CONFLICT DO NOTHING;
