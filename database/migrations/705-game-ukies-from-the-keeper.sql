-- 705 (2026-10-26) — game: the Ukies' own shape building from the keeper
-- (game/DESIGN.md §8.58).
--
-- James 10/26: "fix 1) Ukies from the keeper. their cdms should be outside
-- the box." The 4-2-3-1 had no 'in' rows for the keeper phase, so it stood
-- in its open-play shape squeezed onto a ball on its own 6-yard line: back
-- four ON the goal line (2 m), both CDMs at 6.8 m, the wingers 17 m.
--
-- CDMs (6 and 8, the double pivot) just outside the box, split — James.
-- James: "thier 7,11 and 10 should be then 8 to 10 yards past the cdmes
-- and the 9 8 to 10 or near half line" — the line of three ~9 yd (8 m)
-- past the CDMs in lanes 2 / 3 / 4 (as in their defending shape, mig 698),
-- the 9 another ~9 yd on. The back five copy Lighthouse's goal-kick
-- numbers (mig 697, James's): keeper on the ball, centre backs low and
-- split to the box edge, full-backs high on the touchlines.
-- Depth from the team's own goal line, width + = left (7 = left winger,
-- 11 = right, 3 = left back, 2 = right back — mig 694).

INSERT INTO game_phase_positions (phase_code, formation_code, side, number, depth_m, width_m, note) VALUES
 ('keeper', '4-2-3-1', 'in', 1, 5.5, 0, 'on the ball'),
 ('keeper', '4-2-3-1', 'in', 4, 7, 19, 'centre-backs low, split to the box edge (as Lighthouse''s, James)'),
 ('keeper', '4-2-3-1', 'in', 5, 7, -19, 'centre-backs low, split to the box edge (as Lighthouse''s, James)'),
 ('keeper', '4-2-3-1', 'in', 2, 30, -33.5, 'full-backs high on the touchline (as Lighthouse''s, James)'),
 ('keeper', '4-2-3-1', 'in', 3, 30, 33.5, 'full-backs high on the touchline (as Lighthouse''s, James)'),
 ('keeper', '4-2-3-1', 'in', 6, 19, -8, 'CDMs just outside the box (James 10/26)'),
 ('keeper', '4-2-3-1', 'in', 8, 19, 8, 'CDMs just outside the box (James 10/26)'),
 ('keeper', '4-2-3-1', 'in', 7, 27, 13.6, 'line of three 8-10 yd past the CDMs, lane 2 (James 10/26)'),
 ('keeper', '4-2-3-1', 'in', 10, 27, 0, 'line of three 8-10 yd past the CDMs, lane 3 (James 10/26)'),
 ('keeper', '4-2-3-1', 'in', 11, 27, -13.6, 'line of three 8-10 yd past the CDMs, lane 4 (James 10/26)'),
 ('keeper', '4-2-3-1', 'in', 9, 35.5, 0, 'the 9 another 8-10 yd on (James 10/26: or near the half line)')
ON CONFLICT (phase_code, formation_code, side, number) DO UPDATE
  SET depth_m = EXCLUDED.depth_m, width_m = EXCLUDED.width_m, note = EXCLUDED.note;
