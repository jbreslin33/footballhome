-- 867 (2026-10-29) — game: the passer and the ball behind their line (G4.98,
-- game/DESIGN.md §8.96).
--
-- James 10/29: "yes" (take the passer). The pro's balls in behind, asked the
-- harness's way — a pass 3 m+ forward aimed past their last outfield man at
-- the kick — from StatsBomb Open Data's 360 freeze frames
-- (game/scripts/benchmarks_statsbomb_360.py): ~26 a team a match, 62%
-- completed (Euro 2020 51 matches, World Cup 2022 64). The game: 144 / 199.
-- Two causes on the passer's side:
--   * the pass ladder led ANY man moving forward into the space behind —
--     only a man running at their goal is led now (run_mps);
--   * "a high line" was any back line 30 m+ off its goal; a pro line sits at
--     49-50 m (median, passer in his own half) — 30 m is deeper than 9 in 10
--     of them. High now = higher than the pro median.

BEGIN;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
  ('concept', 'pass-ladder', 'run_mps', 4::numeric, 'm/s',
   'G4.98: only a man running at their goal this fast is led into the space behind (rungs 1-2); slower, he is played to his feet. Same bar as release-timing''s run worth waiting for. [FH]')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);

UPDATE game_model_params
   SET value = 49,
       note = 'Their last outfield defender this far or more off his goal line is a high line. G4.98: the pro median with the passer in his own half (StatsBomb 360, Euro 2020 49.0 / World Cup 2022 50.0 m; was 30, deeper than 9 in 10 pro lines).'
 WHERE owner = 'concept' AND code = 'beat-the-high-line' AND param = 'high_m';

INSERT INTO game_benchmark_metrics (code, label, unit, definition) VALUES
  ('behind_line_passes_per_team_match', 'Passes aimed past their last outfielder, a team a match', 'passes',
   'StatsBomb 360: open-play passes 3 m+ forward ending beyond the deepest outfield opponent in the freeze frame (4+ in view, end in the visible area). Harness: any pass to a mate, 3 m+ forward, aimed past their deepest outfielder at the kick.'),
  ('behind_line_completion_pct', 'Passes past their last outfielder completed', '%', 'As behind_line_passes_per_team_match, reaching a mate.'),
  ('behind_line_lofted_pct', 'Passes past their last outfielder: lofted', '%', 'StatsBomb High Pass; harness: a lofted kick.'),
  ('behind_line_own_half_pct', 'Passes past their last outfielder: from the passer''s own half', '%', 'Struck in the passer''s own half.'),
  ('behind_line_pressed_pct', 'Passes past their last outfielder: passer under pressure', '%', 'StatsBomb under_pressure; harness: an opponent within 2.5 m.'),
  ('behind_line_depth_lt2m_pct', 'Passes past their last outfielder: < 2 m past him', '%', 'How far past the deepest outfield opponent the pass ends (harness: is aimed).'),
  ('behind_line_depth_2_5m_pct', 'Passes past their last outfielder: 2-5 m past him', '%', 'As behind_line_depth_lt2m_pct.'),
  ('behind_line_depth_5_10m_pct', 'Passes past their last outfielder: 5-10 m past him', '%', 'As behind_line_depth_lt2m_pct.'),
  ('behind_line_depth_10m_plus_pct', 'Passes past their last outfielder: 10 m+ past him', '%', 'As behind_line_depth_lt2m_pct.'),
  ('back_line_m_p25_passer_own_half', 'Their back line off its goal, passer in his own half: 25th percentile', 'm', 'StatsBomb 360: the deepest outfield opponent in view (4+ in view).'),
  ('back_line_m_p50_passer_own_half', 'Their back line off its goal, passer in his own half: median', 'm', 'As back_line_m_p25_passer_own_half.'),
  ('back_line_m_p75_passer_own_half', 'Their back line off its goal, passer in his own half: 75th percentile', 'm', 'As back_line_m_p25_passer_own_half.')
ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, unit = EXCLUDED.unit, definition = EXCLUDED.definition;

INSERT INTO game_benchmarks (source_id, level, competition, season, matches, metric, value)
SELECT s.id, 'pro', v.comp, v.season, v.matches, v.metric, v.value
  FROM game_sources s, (VALUES
    ('UEFA Euro', '2020', 51, 'behind_line_passes_per_team_match', 26.69),
    ('UEFA Euro', '2020', 51, 'behind_line_completion_pct', 61.5),
    ('UEFA Euro', '2020', 51, 'behind_line_lofted_pct', 33.9),
    ('UEFA Euro', '2020', 51, 'behind_line_own_half_pct', 28.4),
    ('UEFA Euro', '2020', 51, 'behind_line_pressed_pct', 17.2),
    ('UEFA Euro', '2020', 51, 'behind_line_depth_lt2m_pct', 33.1),
    ('UEFA Euro', '2020', 51, 'behind_line_depth_2_5m_pct', 33.5),
    ('UEFA Euro', '2020', 51, 'behind_line_depth_5_10m_pct', 24.3),
    ('UEFA Euro', '2020', 51, 'behind_line_depth_10m_plus_pct', 9.1),
    ('UEFA Euro', '2020', 51, 'back_line_m_p25_passer_own_half', 39.5),
    ('UEFA Euro', '2020', 51, 'back_line_m_p50_passer_own_half', 49.0),
    ('UEFA Euro', '2020', 51, 'back_line_m_p75_passer_own_half', 60.5),
    ('FIFA World Cup', '2022', 64, 'behind_line_passes_per_team_match', 25.74),
    ('FIFA World Cup', '2022', 64, 'behind_line_completion_pct', 61.6),
    ('FIFA World Cup', '2022', 64, 'behind_line_lofted_pct', 35.6),
    ('FIFA World Cup', '2022', 64, 'behind_line_own_half_pct', 30.8),
    ('FIFA World Cup', '2022', 64, 'behind_line_pressed_pct', 15.4),
    ('FIFA World Cup', '2022', 64, 'behind_line_depth_lt2m_pct', 30.7),
    ('FIFA World Cup', '2022', 64, 'behind_line_depth_2_5m_pct', 34.4),
    ('FIFA World Cup', '2022', 64, 'behind_line_depth_5_10m_pct', 25.3),
    ('FIFA World Cup', '2022', 64, 'behind_line_depth_10m_plus_pct', 9.5),
    ('FIFA World Cup', '2022', 64, 'back_line_m_p25_passer_own_half', 40.1),
    ('FIFA World Cup', '2022', 64, 'back_line_m_p50_passer_own_half', 50.0),
    ('FIFA World Cup', '2022', 64, 'back_line_m_p75_passer_own_half', 61.8)
  ) AS v(comp, season, matches, metric, value)
 WHERE s.code = 'statsbomb-open-data'
ON CONFLICT (source_id, competition, season, metric) DO UPDATE SET value = EXCLUDED.value, matches = EXCLUDED.matches;

COMMIT;
