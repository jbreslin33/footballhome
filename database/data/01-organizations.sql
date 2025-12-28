-- Organizations (Parent entities for leagues)

INSERT INTO organizations (id, name, short_name, website_url, affiliation, description, is_active)
VALUES
  (1, 'Amateur Premier Soccer League', 'APSL', 'https://www.apslsoccer.com', 'US Soccer', 'US Soccer affiliated adult amateur league with promotion/relegation system', true),
  (2, 'CASA Soccer', 'CASA', 'https://www.casasoccerleagues.com', 'Mixed', 'Community soccer organization running both US Soccer affiliated (Select) and unaffiliated (Traditional) leagues', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  short_name = EXCLUDED.short_name,
  website_url = EXCLUDED.website_url,
  affiliation = EXCLUDED.affiliation,
  description = EXCLUDED.description,
  is_active = EXCLUDED.is_active
;
