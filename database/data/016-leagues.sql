-- Leagues (persistent competitions)
-- Manual seed data - defines leagues before scraping their teams
-- Generated from: database/config/league-structure.json

INSERT INTO leagues (id, organization_id, name, age_calculation_method_id) VALUES
  (1, 1, 'APSL Premier League', 1),
  (2, 2, 'CASA Traditional', 1),
  (3, 2, 'CASA Select', 1)
ON CONFLICT (id) DO UPDATE SET
  organization_id = EXCLUDED.organization_id,
  name = EXCLUDED.name,
  age_calculation_method_id = EXCLUDED.age_calculation_method_id;

-- Seasons (time-bounded competitions within leagues)
INSERT INTO seasons (id, league_id, name, start_date, end_date, is_active) VALUES
  (1, 1, '2025', '2025-01-01', '2025-12-31', true),
  (2, 2, '2024-2025', '2024-09-01', '2025-05-31', true),
  (3, 3, '2024-2025', '2024-09-01', '2025-05-31', true)
ON CONFLICT (id) DO UPDATE SET
  league_id = EXCLUDED.league_id,
  name = EXCLUDED.name,
  start_date = EXCLUDED.start_date,
  end_date = EXCLUDED.end_date,
  is_active = EXCLUDED.is_active;
