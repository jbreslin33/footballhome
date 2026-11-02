-- 922 (2026-10-31) — game: the ball out of play is the officials' call (G5.2,
-- game/DESIGN.md §8.100).
--
-- James: "we need out of bounds with throw ins. we need goal kicks and corner
-- kicks. refs should call them." Restarts existed since G3 as a silent
-- teleport the World decided. Now: whole ball over the line, play stops, the
-- official whose line it is calls it, the ball comes back to its Law spot, the
-- taker walks there, the referee's restart time runs, he plays it.
--
-- Restart times are the lower quartile of StatsBomb's dead time (the taker's
-- own seconds come on top). Numbers marked [FH] are first numbers of ours, no
-- published source found. Pro rows: benchmarks_statsbomb_restarts.py, a
-- 60-match sample of PL 2015/16 (goal kicks predate the 2019 law, so they run
-- longer than today's).

BEGIN;

-- The Laws.
INSERT INTO game_ref_laws (id, number, code, title, summary, status, source_id)
SELECT x.id, x.number, x.code, x.title, x.summary, 'wired', s.id
FROM (VALUES
  (15, 15, 'law-15-throw-in', 'The Throw-in', 'To the opponents of the last toucher, where the ball crossed the touchline; from behind and over the head; opponents 2 m away; no goal direct; no offside.'),
  (16, 16, 'law-16-goal-kick', 'The Goal Kick', 'Attackers last touched it over the goal line: from anywhere in the goal area, opponents outside the penalty area until it is in play; no offside.'),
  (17, 17, 'law-17-corner-kick', 'The Corner Kick', 'Defenders last touched it over their goal line: from the corner arc, opponents 9.15 m away until it is in play; no offside.')
) AS x(id, number, code, title, summary)
JOIN game_sources s ON s.code = 'ifab-lotg'
ON CONFLICT (id) DO NOTHING;

UPDATE game_ref_judgements
   SET made_by = 'assistant',
       cue_call = 'The whole ball over the whole goal line or touchline → out. Each assistant calls his own touchline in his half and his goal line; the far half of a touchline is the referee''s. The line itself is still exact; who touched it last is judged (ball-out-last-touch).'
 WHERE code = 'ball-out-of-play';

INSERT INTO game_ref_judgements (id, law_id, code, title, cue_call, made_by, status, sort_order) VALUES
  (10, 9,  'ball-out-last-touch', 'Who touched it last',
   'Ball out off a man → whose touch was it? A clean ball out is never wrong; off a man he can give it the wrong way, likelier the further he stood from the touch. His call stands.', 'assistant', 'wired', 10),
  (11, 15, 'throw-in-award', 'Throw-in', 'Over the touchline → to the opponents of the last toucher, where it crossed. Flag up 45 degrees toward their attack; the referee repeats it.', 'assistant', 'wired', 11),
  (12, 16, 'goal-kick-award', 'Goal kick', 'Attackers last touched it over the goal line, no goal → flag points at the goal area; the referee repeats it.', 'assistant', 'wired', 12),
  (13, 17, 'corner-award', 'Corner kick', 'Defenders last touched it over their goal line, no goal → flag points at the corner arc; the referee repeats it.', 'assistant', 'wired', 13),
  (14, 5,  'restart-ready', 'The restart is ready', 'He lets a dead ball be played once it is on its spot and his restart time has run.', 'referee', 'wired', 14)
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_ref_perceptions (id, code, title, how, status) VALUES
  (5, 'last-touch-off-a-man', 'A touch off a man', 'A ball that comes off a player just before it goes out: the touch is small and from a distance he reads it as the other man''s.', 'wired')
ON CONFLICT (id) DO NOTHING;
INSERT INTO game_ref_judgement_perceptions (judgement_id, perception_id) VALUES (10, 5) ON CONFLICT DO NOTHING;

-- The numbers.
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
  ('official', 'restart', 'call_s', 0.4, 's', 'Ball over the line to the call [FH].'),
  ('official', 'restart', 'retrieve_s', 1.5, 's', 'The call to the ball back at its spot [FH].'),
  ('official', 'restart', 'throw_in_s', 8.4, 's', 'Earliest a throw is played after the ball goes out: pro dead time lower quartile (StatsBomb PL 2015/16 sample).'),
  ('official', 'restart', 'goal_kick_s', 21.8, 's', 'Same, goal kick.'),
  ('official', 'restart', 'corner_s', 21.2, 's', 'Same, corner.'),
  ('official', 'restart', 'deflection_s', 1.0, 's', 'A touch off a man this recent can be misread [FH].'),
  ('official', 'restart', 'wrong_pct_per_10m', 5, '%', 'Chance of giving a ball off a man the wrong way, per 10 m from the touch [FH: no published rate found].'),
  ('official', 'restart', 'wrong_pct_max', 30, '%', 'Cap on that chance [FH].'),
  ('official', 'restart', 'throw_max_m', 28, 'm', 'Longest throw: pro 90th percentile (StatsBomb sample). Long-throw specialists not modelled.'),
  ('physics', 'restart', 'throw_look_s', 1.0, 's', 'Thrower looks before he can release [FH].'),
  ('physics', 'restart', 'throw_wait_s', 4.0, 's', 'He waits this long for a man to come free [FH].'),
  ('physics', 'restart', 'corner_look_s', 1.5, 's', 'Corner taker looks up [FH].'),
  ('physics', 'restart', 'keeper_wait_s', 3.0, 's', 'Keeper goes long if his concepts found nothing by then [FH].'),
  ('physics', 'restart', 'throw_min_m', 4, 'm', 'Nearest man worth a throw [FH].'),
  ('physics', 'restart', 'throw_room_m', 10, 'm', 'Room around a receiver stops counting past this [FH].'),
  ('physics', 'restart', 'throw_free_m', 3, 'm', 'A receiver this free gets it now [FH].'),
  ('physics', 'restart', 'throw_gain', 0.3, '', 'Value of a metre gained, against a metre of room [FH].'),
  ('physics', 'restart', 'keeper_long_m', 55, 'm', 'Goal kick gone long: pro median 60 m (StatsBomb sample), kept inside the band''s range.'),
  ('physics', 'restart', 'throw_law_m', 2, 'm', 'Law 15.'),
  ('physics', 'restart', 'kick_law_m', 9.15, 'm', 'Law 13, Law 17.')
ON CONFLICT DO NOTHING;

-- Pro reference.
INSERT INTO game_benchmark_metrics (code, label, unit, definition) VALUES
  ('throw_ins_per_team_match', 'Throw-ins a team a match', 'count', 'Passes of type Throw-in.'),
  ('throw_ins_dead_median_s', 'Throw-in: seconds dead, median', 's', 'End of the event before it to the throw (game: ball over the line to played).'),
  ('throw_ins_length_median_m', 'Throw-in: length, median', 'm', 'pass.length (game: spot to first control).'),
  ('throw_ins_completion_pct', 'Throw-in: reaches a mate', '%', 'No pass.outcome (game: first control is ours).'),
  ('throw_ins_shot_10s_pct', 'Throw-in: a shot within 10 s', '%', 'Same team shoots within 10 s.'),
  ('goal_kicks_per_team_match', 'Goal kicks a team a match', 'count', 'Passes of type Goal Kick.'),
  ('goal_kicks_dead_median_s', 'Goal kick: seconds dead, median', 's', 'As throw-ins.'),
  ('goal_kicks_length_median_m', 'Goal kick: length, median', 'm', 'As throw-ins. Pre-2019 law: longer than today.'),
  ('goal_kicks_completion_pct', 'Goal kick: reaches a mate', '%', 'As throw-ins.'),
  ('goal_kicks_shot_10s_pct', 'Goal kick: a shot within 10 s', '%', 'As throw-ins.'),
  ('corners_per_team_match', 'Corners a team a match', 'count', 'Passes of type Corner.'),
  ('corners_dead_median_s', 'Corner: seconds dead, median', 's', 'As throw-ins.'),
  ('corners_length_median_m', 'Corner: length, median', 'm', 'As throw-ins.'),
  ('corners_completion_pct', 'Corner: reaches a mate', '%', 'As throw-ins.'),
  ('corners_shot_10s_pct', 'Corner: a shot within 10 s', '%', 'As throw-ins.')
ON CONFLICT (code) DO NOTHING;

INSERT INTO game_benchmarks (source_id, level, competition, season, matches, metric, value)
SELECT s.id, 'pro', 'Premier League', '2015/2016', 60, x.metric, x.value
FROM game_sources s, (VALUES
  ('throw_ins_per_team_match', 23.1), ('throw_ins_dead_median_s', 13.1), ('throw_ins_length_median_m', 15.4), ('throw_ins_completion_pct', 82), ('throw_ins_shot_10s_pct', 2.8),
  ('goal_kicks_per_team_match', 8.5), ('goal_kicks_dead_median_s', 27.4), ('goal_kicks_length_median_m', 60.1), ('goal_kicks_completion_pct', 49), ('goal_kicks_shot_10s_pct', 0.2),
  ('corners_per_team_match', 5.7), ('corners_dead_median_s', 27.0), ('corners_length_median_m', 34.4), ('corners_completion_pct', 42), ('corners_shot_10s_pct', 31.3)
) AS x(metric, value)
WHERE s.code = 'statsbomb-open-data';

-- A corner's shape (phases corner-left / corner-right had no rows, so a corner
-- had no shape). First numbers [FH], a coach's to change. Same table for 4-3-3
-- and 4-2-3-1. Depth = metres from the team's OWN goal line, width + = its left.
-- Written for corner-left (ball on the attackers' left); corner-right mirrors
-- the widths and swaps 7/11 and 2/3. The 11 takes from the left (mark on the
-- ball: 104.5, 33.5), the 7 from the right.
WITH rows(side, number, depth_m, width_m, note) AS (VALUES
  ('in',  1, 30.0,   0.0, 'Keeper up to the edge of his area.'),
  ('in',  2, 60.0, -20.0, 'Rest defence.'),
  ('in',  3, 60.0,  20.0, 'Rest defence.'),
  ('in',  4, 99.0,  -4.0, 'Attacks the far post.'),
  ('in',  5, 94.0,   0.0, 'Attacks the penalty spot.'),
  ('in',  6, 65.0,   0.0, 'Rest defence, the second ball.'),
  ('in',  7, 96.0,  -8.0, 'Back post.'),
  ('in',  8, 88.0,   8.0, 'Edge of the box.'),
  ('in',  9,100.0,   3.0, 'Attacks the near post.'),
  ('in', 10, 88.0,  -6.0, 'Edge of the box.'),
  ('in', 11,104.5,  33.5, 'Takes it.'),
  ('out', 1,  1.0,   0.0, 'On his line.'),
  ('out', 2,  1.5,  -3.5, 'Near post.'),
  ('out', 3,  1.5,   3.5, 'Far post.'),
  ('out', 4,  5.5,  -1.0, 'Six-yard line.'),
  ('out', 5,  5.5,   3.0, 'Six-yard line.'),
  ('out', 6,  9.0,   0.0, 'Penalty spot zone.'),
  ('out', 7, 20.0,  -2.0, 'Edge of the box, the second ball.'),
  ('out', 8, 10.0,  -6.0, 'Marks in the box.'),
  ('out', 9,  6.0,  -5.0, 'Front of the near post.'),
  ('out',10, 11.0,   6.0, 'Marks in the box.'),
  ('out',11, 48.0,  15.0, 'Stays up for the counter.')
), f(formation_code) AS (VALUES ('4-3-3'), ('4-2-3-1'))
INSERT INTO game_phase_positions (phase_code, formation_code, side, number, depth_m, width_m, note)
SELECT 'corner-left', f.formation_code, r.side, r.number, r.depth_m, r.width_m, r.note FROM rows r, f
UNION ALL
SELECT 'corner-right', f.formation_code, r.side,
       CASE WHEN r.number = 7 THEN 11 WHEN r.number = 11 THEN 7
            WHEN r.number = 2 THEN 3 WHEN r.number = 3 THEN 2 ELSE r.number END,
       r.depth_m, -r.width_m, r.note FROM rows r, f
ON CONFLICT (phase_code, formation_code, side, number) DO NOTHING;

COMMIT;
