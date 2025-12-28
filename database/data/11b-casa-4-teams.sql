-- CASA Teams

INSERT INTO casa_teams (id, casa_division_id, name, city, logo_url, casa_team_id)
VALUES
  (1, 1, 'Lighthouse Boys Club', NULL, NULL, '68b9e9d81f736301382e6ee1'),
  (2, 2, 'Lighthouse Old Timers Club', NULL, NULL, '68b9ec8fb3eb0800fd755db8')
ON CONFLICT (id) DO UPDATE SET
  casa_division_id = EXCLUDED.casa_division_id,
  name = EXCLUDED.name,
  city = EXCLUDED.city,
  logo_url = EXCLUDED.logo_url,
  casa_team_id = EXCLUDED.casa_team_id
;

