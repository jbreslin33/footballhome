-- APSL Divisions

INSERT INTO apsl_divisions (id, apsl_id, name, season, league_division_id)
VALUES
  ('fb5cafed-3a22-48ca-824c-894a9ad623f4', 'Mayflower Conference', 'Mayflower Conference', '2025/2026', NULL),
  ('18541bb9-0c7e-40ee-86ea-c52fb67da02a', 'Constitution Conference', 'Constitution Conference', '2025/2026', NULL),
  ('913ab99a-cd6d-4186-8278-916506f6f119', 'Metropolitan Conference', 'Metropolitan Conference', '2025/2026', NULL),
  ('c85936a7-3ca5-4c01-8356-8f916d25cd73', 'Delaware River Conference', 'Delaware River Conference', '2025/2026', NULL),
  ('606f565e-deb2-41f5-83b4-e136a7ce41e0', 'Mid-Atlantic Conference', 'Mid-Atlantic Conference', '2025/2026', NULL),
  ('d4319cf2-f454-423c-8d45-426b69846253', 'Terminus Conference', 'Terminus Conference', '2025/2026', NULL)
ON CONFLICT (id) DO UPDATE SET
  apsl_id = EXCLUDED.apsl_id,
  name = EXCLUDED.name,
  season = EXCLUDED.season,
  league_division_id = EXCLUDED.league_division_id
;

