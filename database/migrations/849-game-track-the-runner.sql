-- 849 (2026-10-29) — game: track the runner wired (concept 121, G4.96,
-- game/DESIGN.md §8.94); the pro's through balls.
--
-- James 10/29: "continue" (shots: the block isn't goal-side). Goals came
-- from balls in behind — 199 a match (both teams), ~78% reaching the runner;
-- Premier League 2015/16 (StatsBomb Open Data, 380 matches, Pass technique
-- Through Ball): 2.04 a team a match, 33.7% completed. At the kick the
-- runner's nearest defender held shape 22%, 8 m+ off him a third of the
-- time, the runner 4 m/s+ faster toward goal a quarter of the time. The
-- technique def-track-runner was 'teaching'. A core out-of-possession
-- concept every top-level model asks for (mig 762).

BEGIN;

-- 121 has been in the curriculum ('queued') since the taxonomy; every
-- top-level model already states its demand.
UPDATE game_concepts
   SET status = 'wired', taught_from = COALESCE(taught_from, 'amateur'),
       cue_answer = 'Their carrier is free to play it in behind and a runner near you goes past your line: the man responsible (the nearest of us) goes with him, goal-side of where he''s going — don''t hold the line''s height and watch him run off you. Leave him if he''s offside.',
       lacking = COALESCE(NULLIF(lacking, ''), 'Holds the line and turns to watch the runner already gone; the ball in behind finds him alone.')
 WHERE id = 121 AND name = 'track-the-runner';

INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT 121, s.id, v.cit FROM (VALUES
 ('fh', 'James 10/29 (shots): the ball in behind; measured 199 a match vs pro 2 a team (G4.96).'),
 ('us-soccer-u17', 'Out of possession: track runners, deny the space behind.')
) AS v(code, cit) JOIN game_sources s ON s.code = v.code
ON CONFLICT DO NOTHING;

UPDATE game_techniques SET status = 'wired' WHERE code = 'def-track-runner';
INSERT INTO game_concept_techniques (concept_id, technique_id)
SELECT 121, t.id FROM game_techniques t WHERE t.code IN ('def-track-runner', 'def-recovery-run', 'def-goal-side')
ON CONFLICT DO NOTHING;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'track-the-runner', 'near_m', 8::numeric, 'm', 'A runner this close to him (the nearest of us goes). [FH]'),
 ('concept', 'track-the-runner', 'run_mps', 4, 'm/s', 'Going for our goal at least this fast. [FH]'),
 ('concept', 'track-the-runner', 'lead_s', 0.4, 's', 'He aims where the runner will be this far on. [FH]'),
 ('concept', 'track-the-runner', 'goal_side_m', 1.5, 'm', '... and this far goal-side of it. [FH]')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);

INSERT INTO game_benchmark_metrics (code, label, unit, definition) VALUES
  ('through_balls_per_team_match', 'Balls in behind a team a match (through balls)', 'passes',
   'StatsBomb: open-play passes with technique Through Ball. Harness: a laddered pass to rung 1-2 (into the space behind their line).'),
  ('through_ball_completion_pct', 'Balls in behind completed', '%', 'As through_balls_per_team_match, reaching a mate.')
ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, unit = EXCLUDED.unit, definition = EXCLUDED.definition;

INSERT INTO game_benchmarks (source_id, level, competition, season, matches, metric, value)
SELECT s.id, 'pro', 'Premier League', '2015/2016', 380, v.metric, v.value
  FROM game_sources s, (VALUES ('through_balls_per_team_match', 2.04), ('through_ball_completion_pct', 33.7)) AS v(metric, value)
 WHERE s.code = 'statsbomb-open-data'
ON CONFLICT (source_id, competition, season, metric) DO UPDATE SET value = EXCLUDED.value, matches = EXCLUDED.matches;

COMMIT;
