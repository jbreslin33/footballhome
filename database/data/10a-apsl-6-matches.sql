-- APSL Matches

INSERT INTO matches (id, division_id, home_team_id, away_team_id, match_type_id, match_status_id, match_date, match_time, venue_id, home_score, away_score, source_system_id, external_id)
VALUES
  (1, 4, NULL, 1, 1, 3, '2025-09-07T20:30:00.000Z', NULL, NULL, 2, 3, 1, '2025-09-07T20:30:00.000Z-Lighthouse 1893 SC-Philadelphia Soccer Club'),
  (2, 4, NULL, 1, 1, 3, '2025-09-14T20:00:00.000Z', NULL, NULL, 1, 5, 1, '2025-09-14T20:00:00.000Z-Lighthouse 1893 SC-Medford Strikers'),
  (3, 4, NULL, 1, 1, 3, '2025-09-21T20:00:00.000Z', NULL, NULL, 1, 2, 1, '2025-09-21T20:00:00.000Z-Lighthouse 1893 SC-Real Central NJ Soccer'),
  (4, 4, NULL, 1, 1, 3, '2025-09-28T15:00:00.000Z', NULL, NULL, 1, 0, 1, '2025-09-28T15:00:00.000Z-Lighthouse 1893 SC-Sewell Old Boys FC'),
  (5, 4, NULL, 1, 1, 3, '2025-10-05T19:30:00.000Z', NULL, NULL, 0, 0, 1, '2025-10-05T19:30:00.000Z-Lighthouse 1893 SC-Philadelphia Heritage SC'),
  (6, 4, NULL, 1, 1, 3, '2025-10-12T17:00:00.000Z', NULL, NULL, 2, 1, 1, '2025-10-12T17:00:00.000Z-Lighthouse 1893 SC-Vidas United FC'),
  (7, 4, NULL, 1, 1, 3, '2025-11-09T18:00:00.000Z', NULL, NULL, 1, 2, 1, '2025-11-09T18:00:00.000Z-Lighthouse 1893 SC-Oaklyn United FC'),
  (8, 4, NULL, 1, 1, 3, '2025-11-14T02:00:00.000Z', NULL, NULL, 5, 1, 1, '2025-11-14T02:00:00.000Z-Lighthouse 1893 SC-GAK'),
  (9, 4, NULL, 1, 1, 3, '2025-11-22T23:00:00.000Z', NULL, NULL, 2, 2, 1, '2025-11-22T23:00:00.000Z-Lighthouse 1893 SC-Alloy Soccer Club'),
  (10, 4, NULL, 1, 1, 3, '2025-11-30T23:30:00.000Z', NULL, NULL, 2, 1, 1, '2025-11-30T23:30:00.000Z-Lighthouse 1893 SC-Jersey Shore Boca'),
  (11, 4, NULL, 1, 1, 3, '2025-12-03T01:30:00.000Z', NULL, NULL, 7, 0, 1, '2025-12-03T01:30:00.000Z-Lighthouse 1893 SC-WC Predators')
ON CONFLICT (id) DO UPDATE SET
  division_id = EXCLUDED.division_id,
  home_team_id = EXCLUDED.home_team_id,
  away_team_id = EXCLUDED.away_team_id,
  match_type_id = EXCLUDED.match_type_id,
  match_status_id = EXCLUDED.match_status_id,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  source_system_id = EXCLUDED.source_system_id,
  external_id = EXCLUDED.external_id
;

