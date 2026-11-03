-- G5.6 (game/DESIGN.md §8.104): a beaten man recovers to his own spot in the
-- shape, not to a point in front of the ball (the cover man already holds the
-- ball-goal line), and only sprints back when the ball is inside
-- sprint_within_m of our goal; further out he gets back at the shape's pace.
-- to_shape is a switch; sprint_within_m is an [FH] fit, not measured.
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('concept', 'recover-goal-side', 'to_shape', 1, 'switch', 'Beaten, he runs back to his own spot in the shape; the cover man takes the ball-goal line.'),
 ('concept', 'recover-goal-side', 'sprint_within_m', 40, 'm', 'He sprints back only with the ball this close to our goal; further out, at the shape''s pace.')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, note = EXCLUDED.note;
