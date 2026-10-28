-- 782 (2026-10-28) — game: pro reference numbers in the DB (game/DESIGN.md
-- §8.79, G4.81b).
--
-- James 10/28: "can we actaully look at pro data and get it into db and then
-- we can work off it and referecne it?" — and "whatever pro data is semi pro
-- is worse of course". So the harness's numbers stop being judged against
-- figures from memory: every fh-game-match line that has a pro counterpart
-- prints it, from these rows.
--
-- Source: StatsBomb Open Data (github.com/statsbomb/open-data — free to use
-- with attribution to StatsBomb), Premier League 2015/16, all 380 matches,
-- event data. Measured by game/scripts/benchmarks_statsbomb.py with the
-- harness's own definitions (game_benchmark_metrics.definition). A new
-- league/season = rerun the script and add rows under its source; a
-- semi-pro source, if one ever exists, = level 'semipro'.
--
-- What it says (pro, a team a match unless noted): 12.9 shots, 2.5 goals a
-- match, 378 open-play passes at 79%, 121 possession spells a match of 47 s,
-- 2.1 balls lost within 35 m of their own goal (12.5% shot at inside 10 s),
-- 72% of open-play shots 20 s+ into the spell, 28% with 0-2 defenders
-- goal-side.

BEGIN;

CREATE TABLE IF NOT EXISTS game_benchmark_metrics (
  code        text PRIMARY KEY,
  label       text NOT NULL,
  unit        text NOT NULL,
  definition  text NOT NULL
);
COMMENT ON TABLE game_benchmark_metrics IS
  'What a game benchmark measures (mig 782): one row per measure, defined the way fh-game-match and game/scripts/benchmarks_statsbomb.py both measure it.';

CREATE TABLE IF NOT EXISTS game_benchmarks (
  id           serial PRIMARY KEY,
  source_id    integer NOT NULL REFERENCES game_sources(id),
  level        text NOT NULL CHECK (level IN ('u10','u14','amateur','semipro','pro','world')),
  competition  text NOT NULL,
  season       text NOT NULL,
  matches      integer NOT NULL CHECK (matches > 0),
  metric       text NOT NULL REFERENCES game_benchmark_metrics(code),
  value        numeric NOT NULL,
  UNIQUE (source_id, competition, season, metric)
);
COMMENT ON TABLE game_benchmarks IS
  'Real-football reference values for the game (mig 782): a source, a level band, a competition and season, how many matches, the metric and its value. The harness prints these beside its own lines. Pro data is a bound: semi-pro is worse.';

INSERT INTO game_sources (code, kind, title, url, verified)
VALUES ('statsbomb-open-data', 'analysis', 'StatsBomb Open Data (event data, free with attribution)', 'https://github.com/statsbomb/open-data', true)
ON CONFLICT DO NOTHING;

INSERT INTO game_benchmark_metrics (code, label, unit, definition) VALUES
  ('shots_per_team_match', 'Shots a team a match', 'shots', 'Shot events, penalties and shoot-outs left out (the game has neither).'),
  ('shots_open_play_per_team_match', 'Open-play shots a team a match', 'shots', 'Shots with shot.type Open Play.'),
  ('goals_per_match', 'Goals a match', 'goals', 'Goals from those shots plus own goals, both teams.'),
  ('goals_open_play_per_match', 'Open-play goals a match', 'goals', 'Goals from open-play shots, both teams.'),
  ('open_play_passes_per_team_match', 'Open-play passes a team a match', 'passes', 'Passes with no pass.type (not corners, free kicks, throw-ins, goal kicks, kick-offs).'),
  ('open_play_pass_completion_pct', 'Open-play passes completed', '%', 'Open-play passes with no outcome (reached a team-mate). Harness: kicks to a mate, any mate, over passes (shots, clears, punts left out).'),
  ('ground_pass_completion_pct', 'Ground passes completed', '%', 'Open-play passes of height Ground Pass that were completed.'),
  ('spells_per_match', 'Possession spells a match', 'spells', 'Changes of the team in possession (StatsBomb possession ids, consecutive same-team ones merged — a new spell needs CONTROL; the harness counts every change of the ball''s owner, so a touch-and-lose counts there and not here).'),
  ('spell_length_s', 'Spell length', 's', 'Clock time from one change of possession to the next, dead time included (both sides of the comparison).'),
  ('final_third_entries_per_team_match', 'Final-third entries a team a match', 'entries', 'Completed open-play passes and carries from outside the attacking third into it. Harness: the carrier enters the last 35 m.'),
  ('own_third_losses_per_team_match', 'Balls lost within 35 m of own goal, a team a match', 'losses', 'Spells that START in the losing team''s defensive third (the new team''s first on-ball event at x >= 80 of 120). Harness: the ball < 35 m from the loser''s goal when the owner flips.'),
  ('own_third_loss_shot_10s_pct', 'Own-third losses the other side shoots from inside 10 s', '%', 'Of those spells, the share with an open-play shot by the winners within 10 s of its start.'),
  ('own_third_loss_shot_spell_pct', 'Own-third losses that end in a shot that spell', '%', 'Of those spells, the share with an open-play shot by the winners at any point in it.'),
  ('op_shot_age_lt5s_pct', 'Open-play shots by the spell''s age: < 5 s', '%', 'Seconds from the spell''s start to the shot.'),
  ('op_shot_age_5_10s_pct', 'Open-play shots by the spell''s age: 5-10 s', '%', 'Seconds from the spell''s start to the shot.'),
  ('op_shot_age_10_20s_pct', 'Open-play shots by the spell''s age: 10-20 s', '%', 'Seconds from the spell''s start to the shot.'),
  ('op_shot_age_20s_plus_pct', 'Open-play shots by the spell''s age: 20 s+', '%', 'Seconds from the spell''s start to the shot.'),
  ('op_shot_goalside_0_2_pct', 'Open-play shots with 0-2 outfield defenders goal-side of the shooter', '%', 'Outfield opponents in the shot''s freeze frame nearer the goal line than the shooter (a broadcast frame can miss an off-camera man, so a floor).'),
  ('op_shot_goalside_3_4_pct', 'Open-play shots with 3-4 outfield defenders goal-side of the shooter', '%', 'Outfield opponents in the shot''s freeze frame nearer the goal line than the shooter (a broadcast frame can miss an off-camera man, so a floor).'),
  ('op_shot_goalside_5_6_pct', 'Open-play shots with 5-6 outfield defenders goal-side of the shooter', '%', 'Outfield opponents in the shot''s freeze frame nearer the goal line than the shooter (a broadcast frame can miss an off-camera man, so a floor).'),
  ('op_shot_goalside_7_plus_pct', 'Open-play shots with 7+ outfield defenders goal-side of the shooter', '%', 'Outfield opponents in the shot''s freeze frame nearer the goal line than the shooter (a broadcast frame can miss an off-camera man, so a floor).'),
  ('op_shot_dist_lt11m_pct', 'Open-play shots from < 11 m', '%', 'Distance from the shot to the centre of the goal (yards x 0.9144).'),
  ('op_shot_dist_11_18m_pct', 'Open-play shots from 11-18 m', '%', 'Distance from the shot to the centre of the goal (yards x 0.9144).'),
  ('op_shot_dist_18_25m_pct', 'Open-play shots from 18-25 m', '%', 'Distance from the shot to the centre of the goal (yards x 0.9144).'),
  ('op_shot_dist_25m_plus_pct', 'Open-play shots from 25 m+', '%', 'Distance from the shot to the centre of the goal (yards x 0.9144).'),
  ('op_shot_near_lt1_5m_pct', 'Open-play shots with the nearest defender < 1.5 m away', '%', 'Nearest outfield opponent in the freeze frame.'),
  ('op_shot_near_1_5_3m_pct', 'Open-play shots with the nearest defender 1.5-3 m away', '%', 'Nearest outfield opponent in the freeze frame.'),
  ('op_shot_near_3_6m_pct', 'Open-play shots with the nearest defender 3-6 m away', '%', 'Nearest outfield opponent in the freeze frame.'),
  ('op_shot_near_6m_plus_pct', 'Open-play shots with the nearest defender 6 m+ away', '%', 'Nearest outfield opponent in the freeze frame.'),
  ('op_shot_began_lt35m_pct', 'Open-play shots whose spell began < 35 m from the goal attacked', '%', 'Where the shooting team''s spell began: its first on-ball event, metres from the goal it attacks.'),
  ('op_shot_began_35_52m_pct', 'Open-play shots whose spell began 35-52 m from the goal attacked', '%', 'Where the shooting team''s spell began: its first on-ball event, metres from the goal it attacks.'),
  ('op_shot_began_52_70m_pct', 'Open-play shots whose spell began 52-70 m from the goal attacked', '%', 'Where the shooting team''s spell began: its first on-ball event, metres from the goal it attacks.'),
  ('op_shot_began_70m_plus_pct', 'Open-play shots whose spell began 70 m+ from the goal attacked', '%', 'Where the shooting team''s spell began: its first on-ball event, metres from the goal it attacks.')
ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, unit = EXCLUDED.unit, definition = EXCLUDED.definition;

INSERT INTO game_benchmarks (source_id, level, competition, season, matches, metric, value)
SELECT s.id, 'pro', 'Premier League', '2015/2016', 380, v.metric, v.value
  FROM game_sources s, (VALUES
    ('shots_per_team_match', 12.92),
    ('shots_open_play_per_team_match', 12.39),
    ('goals_per_match', 2.51),
    ('goals_open_play_per_match', 2.34),
    ('open_play_passes_per_team_match', 377.7),
    ('open_play_pass_completion_pct', 79.1),
    ('ground_pass_completion_pct', 91.2),
    ('spells_per_match', 120.7),
    ('spell_length_s', 46.7),
    ('final_third_entries_per_team_match', 44.4),
    ('own_third_losses_per_team_match', 2.1),
    ('own_third_loss_shot_10s_pct', 12.5),
    ('own_third_loss_shot_spell_pct', 28.4),
    ('op_shot_age_lt5s_pct', 2.1),
    ('op_shot_age_5_10s_pct', 7.2),
    ('op_shot_age_10_20s_pct', 17.3),
    ('op_shot_age_20s_plus_pct', 72.1),
    ('op_shot_goalside_0_2_pct', 27.7),
    ('op_shot_goalside_3_4_pct', 22.7),
    ('op_shot_goalside_5_6_pct', 25.6),
    ('op_shot_goalside_7_plus_pct', 23.9),
    ('op_shot_dist_lt11m_pct', 25.0),
    ('op_shot_dist_11_18m_pct', 30.1),
    ('op_shot_dist_18_25m_pct', 29.0),
    ('op_shot_dist_25m_plus_pct', 15.8),
    ('op_shot_near_lt1_5m_pct', 33.5),
    ('op_shot_near_1_5_3m_pct', 37.7),
    ('op_shot_near_3_6m_pct', 25.0),
    ('op_shot_near_6m_plus_pct', 3.9),
    ('op_shot_began_lt35m_pct', 5.0),
    ('op_shot_began_35_52m_pct', 12.9),
    ('op_shot_began_52_70m_pct', 23.0),
    ('op_shot_began_70m_plus_pct', 57.9)
  ) AS v(metric, value)
 WHERE s.code = 'statsbomb-open-data'
ON CONFLICT (source_id, competition, season, metric) DO UPDATE SET value = EXCLUDED.value, matches = EXCLUDED.matches;

COMMIT;
