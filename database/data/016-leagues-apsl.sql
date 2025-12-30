-- APSL Leagues

INSERT INTO leagues (id, organization_id, name, season, website_url, is_active)
VALUES
  (1, 1, 'APSL', '2025/2026', 'https://apslsoccer.com', true)
ON CONFLICT (id) DO UPDATE SET
  organization_id = EXCLUDED.organization_id,
  name = EXCLUDED.name,
  season = EXCLUDED.season,
  website_url = EXCLUDED.website_url,
  is_active = EXCLUDED.is_active
;

