-- CASA Teams

INSERT INTO casa_teams (id, casa_division_id, name, city, logo_url, casa_team_id)
VALUES
  (1, 1, 'Adé United FC', NULL, NULL, '68b9e9d8c557f500fc9757a0'),
  (2, 1, 'Oaklyn United FC II', NULL, NULL, '68b9e9d9fa1e910177ec564d'),
  (3, 1, 'Philadelphia Sierra Stars', NULL, NULL, '68b9e9d91ff01d00fc20f616'),
  (4, 1, 'Persepolis FC', NULL, NULL, '69406f99797af1d33f398d2e'),
  (5, 1, 'Phoenix SCM', NULL, NULL, '68b9e9d9b3eb08013b7559cd'),
  (6, 1, 'Philly BlackStars', NULL, NULL, '68b9e9d8b3eb0800fd755c9c'),
  (7, 1, 'Illyrians FC', NULL, NULL, '68b9e9d8fa1e9100fbec60d4'),
  (8, 1, 'Lighthouse Boys Club', NULL, NULL, '68b9e9d81f736301382e6ee1')
ON CONFLICT (id) DO UPDATE SET
  casa_division_id = EXCLUDED.casa_division_id,
  name = EXCLUDED.name,
  city = EXCLUDED.city,
  logo_url = EXCLUDED.logo_url,
  casa_team_id = EXCLUDED.casa_team_id
;

