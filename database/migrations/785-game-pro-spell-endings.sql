-- 785 (2026-10-28) — game: how pro possessions end (game/DESIGN.md §8.80,
-- G4.82), beside mig 782's reference rows.
--
-- James 10/28: "commit and deploy and conintyue" — next is ball-keeping (the
-- gap mig 782 showed: 679 spells a match of 6.8 s against 121 of 47 s). To
-- know WHICH way the game gives the ball away too often, every change of
-- possession is classed by what the losing side last did. Premier League
-- 2015/16 (StatsBomb Open Data, 380 matches, game/scripts/
-- benchmarks_statsbomb.py): 55.4% a lost pass, 0.9% a clearance, 12.8% a
-- shot, 11.0% a bad touch, 14.7% beaten on the ball, 5.3% other (keeper,
-- foul, ...).

BEGIN;

INSERT INTO game_benchmark_metrics (code, label, unit, definition) VALUES
  ('spell_end_pass_pct', 'Spells ended by a pass that didn''t reach a mate', '%', 'Of every change of possession, the share where the losing side last did this: a pass that didn''t reach a mate (picked off, out of play, or its receipt failed). StatsBomb: its last on-ball event in the possession.'),
  ('spell_end_clear_pct', 'Spells ended by a clearance', '%', 'Of every change of possession, the share where the losing side last did this: a clearance (the harness: a clear or keeper punt). StatsBomb: its last on-ball event in the possession.'),
  ('spell_end_shot_pct', 'Spells ended by a shot', '%', 'Of every change of possession, the share where the losing side last did this: a shot. StatsBomb: its last on-ball event in the possession.'),
  ('spell_end_bad_touch_pct', 'Spells ended by a bad touch', '%', 'Of every change of possession, the share where the losing side last did this: a bad touch (StatsBomb Miscontrol; the harness: the World''s bobble). StatsBomb: its last on-ball event in the possession.'),
  ('spell_end_on_ball_pct', 'Spells lost on the ball', '%', 'Of every change of possession, the share where the losing side last did this: beaten on the ball — dispossessed, a lost duel (aerial too), a failed dribble (the harness: tackled or stolen). StatsBomb: its last on-ball event in the possession.')
ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, unit = EXCLUDED.unit, definition = EXCLUDED.definition;

INSERT INTO game_benchmarks (source_id, level, competition, season, matches, metric, value)
SELECT s.id, 'pro', 'Premier League', '2015/2016', 380, v.metric, v.value
  FROM game_sources s, (VALUES
    ('spell_end_pass_pct', 55.4),
    ('spell_end_clear_pct', 0.9),
    ('spell_end_shot_pct', 12.8),
    ('spell_end_bad_touch_pct', 11.0),
    ('spell_end_on_ball_pct', 14.7)
  ) AS v(metric, value)
 WHERE s.code = 'statsbomb-open-data'
ON CONFLICT (source_id, competition, season, metric) DO UPDATE SET value = EXCLUDED.value, matches = EXCLUDED.matches;

COMMIT;
