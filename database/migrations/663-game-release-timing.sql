-- 663 (2026-10-23) — game: release timing wired (game/DESIGN.md §8.39).
--
-- James: "continue with blind side etc". The passer's half of the
-- blind-side run [Bielsa-Leeds f54/f67/f71]: an unpressed carrier holds the
-- ball while a teammate attacks their line (onside, at pace, within 15 m),
-- and plays only the ball in behind once it is on. Class ai::ReleaseTiming.
-- Core (any good team does it): known from amateur up, demanded at 100
-- unless a model says otherwise (Bielsa asks 80).
UPDATE game_concepts SET status = 'wired', taught_from = 'amateur' WHERE name = 'release-timing';
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('concept', 'release-timing', 'approach_m', 15, 'm',
  'A teammate within this of their offside line, running at it, is "about to break" — the passer holds for him.'),
 ('concept', 'release-timing', 'runner_speed_mps', 4, 'm/s',
  'Only a teammate running at the line at least this fast counts as a run worth waiting for.')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
