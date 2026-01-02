-- Leagues
-- Manual seed data - defines leagues before scraping their teams
-- Generated from: database/config/league-structure.json

INSERT INTO leagues (id, organization_id, name, season, age_calculation_method_id) VALUES
  (1, 1, 'APSL 2025 Season', '2025', 1),
  (2, 2, 'CASA Traditional 2024-2025 Season', '2024-2025', 1),
  (3, 2, 'CASA Select 2024-2025 Season', '2024-2025', 1)
ON CONFLICT (id) DO UPDATE SET
  organization_id = EXCLUDED.organization_id,
  name = EXCLUDED.name,
  season = EXCLUDED.season,
  age_calculation_method_id = EXCLUDED.age_calculation_method_id;
