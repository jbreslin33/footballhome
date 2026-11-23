-- G5.230 (game/DESIGN.md §8.336): the ball into an empty zone ahead goes in the air at the real high share for its
-- length and direction, and the high one is played whoever would be first to it — only the ground one keeps the
-- "ours first" gate. StatsBomb PL 15/16 (benchmarks_statsbomb_midloss.py): forward passes of 30 m+ are high 28.9 a
-- team-match (19.8 not completed); ours 17.3 (9.0) — our space ball was always along the ground and dropped when
-- theirs were nearer. x this of the high ball's share: 1 gave 41.9 (26.6) and goals 2.64; 0.45 gives 30.9 (18.8)
-- — from our own third 19.7 / 11.3 (18.8 / 12.9), from 52-70 m 6.4 / 4.1 (7.0 / 4.8) — completion 85.4 -> 81.0% (77.5),
-- throw-ins 17.0 -> 20.0 (23.1), carries of 10 m+ 38.3 -> 34.9 (34.6), goals 2.34 -> 2.31. Seeds 1000-4000 x 8.
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'space', 'high', 0.45, 'share', 'G5.230 §8.336: the ball into an empty zone goes high at the real share for its length x this, played whoever is first (0 = always the ground ball, only when ours is first)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
