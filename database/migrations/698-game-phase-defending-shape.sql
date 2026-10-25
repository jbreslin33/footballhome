-- 698 (2026-10-24) — game: the defending team's restart shape (game/
-- DESIGN.md §8.54, G4.58).
--
-- James: "ukies back line would be on half line and then cdms in front of
-- them about 8 to 10 yards. then their line of 3 8 to 10 in front of cdms.
-- then striker" / "their 7 and 11 would protect lanes 2 and 4 and their 9
-- and 10 lane 3" / "of 5 lanes".
--
-- Restart shapes gain a side: 'in' = the team in possession (mig 697),
-- 'out' = the team defending the phase. Depth is always from the team's
-- OWN goal line, width + = left from its own view. Five lanes across the
-- 68 m pitch, 13.6 m each: lane 3 is the centre (|y| < 6.8), lanes 2 / 4
-- either side (centre ±13.6). Rows win over press_line_pct (mig 696).

ALTER TABLE game_phase_positions ADD COLUMN IF NOT EXISTS side text NOT NULL DEFAULT 'in'
  CHECK (side IN ('in', 'out'));
ALTER TABLE game_phase_positions DROP CONSTRAINT IF EXISTS game_phase_positions_pkey;
ALTER TABLE game_phase_positions ADD PRIMARY KEY (phase_code, formation_code, side, number);

INSERT INTO game_phase_positions (phase_code, formation_code, side, number, depth_m, width_m, note) VALUES
 ('keeper', '4-2-3-1', 'out', 2, 52.5, -19, 'back four on the half line (James)'),
 ('keeper', '4-2-3-1', 'out', 5, 52.5, -6, 'back four on the half line (James)'),
 ('keeper', '4-2-3-1', 'out', 4, 52.5, 6, 'back four on the half line (James)'),
 ('keeper', '4-2-3-1', 'out', 3, 52.5, 19, 'back four on the half line (James)'),
 ('keeper', '4-2-3-1', 'out', 6, 60.5, -8, 'the two CDMs 8-10 yards in front of the back line (James)'),
 ('keeper', '4-2-3-1', 'out', 8, 60.5, 8, 'the two CDMs 8-10 yards in front of the back line (James)'),
 ('keeper', '4-2-3-1', 'out', 11, 68.5, -13.6, 'line of three 8-10 yards in front of the CDMs; protects lane 4 (James)'),
 ('keeper', '4-2-3-1', 'out', 10, 68.5, 0, 'line of three; protects lane 3 (James)'),
 ('keeper', '4-2-3-1', 'out', 7, 68.5, 13.6, 'line of three; protects lane 2 (James)'),
 ('keeper', '4-2-3-1', 'out', 9, 76.5, 0, 'then the striker, lane 3 (James)')
ON CONFLICT DO NOTHING;
