-- CASA Teams

INSERT INTO teams (id, club_id, sport_division_id, name, city, logo_url, is_active, source_system_id, external_id)
VALUES
  (1, NULL, 1, 'Persepolis United FC II', NULL, NULL, true, 2, '68b9ec8f562f54017935a21b'),
  (2, NULL, 2, 'Phoenix SCR', NULL, NULL, true, 2, '68b9ec8f562f5400fd35a5dc'),
  (3, NULL, 3, 'Philadelphia SC II', NULL, NULL, true, 2, '68b9ec8fb3eb08013b755a47'),
  (4, NULL, 4, 'Lighthouse Old Timers Club', NULL, NULL, true, 2, '68b9ec8fb3eb0800fd755db8'),
  (5, NULL, 5, 'Club de Futbol Armada', NULL, NULL, true, 2, '68b9ec8f1ff01d00fc20f6d3'),
  (6, NULL, 1, 'Persepolis FC', NULL, NULL, NULL, 2, 'STUB-PersepolisFC'),
  (7, NULL, 6, 'Philly Black Stars', NULL, NULL, NULL, 2, 'STUB-PhillyBlackStars'),
  (8, NULL, 7, 'Oaklyn United Nor’Easters II', NULL, NULL, NULL, 2, 'STUB-OaklynUnitedNorEastersII'),
  (9, NULL, 8, 'Illyrians', NULL, NULL, NULL, 2, 'STUB-Illyrians'),
  (10, NULL, 2, 'Phoenix Majors', NULL, NULL, NULL, 2, 'STUB-PhoenixMajors'),
  (11, NULL, 4, 'Lighthouse Boys Club', NULL, NULL, NULL, 2, 'STUB-LighthouseBoysClub'),
  (12, NULL, 9, 'Ade United FC', NULL, NULL, NULL, 2, 'STUB-AdeUnitedFC')
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

