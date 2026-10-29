-- 841 (2026-10-29) — game: the control touch, and the pro's time on the
-- ball (G4.92, game/DESIGN.md §8.91).
--
-- James 10/29: "1 then move to all" (possession churn first). The game
-- passed 0.32 s after taking the ball, 89% inside a second; Premier League
-- 2015/16 (StatsBomb Open Data, 380 matches; Ball Receipt → the same
-- player's next open-play Pass, same possession) 1.47 s, 46% inside a
-- second. A ball stopped dead the instant he took it and he kicked it the
-- next tick. Now he can't play it until his control touch settles it: his
-- level's control_settle_ms (core::levelParams, FH estimates: semipro 400
-- ms) + 25 ms per m/s it arrived at, scaled by his first_touch below.

BEGIN;

INSERT INTO game_benchmark_metrics (code, label, unit, definition) VALUES
  ('time_on_ball_s', 'Time on the ball before a pass', 's',
   'StatsBomb: Ball Receipt to the same player''s next open-play Pass in the same possession (carries between count). Harness: from his first touch of it to the kick of a pass to a mate.'),
  ('time_on_ball_lt1s_pct', 'Passes played inside 1 s of receiving', '%', 'As time_on_ball_s, under 1 s.'),
  ('time_on_ball_1_2s_pct', 'Passes played 1-2 s after receiving', '%', 'As time_on_ball_s, 1-2 s.'),
  ('time_on_ball_2_4s_pct', 'Passes played 2-4 s after receiving', '%', 'As time_on_ball_s, 2-4 s.'),
  ('time_on_ball_4s_plus_pct', 'Passes played 4 s+ after receiving', '%', 'As time_on_ball_s, 4 s or more.')
ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, unit = EXCLUDED.unit, definition = EXCLUDED.definition;

INSERT INTO game_benchmarks (source_id, level, competition, season, matches, metric, value)
SELECT s.id, 'pro', 'Premier League', '2015/2016', 380, v.metric, v.value
  FROM game_sources s, (VALUES
    ('time_on_ball_s', 1.47),
    ('time_on_ball_lt1s_pct', 46.2),
    ('time_on_ball_1_2s_pct', 27.6),
    ('time_on_ball_2_4s_pct', 18.8),
    ('time_on_ball_4s_plus_pct', 7.4)
  ) AS v(metric, value)
 WHERE s.code = 'statsbomb-open-data'
ON CONFLICT (source_id, competition, season, metric) DO UPDATE SET value = EXCLUDED.value, matches = EXCLUDED.matches;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
  ('skill', 'first_touch', 'settle_at0_pct', 150::numeric, '%',
   'G4.92: his control touch takes this share of his level''s settle time at first_touch 0 (x1 at 50). [FH] estimate.'),
  ('skill', 'first_touch', 'settle_at100_pct', 50, '%', 'At 100.')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);

UPDATE game_attributes
   SET scales = scales || '; G4.92 control touch: x1.5 at 0 … x1 at 50 … x0.5 at 100 of his level''s settle time'
 WHERE code = 'first_touch' AND scales NOT LIKE '%G4.92%';

COMMIT;
