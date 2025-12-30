-- Organizations (Parent entities for leagues)
-- Linked to governing bodies hierarchy

INSERT INTO organizations (id, name, short_name, website_url, governing_body_id, affiliation, description, is_active)
VALUES
  -- APSL is affiliated directly with USASA (id=200)
  (1, 'American Premier Soccer League', 'APSL', 'https://www.apslsoccer.com', 200, 'USASA', 'US Soccer affiliated adult amateur league with promotion/relegation system', true),
  -- CASA is affiliated with EPSA (id=300)
  (2, 'CASA Soccer', 'CASA', 'https://www.casasoccerleagues.com', 300, 'EPSA', 'Community soccer organization running both US Soccer affiliated (Select) and unaffiliated (Traditional) leagues', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  short_name = EXCLUDED.short_name,
  website_url = EXCLUDED.website_url,
  governing_body_id = EXCLUDED.governing_body_id,
  affiliation = EXCLUDED.affiliation,
  description = EXCLUDED.description,
  is_active = EXCLUDED.is_active
;
