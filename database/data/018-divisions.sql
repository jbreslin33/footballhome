-- Divisions  
-- Manual seed data - defines division tiers before scraping teams
-- APSL: Only Division 1 per conference (prevents overlap with feeder leagues)
-- CASA Traditional: Multiple tiers with Spanish names (Primera through Septima)
-- CASA Select: Liga 1/Liga 2 or Division 1/Division 2
-- Generated from: database/config/league-structure.json

INSERT INTO divisions (id, season_id, conference_id, name, skill_level) VALUES
  -- APSL 2025 Season - Each conference has ONLY Division 1
  (1, 1, 1, 'Division 1', 1),   -- Mayflower
  (2, 1, 2, 'Division 1', 1),   -- Constitution
  (3, 1, 3, 'Division 1', 1),   -- Metropolitan
  (4, 1, 4, 'Division 1', 1),   -- Delaware River
  (5, 1, 5, 'Division 1', 1),   -- Mid-Atlantic
  (6, 1, 6, 'Division 1', 1),   -- Terminus
  (7, 1, 7, 'Division 1', 1),   -- Pine Tree (coming soon)
  (8, 1, 8, 'Division 1', 1),   -- Trinity (coming soon)
  
  -- CASA Traditional - Philadelphia (7 divisions)
  (9, 2, 9, 'Primera', 1),
  (10, 2, 9, 'Segunda', 2),
  (11, 2, 9, 'Tercera', 3),
  (12, 2, 9, 'Cuarta', 4),
  (13, 2, 9, 'Quinto', 5),
  (14, 2, 9, 'Sexta', 6),
  (15, 2, 9, 'Septima', 7),
  
  -- CASA Traditional - Boston (5 divisions, D4 split into Azul/Roja)
  (16, 2, 10, 'Primera', 1),
  (17, 2, 10, 'Segunda', 2),
  (18, 2, 10, 'Tercera', 3),
  (19, 2, 10, 'Cuarto Azul', 4),
  (20, 2, 10, 'Cuarta Roja', 4),
  
  -- CASA Select - Philadelphia
  (21, 3, 11, 'Liga 1', 1),
  (22, 3, 11, 'Liga 2', 2),
  
  -- CASA Select - Boston
  (23, 3, 12, 'Liga 1', 1),
  (24, 3, 12, 'Division 2', 2),
  
  -- CASA Select - Lancaster
  (25, 3, 13, 'Liga 1', 1),
  (26, 3, 13, 'Division 2', 2),
  
  -- CASA Select - Central New Jersey
  (27, 3, 14, 'Liga 1', 1),
  (28, 3, 14, 'Division 2', 2),
  
  -- CASA Select - South New Jersey
  (29, 3, 15, 'Division 1', 1),
  (30, 3, 15, 'Division 2', 2),
  
  -- CASA Select - North New Jersey
  (31, 3, 16, 'Division 1', 1),
  (32, 3, 16, 'Division 2', 2)
ON CONFLICT (id) DO UPDATE SET
  season_id = EXCLUDED.season_id,
  conference_id = EXCLUDED.conference_id,
  name = EXCLUDED.name,
  skill_level = EXCLUDED.skill_level;
