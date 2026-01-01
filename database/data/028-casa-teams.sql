-- CASA Teams

INSERT INTO teams (id, club_id, sport_division_id, name, city, logo_url, is_active, source_system_id, external_id)
VALUES
  (1, NULL, 53, 'Adé United FC', NULL, NULL, true, 2, '68b9e9d8c557f500fc9757a0'),
  (2, NULL, 27, 'Oaklyn United FC II', NULL, NULL, true, 2, '68b9e9d9fa1e910177ec564d'),
  (3, NULL, 29, 'Philadelphia Sierra Stars', NULL, NULL, true, 2, '68b9e9d91ff01d00fc20f616'),
  (4, NULL, 54, 'Persepolis FC', NULL, NULL, true, 2, '69406f99797af1d33f398d2e'),
  (5, NULL, 55, 'Phoenix SCM', NULL, NULL, true, 2, '68b9e9d9b3eb08013b7559cd'),
  (6, NULL, 56, 'Philly BlackStars', NULL, NULL, true, 2, '68b9e9d8b3eb0800fd755c9c'),
  (7, NULL, 57, 'Illyrians FC', NULL, NULL, true, 2, '68b9e9d8fa1e9100fbec60d4'),
  (8, NULL, 33, 'Lighthouse Boys Club', NULL, NULL, true, 2, '68b9e9d81f736301382e6ee1'),
  (9, NULL, 54, 'Persepolis United FC II', NULL, NULL, true, 2, '68b9ec8f562f54017935a21b'),
  (10, NULL, 55, 'Phoenix SCR', NULL, NULL, true, 2, '68b9ec8f562f5400fd35a5dc'),
  (11, NULL, 30, 'Philadelphia SC II', NULL, NULL, true, 2, '68b9ec8fb3eb08013b755a47'),
  (12, NULL, 33, 'Lighthouse Old Timers Club', NULL, NULL, true, 2, '68b9ec8fb3eb0800fd755db8'),
  (13, NULL, 58, 'Club de Futbol Armada', NULL, NULL, true, 2, '68b9ec8f1ff01d00fc20f6d3')
ON CONFLICT (id) DO UPDATE SET
  club_id = EXCLUDED.club_id,
  sport_division_id = EXCLUDED.sport_division_id,
  name = EXCLUDED.name,
  city = EXCLUDED.city,
  logo_url = EXCLUDED.logo_url,
  is_active = EXCLUDED.is_active,
  source_system_id = EXCLUDED.source_system_id,
  external_id = EXCLUDED.external_id
;

