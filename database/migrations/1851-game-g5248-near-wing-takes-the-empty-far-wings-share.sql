-- G5.248 (game/DESIGN.md §8.354): a wide zone's far-wing share is held back only when a mate stands on the far wing.
-- The pass chooser split every wide zone's share (StatsBomb zone → zone x DFL kappa = its share given a mate in it, on
-- either wing) between its two wings at the real far share (G5.172) — and dropped the far wing's part when nobody was
-- there; a central zone has no such loss. THE CHOOSER'S CHAIN (harness §8.354), a central midfielder 35-52 m out, the
-- wide zone ahead: the table x presence 10.6% of his to-feet weight, after the wing split 7.6 -> 9.4; chosen 3.9 -> 5.2%;
-- the wide zone level chosen 14.9 -> 16.8% (the table 16.3). Passes struck within 14 m of a touchline 18-35 / 35-52 /
-- 52-70 m off the line attacked 23.0 / 40.6 / 41.6 -> 24.0 / 42.7 / 43.6 a team-match (36.4 / 49.2 / 45.8).
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'pass', 'wing_near_full', 1, 'flag', 'G5.248 §8.354: with the far wing of a wide zone empty the zone''s whole share is the near wing''s (the far share is the far man''s only when he is there)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;

DO $$
BEGIN
  IF to_regclass('public.game_engine_behaviours') IS NOT NULL THEN
    UPDATE game_engine_behaviours SET what = what || ' G5.248: with the far wing empty the near wing takes the zone''s whole share (row physics.pass.wing_near_full).'
     WHERE code = 'poss_pass_far_wing' AND what NOT LIKE '%G5.248%';
  END IF;
END $$;
