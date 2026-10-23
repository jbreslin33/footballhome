-- 646 (2026-10-23) — game: the pass ladder (game/DESIGN.md §8.31,
-- CONCEPTS.md G4.35).
--
-- James: "yes build pass_ladder" — the first concept from the Leeds book
-- [Bielsa-Leeds ch4]: the passer looks forward in a fixed order — behind
-- their back line (central, then wide), the pocket in front of it
-- (central, then wide), past their first line (central, then wide) — and
-- plays a high enough rung at once. Concept bit 29 'pass-ladder', class
-- ai::PassLadder; STYLE (default 0 at every band), so bands and goldens
-- are untouched. Teams get it from their preset.

INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('concept', 'pass-ladder', 'pocket_depth_m',       10,  'm',
  'Rungs 3-4: a receiver within this much in front of their deepest outfield player is in the pocket before their back line [Bielsa-Leeds ch4].'),
 ('concept', 'pass-ladder', 'central_half_width_m', 20,  'm',
  'Central vs wide rung: |y| beyond this (about the width of the box) is the wide lane [Bielsa-Leeds ch4: central before wide].'),
 ('concept', 'pass-ladder', 'fire_rung_min',        2,   'rung',
  'Any laddered passer plays rungs 1-2 (in behind) at once — no "is it worth it" gain threshold.'),
 ('concept', 'pass-ladder', 'fire_rung_span',       2,   'rungs',
  'More rungs played at once at rating 100 (rounded): Bielsa 90 plays rungs 1-4 at once [Bielsa-Leeds ch4: progress quickly but cleanly].')
ON CONFLICT (owner, code, param) DO UPDATE
   SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;

INSERT INTO game_style_preset_ratings (preset_id, concept, rating, source)
SELECT p.id, 'pass-ladder', 90,
       'Bielsa-Leeds ch4 (Leeds 2019/20 tactical analysis): every receiver works a fixed order of forward options — behind the back line first, then the pocket in front of it, then between the lines — before going sideways.'
  FROM game_style_presets p
 WHERE p.name = 'Bielsa'
ON CONFLICT (preset_id, concept) DO UPDATE SET rating = EXCLUDED.rating, source = EXCLUDED.source;
