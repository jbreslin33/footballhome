-- CASA Matches

INSERT INTO casa_matches (casa_division_id, home_team_id, away_team_id, match_date, match_time, venue_id, status, home_score, away_score, casa_match_id)
VALUES
  (NULL, NULL, NULL, '2025-11-09', '20:00:00', NULL, 'completed', 6, 3, '94b4c1b4-8f70-4373-8cdb-f2217950a044'),
  (NULL, NULL, NULL, '2025-11-09', '19:30:00', NULL, 'completed', 1, 3, 'a626ab3c-f16e-47d0-8f62-97e988d205ed'),
  (NULL, NULL, NULL, '2025-11-09', '18:30:00', NULL, 'completed', 1, 2, 'f205f1e1-339e-4552-a5b9-14b6e661811a'),
  (NULL, NULL, NULL, '2025-11-09', '16:45:00', NULL, 'completed', 0, 3, '7d71e9e0-2d66-44a8-a6c8-ba94a77e8d6a'),
  (NULL, NULL, NULL, '2025-11-09', '14:00:00', NULL, 'completed', 1, 2, '804316a8-f57a-4351-878e-a582b8647d46'),
  (NULL, NULL, NULL, '2025-11-07', '01:45:00', NULL, 'completed', 0, 1, '08ac4dd8-3fdd-40bd-b1bf-95302006a543'),
  (NULL, NULL, NULL, '2025-11-07', '00:00:00', NULL, 'completed', 0, 3, 'fc780790-8e02-44fc-855a-cde65a0f24d4'),
  (NULL, NULL, NULL, '2025-11-06', '01:45:00', NULL, 'completed', 3, 0, '547f5b1b-0eda-4659-b1c8-9925dde33a44'),
  (NULL, NULL, NULL, '2025-11-06', '01:00:00', NULL, 'completed', 0, 1, '349116fd-0244-49a9-b863-22e4a612abe0'),
  (NULL, NULL, NULL, '2025-11-02', '20:00:00', NULL, 'completed', 1, 9, 'f1ee6819-519b-40a9-9c60-6e2f0f8eed9b'),
  (NULL, NULL, NULL, '2025-09-07', '16:45:00', NULL, 'completed', 3, 8, 'dc6ccb40-e5c8-4f77-a1f7-e4289e685617'),
  (NULL, NULL, NULL, '2025-09-07', '17:30:00', NULL, 'completed', 0, 2, 'b3300d0f-cb63-4c00-b298-b224c2610317'),
  (NULL, NULL, NULL, '2025-09-07', '18:30:00', NULL, 'completed', 1, 4, 'e74fc9dc-256c-4e3d-9a32-7af13d2e4e7d'),
  (NULL, NULL, NULL, '2025-09-07', '18:30:00', NULL, 'completed', 0, 0, '29856560-a8dc-4787-b7bc-274390ab3b57'),
  (NULL, NULL, NULL, '2025-09-14', '16:30:00', NULL, 'completed', 6, 0, 'c26933ba-949e-446e-9809-01c9ddc7c9eb'),
  (NULL, NULL, NULL, '2025-09-14', '17:00:00', NULL, 'completed', 2, 0, '947e1255-be86-4268-a644-08321f309449'),
  (NULL, NULL, NULL, '2025-09-14', '18:30:00', NULL, 'completed', 2, 2, '9da3c018-7448-468a-8555-63d42c2f1380'),
  (NULL, NULL, NULL, '2025-09-14', '18:45:00', NULL, 'completed', 4, 0, '3e7af5a0-057e-4db5-b787-15f8b5054b01'),
  (NULL, NULL, NULL, '2025-09-21', '15:45:00', NULL, 'completed', 6, 1, 'ed3f1a1c-1d83-4133-ab37-69f9ed8673a7'),
  (NULL, NULL, NULL, '2025-09-21', '15:45:00', NULL, 'completed', 5, 2, 'efc3a3b9-745e-46ad-9182-2cf5c1f1f008')
ON CONFLICT (id) DO UPDATE SET
  casa_division_id = EXCLUDED.casa_division_id,
  home_team_id = EXCLUDED.home_team_id,
  away_team_id = EXCLUDED.away_team_id,
  match_date = EXCLUDED.match_date,
  match_time = EXCLUDED.match_time,
  venue_id = EXCLUDED.venue_id,
  status = EXCLUDED.status,
  home_score = EXCLUDED.home_score,
  away_score = EXCLUDED.away_score,
  casa_match_id = EXCLUDED.casa_match_id
;

