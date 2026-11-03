-- G5.7 (game/DESIGN.md §8.105): both sides slide across with the ball as a
-- block, and with the ball on the far side only the highest wide man holds
-- the width there (the rest take their shifted spot). Measured against DFL
-- tracking (7 matches): ball wide, real sides keep one man wide on the far
-- side; every wide man holding width put two on the far touchline and the
-- defenders marking them stayed wide. Slide share and cap are [FH] fits to
-- that profile, not measured directly.
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('concept', 'width', 'far_one', 1, 'switch', 'Ball on the far side: only the highest wide man holds the width there.'),
 ('physics', 'shape', 'ours_shift_y', 0.6, 'share', 'In possession the shape slides across this share of the ball''s y.'),
 ('physics', 'shape', 'ours_cap_y_m', 20, 'm', 'In possession the slide across is at most this far.'),
 ('physics', 'shape', 'theirs_shift_y', 0.6, 'share', 'Without the ball the shape slides across this share of the ball''s y.'),
 ('physics', 'shape', 'theirs_cap_y_m', 20, 'm', 'Without the ball the slide across is at most this far.')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, note = EXCLUDED.note;
