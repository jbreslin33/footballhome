-- 923 (2026-10-31) — game: pro reference numbers from TRACKING data.
--
-- James 10/31: "ok lets do your recommendation" (free data first, no Opta).
-- The StatsBomb rows see the ball; these see the other 21: team shape, the
-- room on the ball, the mates he can find, the running. Measured by
-- game/scripts/benchmarks_tracking.py, definitions in its header.
--
-- Sources: Bassek, Rein, Weber & Memmert (2025), figshare, doi
-- 10.6084/m9.figshare.28196177, CC BY, data owner DFL: 2 Bundesliga and 5
-- 2. Bundesliga matches of 2022/23, optical, every player always tracked.
-- SkillCorner Open Data, MIT: 20 A-League 2024/25 matches, broadcast; about
-- 64% of player positions were seen, the rest extrapolated, so it carries no
-- physical rows and any gap to the DFL rows may be the camera.
--
-- Read with care: these are small samples and the per-match ranges overlap.
-- They are NOT a ladder. 2. Bundesliga is not worse than Bundesliga on these
-- measures, so no pro-to-semi-pro offset may be derived from them.
--
-- fh-game-match prints a row only once the harness measures that metric, so
-- nothing changes in its output until then. Metric codes are new.

BEGIN;

INSERT INTO game_sources (code, kind, title, url, verified) VALUES
  ('dfl-idsse-open-data', 'analysis', 'Bassek, Rein, Weber & Memmert (2025), integrated tracking and event dataset, data owner DFL (CC BY)', 'https://doi.org/10.6084/m9.figshare.28196177', true),
  ('skillcorner-open-data', 'analysis', 'SkillCorner Open Data, broadcast tracking (MIT)', 'https://github.com/SkillCorner/opendata', true)
ON CONFLICT DO NOTHING;

INSERT INTO game_benchmark_metrics (code, label, unit, definition) VALUES
  ('team_length_in_possession_m', 'Team length in possession', 'm', 'Outfielders, deepest to highest, ball in play.'),
  ('team_length_out_of_possession_m', 'Team length out of possession', 'm', 'Outfielders, deepest to highest, ball in play.'),
  ('team_width_in_possession_m', 'Team width in possession', 'm', 'Outfielders, touchline to touchline, ball in play.'),
  ('team_width_out_of_possession_m', 'Team width out of possession', 'm', 'Outfielders, touchline to touchline, ball in play.'),
  ('line_height_m', 'Back line height', 'm', 'The defending team''s deepest outfielder, metres from their own goal line.'),
  ('line_height_ball_own_third_m', 'Back line height, ball in their own third', 'm', 'line_height_m with the ball in the defenders'' own third.'),
  ('line_height_ball_middle_third_m', 'Back line height, ball in the middle third', 'm', 'line_height_m with the ball in the middle third.'),
  ('line_height_ball_far_third_m', 'Back line height, ball in the far third', 'm', 'line_height_m with the ball in the third they attack.'),
  ('carrier_nearest_opponent_m', 'Room on the ball (median)', 'm', 'Man on the ball: possession team''s nearest to the ball, within 1.5 m, ball under 8 m/s, held 0.4 s. Metres to the nearest opponent, median.'),
  ('carrier_nearest_opponent_lt2m_pct', 'Man on the ball, opponent under 2 m', '%', 'Share of man-on-the-ball samples.'),
  ('carrier_nearest_opponent_2_5m_pct', 'Man on the ball, opponent 2-5 m', '%', 'Share of man-on-the-ball samples.'),
  ('carrier_nearest_opponent_5_10m_pct', 'Man on the ball, opponent 5-10 m', '%', 'Share of man-on-the-ball samples.'),
  ('carrier_nearest_opponent_10m_plus_pct', 'Man on the ball, opponent 10 m+', '%', 'Share of man-on-the-ball samples.'),
  ('reception_nearest_opponent_m', 'Room at the reception (median)', 'm', 'A new man on the ball from the same team within 3 s of the last: metres to the nearest opponent at his first sample, median.'),
  ('reception_nearest_opponent_lt2m_pct', 'Receptions, opponent under 2 m', '%', 'Share of receptions.'),
  ('reception_nearest_opponent_2_5m_pct', 'Receptions, opponent 2-5 m', '%', 'Share of receptions.'),
  ('reception_nearest_opponent_5m_plus_pct', 'Receptions, opponent 5 m+', '%', 'Share of receptions.'),
  ('open_mates_per_carrier', 'Mates he can find', 'mates', 'Outfield mates 5-30 m from the man on the ball, 3 m+ from any opponent, no opponent within 2 m of the straight line to him. Mean over man-on-the-ball samples. FH original.'),
  ('distance_km_per_90', 'Distance an outfielder per 90', 'km', 'Outfielders, per 90 played, whole match, dead time included.'),
  ('high_speed_m_per_90', 'High-speed running an outfielder per 90', 'm', 'Distance at 19.8-25.2 km/h, per 90 played.'),
  ('sprint_m_per_90', 'Sprint distance an outfielder per 90', 'm', 'Distance at 25.2 km/h or faster, per 90 played.'),
  ('sprints_per_90', 'Sprints an outfielder per 90', 'sprints', 'Spells at 25.2 km/h or faster held 1 s, per 90 played.')
ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, unit = EXCLUDED.unit, definition = EXCLUDED.definition;

INSERT INTO game_benchmarks (source_id, level, competition, season, matches, metric, value)
SELECT s.id, 'pro', v.comp, v.season, v.matches, v.metric, v.value
  FROM game_sources s, (VALUES
    ('2. Bundesliga', '2022/2023', 5, 'team_length_in_possession_m', 35.89),
    ('2. Bundesliga', '2022/2023', 5, 'team_length_out_of_possession_m', 32.88),
    ('2. Bundesliga', '2022/2023', 5, 'team_width_in_possession_m', 47.0),
    ('2. Bundesliga', '2022/2023', 5, 'team_width_out_of_possession_m', 37.2),
    ('2. Bundesliga', '2022/2023', 5, 'line_height_m', 33.87),
    ('2. Bundesliga', '2022/2023', 5, 'line_height_ball_own_third_m', 14.89),
    ('2. Bundesliga', '2022/2023', 5, 'line_height_ball_middle_third_m', 32.97),
    ('2. Bundesliga', '2022/2023', 5, 'line_height_ball_far_third_m', 46.17),
    ('2. Bundesliga', '2022/2023', 5, 'carrier_nearest_opponent_m', 5.29),
    ('2. Bundesliga', '2022/2023', 5, 'carrier_nearest_opponent_lt2m_pct', 17.86),
    ('2. Bundesliga', '2022/2023', 5, 'carrier_nearest_opponent_2_5m_pct', 30.64),
    ('2. Bundesliga', '2022/2023', 5, 'carrier_nearest_opponent_5_10m_pct', 27.83),
    ('2. Bundesliga', '2022/2023', 5, 'carrier_nearest_opponent_10m_plus_pct', 23.68),
    ('2. Bundesliga', '2022/2023', 5, 'reception_nearest_opponent_m', 6.97),
    ('2. Bundesliga', '2022/2023', 5, 'reception_nearest_opponent_lt2m_pct', 10.08),
    ('2. Bundesliga', '2022/2023', 5, 'reception_nearest_opponent_2_5m_pct', 24.2),
    ('2. Bundesliga', '2022/2023', 5, 'reception_nearest_opponent_5m_plus_pct', 65.71),
    ('2. Bundesliga', '2022/2023', 5, 'open_mates_per_carrier', 2.33),
    ('2. Bundesliga', '2022/2023', 5, 'distance_km_per_90', 10.35),
    ('2. Bundesliga', '2022/2023', 5, 'high_speed_m_per_90', 679.81),
    ('2. Bundesliga', '2022/2023', 5, 'sprint_m_per_90', 182.32),
    ('2. Bundesliga', '2022/2023', 5, 'sprints_per_90', 8.91),
    ('Bundesliga', '2022/2023', 2, 'team_length_in_possession_m', 34.67),
    ('Bundesliga', '2022/2023', 2, 'team_length_out_of_possession_m', 32.39),
    ('Bundesliga', '2022/2023', 2, 'team_width_in_possession_m', 42.5),
    ('Bundesliga', '2022/2023', 2, 'team_width_out_of_possession_m', 35.38),
    ('Bundesliga', '2022/2023', 2, 'line_height_m', 33.98),
    ('Bundesliga', '2022/2023', 2, 'line_height_ball_own_third_m', 14.9),
    ('Bundesliga', '2022/2023', 2, 'line_height_ball_middle_third_m', 33.72),
    ('Bundesliga', '2022/2023', 2, 'line_height_ball_far_third_m', 47.74),
    ('Bundesliga', '2022/2023', 2, 'carrier_nearest_opponent_m', 4.39),
    ('Bundesliga', '2022/2023', 2, 'carrier_nearest_opponent_lt2m_pct', 22.25),
    ('Bundesliga', '2022/2023', 2, 'carrier_nearest_opponent_2_5m_pct', 32.74),
    ('Bundesliga', '2022/2023', 2, 'carrier_nearest_opponent_5_10m_pct', 26.76),
    ('Bundesliga', '2022/2023', 2, 'carrier_nearest_opponent_10m_plus_pct', 18.25),
    ('Bundesliga', '2022/2023', 2, 'reception_nearest_opponent_m', 5.92),
    ('Bundesliga', '2022/2023', 2, 'reception_nearest_opponent_lt2m_pct', 13.45),
    ('Bundesliga', '2022/2023', 2, 'reception_nearest_opponent_2_5m_pct', 28.23),
    ('Bundesliga', '2022/2023', 2, 'reception_nearest_opponent_5m_plus_pct', 58.32),
    ('Bundesliga', '2022/2023', 2, 'open_mates_per_carrier', 2.11),
    ('Bundesliga', '2022/2023', 2, 'distance_km_per_90', 9.82),
    ('Bundesliga', '2022/2023', 2, 'high_speed_m_per_90', 597.21),
    ('Bundesliga', '2022/2023', 2, 'sprint_m_per_90', 187.49),
    ('Bundesliga', '2022/2023', 2, 'sprints_per_90', 9.47)
  ) AS v(comp, season, matches, metric, value)
 WHERE s.code = 'dfl-idsse-open-data'
ON CONFLICT DO NOTHING;

INSERT INTO game_benchmarks (source_id, level, competition, season, matches, metric, value)
SELECT s.id, 'pro', v.comp, v.season, v.matches, v.metric, v.value
  FROM game_sources s, (VALUES
    ('A-League', '2024/2025', 20, 'team_length_in_possession_m', 33.99),
    ('A-League', '2024/2025', 20, 'team_length_out_of_possession_m', 29.56),
    ('A-League', '2024/2025', 20, 'team_width_in_possession_m', 45.0),
    ('A-League', '2024/2025', 20, 'team_width_out_of_possession_m', 35.43),
    ('A-League', '2024/2025', 20, 'line_height_m', 32.6),
    ('A-League', '2024/2025', 20, 'line_height_ball_own_third_m', 14.16),
    ('A-League', '2024/2025', 20, 'line_height_ball_middle_third_m', 33.31),
    ('A-League', '2024/2025', 20, 'line_height_ball_far_third_m', 48.76),
    ('A-League', '2024/2025', 20, 'carrier_nearest_opponent_m', 4.8),
    ('A-League', '2024/2025', 20, 'carrier_nearest_opponent_lt2m_pct', 19.97),
    ('A-League', '2024/2025', 20, 'carrier_nearest_opponent_2_5m_pct', 32.0),
    ('A-League', '2024/2025', 20, 'carrier_nearest_opponent_5_10m_pct', 30.65),
    ('A-League', '2024/2025', 20, 'carrier_nearest_opponent_10m_plus_pct', 17.38),
    ('A-League', '2024/2025', 20, 'reception_nearest_opponent_m', 6.16),
    ('A-League', '2024/2025', 20, 'reception_nearest_opponent_lt2m_pct', 12.47),
    ('A-League', '2024/2025', 20, 'reception_nearest_opponent_2_5m_pct', 27.24),
    ('A-League', '2024/2025', 20, 'reception_nearest_opponent_5m_plus_pct', 60.29),
    ('A-League', '2024/2025', 20, 'open_mates_per_carrier', 2.32)
  ) AS v(comp, season, matches, metric, value)
 WHERE s.code = 'skillcorner-open-data'
ON CONFLICT DO NOTHING;

COMMIT;
