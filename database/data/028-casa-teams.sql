-- CASA Teams

INSERT INTO teams (id, sport_division_id, name, city, logo_url, source_system_id, external_id)
VALUES
  (1, 1, 'Adé United FC', NULL, NULL, 2, '68b9e9d8c557f500fc9757a0'),
  (2, 2, 'Oaklyn United FC II', NULL, NULL, 2, '68b9e9d9fa1e910177ec564d'),
  (3, 3, 'Philadelphia Sierra Stars', NULL, NULL, 2, '68b9e9d91ff01d00fc20f616'),
  (4, 4, 'Persepolis FC', NULL, NULL, 2, '69406f99797af1d33f398d2e'),
  (5, 5, 'Phoenix SCM', NULL, NULL, 2, '68b9e9d9b3eb08013b7559cd'),
  (6, 6, 'Philly BlackStars', NULL, NULL, 2, '68b9e9d8b3eb0800fd755c9c'),
  (7, 7, 'Illyrians FC', NULL, NULL, 2, '68b9e9d8fa1e9100fbec60d4'),
  (8, 8, 'Lighthouse Boys Club', NULL, NULL, 2, '68b9e9d81f736301382e6ee1'),
  (9, 5, 'Phoenix Reserves', NULL, NULL, 2, 'STUB-PhoenixReserves'),
  (10, 8, 'Lighthouse Old Timers Club', NULL, NULL, 2, 'STUB-LighthouseOldTimersClub'),
  (11, 3, 'Philadelphia SC II', NULL, NULL, 2, 'STUB-PhiladelphiaSCII'),
  (12, 4, 'Persepolis United FC II', NULL, NULL, 2, '68b9ec8f562f54017935a21b'),
  (13, 5, 'Phoenix SCR', NULL, NULL, 2, '68b9ec8f562f5400fd35a5dc'),
  (14, 3, 'Philadelphia SC II', NULL, NULL, 2, '68b9ec8fb3eb08013b755a47'),
  (15, 8, 'Lighthouse Old Timers Club', NULL, NULL, 2, '68b9ec8fb3eb0800fd755db8'),
  (16, 9, 'Club de Futbol Armada', NULL, NULL, 2, '68b9ec8f1ff01d00fc20f6d3'),
  (17, 2, 'Oaklyn United Nor’Easters II', NULL, NULL, 2, 'STUB-OaklynUnitedNorEastersII'),
  (18, 5, 'Phoenix Majors', NULL, NULL, 2, 'STUB-PhoenixMajors')
ON CONFLICT (id) DO UPDATE SET
  sport_division_id = EXCLUDED.sport_division_id,
  name = EXCLUDED.name,
  city = EXCLUDED.city,
  logo_url = EXCLUDED.logo_url,
  source_system_id = EXCLUDED.source_system_id,
  external_id = EXCLUDED.external_id
;

