-- 697 (2026-10-24) — game: where each player stands at a restart, by
-- formation and position number (game/DESIGN.md §8.54, G4.58).
--
-- James: "we need our players in more realistic places on restart. check
-- what is normally done by most teams in a 433" / "our forwards would be
-- near half line" / "our full backs split to touch line" / "our 6 above the
-- pen box" / "our 8 and 10 high but not as high as half line" / "our cbs
-- inside box on or on edge low".
--
-- Sources for the shape (no source gives metres — the numbers are [FH]
-- estimates for James to correct): FIFA Training Centre "Building from
-- goal kicks" (CBs receive inside their own box since the 2019 law; their
-- width decides where the press leaves space; full-backs "high and wide";
-- the keeper is the extra man); Coaches' Voice on Pochettino's 4-3-3 build-
-- up (the pivot dropping in front of / between the split centre-backs).

CREATE TABLE IF NOT EXISTS game_phase_positions (
  phase_code text NOT NULL REFERENCES game_phases(code),
  formation_code text NOT NULL,
  number smallint NOT NULL,       -- position number (formation_slot_roles.number)
  depth_m numeric NOT NULL,       -- metres up the pitch from the team's own goal line
  width_m numeric NOT NULL,       -- metres across from the centre line, + = left (the team's view)
  note text NOT NULL DEFAULT '',
  PRIMARY KEY (phase_code, formation_code, number)
);
COMMENT ON TABLE game_phase_positions IS
  'Restart shapes: where the team IN POSSESSION stands for a phase, per formation and position number. A formation with no rows for a phase takes its ordinary shape for that ball.';

INSERT INTO game_phase_positions (phase_code, formation_code, number, depth_m, width_m, note) VALUES
 ('keeper', '4-3-3', 1, 5.5, 0, 'on the ball'),
 ('keeper', '4-3-3', 4, 7, 19, 'centre-backs inside the box on its edge, low (James)'),
 ('keeper', '4-3-3', 5, 7, -19, 'centre-backs inside the box on its edge, low (James)'),
 ('keeper', '4-3-3', 6, 19, 0, 'the 6 just above the box (James)'),
 ('keeper', '4-3-3', 3, 30, 33.5, 'full-backs split to the touchline (James), high'),
 ('keeper', '4-3-3', 2, 30, -33.5, 'full-backs split to the touchline (James), high'),
 ('keeper', '4-3-3', 10, 42, 13, 'the 8 and 10 high, short of the half line (James); half-spaces'),
 ('keeper', '4-3-3', 8, 42, -13, 'the 8 and 10 high, short of the half line (James); half-spaces'),
 ('keeper', '4-3-3', 7, 49, 28, 'forwards near the half line (James)'),
 ('keeper', '4-3-3', 11, 49, -28, 'forwards near the half line (James)'),
 ('keeper', '4-3-3', 9, 50, 0, 'forwards near the half line (James)')
ON CONFLICT DO NOTHING;
