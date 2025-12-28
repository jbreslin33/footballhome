-- CASA Leagues

INSERT INTO casa_leagues (id, name, season, website_url)
VALUES
  (1, 'CASA Soccer League', '2024-2025', 'https://www.casasoccerleagues.com')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  season = EXCLUDED.season,
  website_url = EXCLUDED.website_url
;

