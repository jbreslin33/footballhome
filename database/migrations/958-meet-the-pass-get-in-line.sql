-- G5.5 (game/DESIGN.md §8.103): the man a rolling pass is for gets his body on
-- its line first, then comes along it; a man adjusting his shape goes only as
-- fast as the gap asks, at a jog at most, and defending men stop short of a full
-- sprint. All five numbers are [FH] fits, not measured.
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('concept', 'meet-the-pass', 'early_s',   0.25, 's', 'He takes the first spot he reaches this long ahead of the ball.'),
 ('concept', 'meet-the-pass', 'on_line_m', 0.25, 'm', 'Inside this far of its line he counts as on it and comes along it.'),
 ('physics', 'body', 'shape_tau_s', 4, 's', 'Holding shape he closes the gap to his spot in this long, not at a run.'),
 ('physics', 'body', 'shape_max_mps', 4.5, 'm/s', 'The fastest a man holding shape goes: a team shifts as a block at a jog.'),
 ('physics', 'body', 'defend_max_mps', 6, 'm/s', 'The fastest a man recovering, marking or protecting the middle goes.')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, note = EXCLUDED.note;
