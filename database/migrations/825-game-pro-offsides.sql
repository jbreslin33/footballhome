-- 825 (2026-10-29) — game: the pro offside number (game/DESIGN.md §8.87,
-- G4.89), beside migs 782/785/787; the metric row came with mig 822.
--
-- James 10/29: "do we have offsides lol" → "yes" (offside next). Premier
-- League 2015/16 (StatsBomb Open Data, 380 matches,
-- game/scripts/benchmarks_statsbomb.py 2 27): 1.96 offsides called a team a
-- match (Offside events + passes with outcome Pass Offside). The game called
-- 24-28.

BEGIN;

INSERT INTO game_benchmarks (source_id, level, competition, season, matches, metric, value)
SELECT s.id, 'pro', 'Premier League', '2015/2016', 380, 'offsides_per_team_match', 1.96
  FROM game_sources s
 WHERE s.code = 'statsbomb-open-data'
ON CONFLICT (source_id, competition, season, metric) DO UPDATE SET value = EXCLUDED.value, matches = EXCLUDED.matches;

COMMIT;
