-- 696 (2026-10-24) — game: where the defending team sets up in a phase
-- (game/DESIGN.md §8.54, G4.58).
--
-- James: "for lighthouse restart set ukies in 4231 in our zone first off."
-- A phase now says how high the defending team starts: its most advanced
-- outfield line at press_line_pct up the pitch from the team in
-- possession's own goal line; the rest of its shape slides with it (its
-- keeper stays home). NULL = the shape it would take for that ball.

ALTER TABLE game_phases ADD COLUMN IF NOT EXISTS press_line_pct smallint;
COMMENT ON COLUMN game_phases.press_line_pct IS
  'Defending team''s most advanced outfield line, % up the pitch from the possessing team''s own goal line (20 = just outside their box: pressing high in their zone). NULL = natural shape for the ball.';

-- From the keeper: they set up in our zone — front line just outside our box.
UPDATE game_phases SET press_line_pct = 20 WHERE code = 'keeper';
