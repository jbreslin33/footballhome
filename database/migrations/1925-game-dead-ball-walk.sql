-- G5.263 (game/DESIGN.md §8.369): a stoppage is walked, not sprinted (owner 11/25: "the game sometimes just stops with one
-- player dwelling on ball and everyone just watching"). DFL (benchmarks_tracking_deadmove.py, 7 matches): in the last 5 s
-- before a throw-in the players move 1.10 m/s on average, 48% at 1 m/s+; from the ball going dead 1.68 / 1.36 / 1.10 /
-- 0.91 / 0.72 m/s at 1-3 / 4-6 / 7-10 / 11-20 / 21-30 s. Ours ran to the restart spot (2.0-2.7 m/s in the first 6 s) and
-- stood: 0.1-0.3 by 11-20 s, ~0 by 21-30; 21-24% moving before a throw-in, 0-2% before a goal kick, 0% before a corner.
--   dead_ball_walk: while a restart is held a man goes to his spot at physics.dead.pace_mps at most.
-- Read (seeds 1000-4000 x 8): moving 1 m/s+ in the last 5 s, throw-in 21-24 -> 42-47% (48.1), goal kick 0-2 -> 17-19
-- (58.9), corner 0 -> 1-8 (13.7), free kick 10-14 -> 14-17 (38.5); dead before restarts unchanged (throw-in median 13.8 s,
-- free kick 34.3, goal kick 22.8); ball in play 56.8 -> 56.2% (55.2). Card 10/12/11 -> 10/11/12.
INSERT INTO game_engine_behaviours (code, file, line, tag, who, what, status, concept_id, other_concepts, suggested, confidence, is_read, in_sim)
VALUES ('dead_ball_walk', 'game/src/core/World.cpp', 1, 'dead ball 11/25', 'team',
        'While the ball is dead for a restart the players walk or jog to their places across the stoppage — they do not sprint there and stand: physics.dead.pace_mps at most.',
        'unnamed', NULL, NULL, NULL, 'high', false, true)
ON CONFLICT (code) DO NOTHING;
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'dead', 'pace_mps', 1.5, 'm/s', 'G5.263 §8.369: while a restart is held, a man goes to his spot at this pace at most (no row = 0, off)')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
