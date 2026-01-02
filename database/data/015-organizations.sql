-- Organizations (Parent entities for leagues)
-- Manual seed data - defines organizations before scraping their teams
-- Generated from: database/config/league-structure.json

INSERT INTO organizations (id, name, short_name, website_url, governing_body_id) VALUES
  -- APSL reports to USASA (id=200)
  (1, 'American Premier Soccer League', 'APSL', 'https://apslsoccer.com', 200),
  
  -- CASA reports to EPSA (id=300) 
  (2, 'CASA Soccer Leagues', 'CASA', 'https://casasoccerleagues.com', 300)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  short_name = EXCLUDED.short_name,
  website_url = EXCLUDED.website_url,
  governing_body_id = EXCLUDED.governing_body_id;
