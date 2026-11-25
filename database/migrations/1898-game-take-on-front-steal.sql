-- G5.260 (game/DESIGN.md §8.366): TAKE-ON ENDS. How a real take-on ends (StatsBomb PL 15/16, benchmarks_statsbomb_takeon_fail.py):
-- 18.05 tried / 10.59 completed a team-match; of the 7.46 failed, 3.81 tackled and theirs, 2.68 a tackle that knocks it
-- loose or out and his own side has it next (90-97%), 0.95 past him and lost it after. Ours (fh-game-match TAKE-ON ENDS,
-- seeds 1000-4000 x 8 on G5.259): 17.80 / 9.03 (50.7%); all 8.77 failed go to them — 4.88 tackles, 3.08 the v1
-- touch-tight steal (0.6 m for 10 ticks, no tackle, no foul: nothing in a real take-on), 0.81 nicks.
--   steal_front_ticks: a man square in front of the carrier (within 45 deg of his way to goal) takes it touch-tight only
--   after physics.steal.front_ticks (0 = kStealTicks 10, as before). With it the steal gone from the front, the off-feet
--   losses move to the side and behind as DFL has them: the nick rows from x0.37 to x0.6 of the DFL rate gaps.
-- Read (seeds 1000-4000 x 8): take-on success 50.7 -> 57.8% (58.7); taken off his feet 8.38 -> 7.89 (8.0); failed
-- take-ons 8.77 -> 6.84 (7.46); goals 2.41 -> 2.12 (1.35); fouls 12.8 -> 13.5 (12.5); passes 433 -> 424 (434).
INSERT INTO game_engine_behaviours (code, file, line, tag, who, what, status, concept_id, other_concepts, suggested, confidence, is_read, in_sim)
VALUES ('steal_front_ticks', 'game/src/core/World.cpp', 1, 'take-on ends 11/25', 'individual',
        'A defender square in front of the man on the ball (within 45 degrees of his way to goal) tackles him in real football; touch-tight on the ball he takes it without a tackle only after physics.steal.front_ticks (30 = 1 s), not the 10 ticks a man beside or behind needs.',
        'unnamed', NULL, 'engage-or-contain', NULL, 'high', false, true)
ON CONFLICT (code) DO NOTHING;
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
 ('physics', 'steal', 'front_ticks', 30, 'ticks', 'G5.260 §8.366: touch-tight from in front, ticks to take it without a tackle (0 = kStealTicks 10)'),
 ('physics', 'steal', 'nick_front_per_s', 0.03, '/s', 'G5.260 §8.366 (was 0.02, G5.259): a man within 1.5 m in front of the carrier takes it off his feet, a rate a second'),
 ('physics', 'steal', 'nick_side_per_s', 0.08, '/s', 'G5.260 §8.366 (was 0.05): … beside him'),
 ('physics', 'steal', 'nick_behind_per_s', 0.12, '/s', 'G5.260 §8.366 (was 0.07): … behind him')
ON CONFLICT (owner, code, param) DO UPDATE SET value = EXCLUDED.value, unit = EXCLUDED.unit, note = EXCLUDED.note;
