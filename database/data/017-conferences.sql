-- Conferences
-- Manual seed data - defines conference structure before scraping
-- Generated from: database/config/league-structure.json

INSERT INTO conferences (id, season_id, name, abbreviation) VALUES
  -- APSL 2025 Season Conferences
  (1, 1, 'Mayflower Conference', 'Mayflower'),
  (2, 1, 'Constitution Conference', 'Constit.'),
  (3, 1, 'Metropolitan Conference', 'Metro'),
  (4, 1, 'Delaware River Conference', 'Del River'),
  (5, 1, 'Mid-Atlantic Conference', 'Mid-Atl'),
  (6, 1, 'Terminus Conference', 'Terminus'),
  (7, 1, 'Pine Tree Conference', 'Pine Tree'),  -- Coming soon
  (8, 1, 'Trinity Conference', 'Trinity'),  -- Coming soon
  
  -- CASA Traditional Conferences
  (9, 2, 'Philadelphia Traditional', 'Philly'),
  (10, 2, 'Boston Traditional', 'Boston'),
  
  -- CASA Select Conferences
  (11, 3, 'Philadelphia Select', 'Philly'),
  (12, 3, 'Boston Select', 'Boston'),
  (13, 3, 'Lancaster Select', 'Lancaster'),
  (14, 3, 'Central New Jersey Select', 'C-NJ'),
  (15, 3, 'South New Jersey Select', 'S-NJ'),
  (16, 3, 'North New Jersey Select', 'N-NJ')
ON CONFLICT (id) DO UPDATE SET
  season_id = EXCLUDED.season_id,
  name = EXCLUDED.name,
  abbreviation = EXCLUDED.abbreviation;
