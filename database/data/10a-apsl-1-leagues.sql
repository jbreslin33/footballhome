-- APSL Leagues

INSERT INTO apsl_leagues (id, name, season, website_url, is_active)
VALUES
  (1, 'APSL', '2025/2026', 'https://apslsoccer.com', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  season = EXCLUDED.season,
  website_url = EXCLUDED.website_url,
  is_active = EXCLUDED.is_active
;

