-- 787 (2026-10-28) — game: pro interceptions and bad touches (game/DESIGN.md
-- §8.80, G4.82), beside migs 782/785.
--
-- James 10/28: "commit and deploy and conintyue" (ball-keeping). The harness
-- found passes cut out 124-132 times a team a match, every one cleanly
-- controlled. Premier League 2015/16 (StatsBomb Open Data, 380 matches,
-- game/scripts/benchmarks_statsbomb.py): 11.7 interceptions a team a match,
-- 7.2 of them kept (Won / Success In Play — 62%, the pro
-- intercept_control_pct in core::levelParams); 14.2 miscontrols, + 4.5
-- interceptions that came off the man = 18.7 bad touches.

BEGIN;

INSERT INTO game_benchmark_metrics (code, label, unit, definition) VALUES
  ('interceptions_kept_per_team_match', 'Passes cut out and kept, a team a match', 'interceptions',
   'StatsBomb Interception events with outcome Won or Success In Play. Harness: an opponent captures a kicked ball that was still travelling 3 m/s+ the tick before.'),
  ('bad_touches_per_team_match', 'Bad touches a team a match', 'touches',
   'StatsBomb Miscontrol events + Interceptions not kept (the ball came off the man). Harness: every World bobble (a ball too fast to control, a fumble, or a reaction touch that came off him).')
ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, unit = EXCLUDED.unit, definition = EXCLUDED.definition;

INSERT INTO game_benchmarks (source_id, level, competition, season, matches, metric, value)
SELECT s.id, 'pro', 'Premier League', '2015/2016', 380, v.metric, v.value
  FROM game_sources s, (VALUES
    ('interceptions_kept_per_team_match', 7.22),
    ('bad_touches_per_team_match', 18.71)
  ) AS v(metric, value)
 WHERE s.code = 'statsbomb-open-data'
ON CONFLICT (source_id, competition, season, metric) DO UPDATE SET value = EXCLUDED.value, matches = EXCLUDED.matches;

COMMIT;
