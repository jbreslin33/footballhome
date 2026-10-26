-- 733 (2026-10-26) — game: a phase of play for Lighthouse's trap
-- (game/DESIGN.md §8.62, G4.64): their centre-back on the ball, building.
--
-- James 10/26: "we essentially pack the middle then wait for the
-- inevitable pass to full then we press" / the 9 "helps mids then locks the
-- door on pass to fb". From the keeper the Ukies now kick long against the
-- packed middle, so the trap gets its own picture to drill and measure: the
-- goal-kick shape, the ball already at a split centre-back's feet (open
-- play) — does he go to the full-back, and does the trap spring?

INSERT INTO game_phases (code, title, kind, ball_x_pct, ball_y_pct, coaching_point, sort_order) VALUES
 ('cb-build', 'Centre-back on the ball', 'open', 7, 56,
  'Ball with our split centre-back on the box edge: play through, go to the full-back under the trap, or go long.', 15)
ON CONFLICT (code) DO NOTHING;

-- Same shape as from the keeper (migs 697, 705, 706): copy the rows.
INSERT INTO game_phase_positions (phase_code, formation_code, side, number, depth_m, width_m, note)
SELECT 'cb-build', formation_code, side, number, depth_m, width_m, note
  FROM game_phase_positions WHERE phase_code = 'keeper'
ON CONFLICT DO NOTHING;

-- The false 9 floats higher than the wingers' screen (James: he "helps mids
-- then locks the door on pass to fb").
INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT 'concept', 'pack-the-middle', 'nine_screen_gap_m', 8, 'm',
       'The false 9 stands this far off the man he screens, toward the ball: between their centre-backs and midfield, in reach to lock the door.'
WHERE NOT EXISTS (SELECT 1 FROM game_model_params WHERE owner = 'concept' AND code = 'pack-the-middle' AND param = 'nine_screen_gap_m');

-- James 10/26: "our 9 needs to stay close enough to ball side cb to lock
-- door on cb to fb transmission".
INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT 'concept', 'lock-the-door', 'reach_m', 8, 'm',
       'Before the trigger the 9 floats no further than this from the ball-side centre-back: close enough to lock the door while the pass to the full-back travels.'
WHERE NOT EXISTS (SELECT 1 FROM game_model_params WHERE owner = 'concept' AND code = 'lock-the-door' AND param = 'reach_m');
