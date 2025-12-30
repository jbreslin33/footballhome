-- APSL Teams

INSERT INTO teams (id, sport_division_id, name, city, logo_url, source_system_id, external_id)
VALUES
  (1, NULL, 'Lighthouse 1893 SC', NULL, NULL, 1, '116079')
ON CONFLICT (id) DO UPDATE SET
  sport_division_id = EXCLUDED.sport_division_id,
  name = EXCLUDED.name,
  city = EXCLUDED.city,
  logo_url = EXCLUDED.logo_url,
  source_system_id = EXCLUDED.source_system_id,
  external_id = EXCLUDED.external_id
;

