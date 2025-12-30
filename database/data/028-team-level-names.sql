-- Team Level Names - Cosmetic display options (zero business logic impact)
-- Clubs choose their preferred terminology from this list
-- All names at a given level_rank have identical functionality

-- LEVEL 1: First Team Names
INSERT INTO team_level_names (id, team_level_id, name, display_name, description) VALUES
(1, 1, 'first', 'First Team', 'Primary/senior competitive team'),
(2, 1, 'firsts', 'Firsts', 'British plural form'),
(3, 1, 'seniors', 'Seniors', 'Adult/senior team'),
(4, 1, 'premier', 'Premier', 'Top-tier designation')
ON CONFLICT (id) DO NOTHING;

-- LEVEL 2: Reserve/Second Team Names
INSERT INTO team_level_names (id, team_level_id, name, display_name, description) VALUES
(5, 2, 'reserves', 'Reserves', 'Reserve squad'),
(6, 2, 'reserve', 'Reserve', 'Reserve team (singular)'),
(7, 2, 'second', 'Second Team', 'Second team designation'),
(8, 2, 'seconds', 'Seconds', 'British plural form'),
(9, 2, 'ii', 'II', 'Roman numeral second team'),
(10, 2, 'b', 'B Team', 'B team designation')
ON CONFLICT (id) DO NOTHING;

-- LEVEL 3: Third Team Names
INSERT INTO team_level_names (id, team_level_id, name, display_name, description) VALUES
(11, 3, 'third', 'Third Team', 'Third team designation'),
(12, 3, 'thirds', 'Thirds', 'British plural form'),
(13, 3, 'iii', 'III', 'Roman numeral third team'),
(14, 3, 'c', 'C Team', 'C team designation'),
(15, 3, 'academy', 'Academy', 'Academy/development team')
ON CONFLICT (id) DO NOTHING;

-- LEVEL 4: Fourth Team Names
INSERT INTO team_level_names (id, team_level_id, name, display_name, description) VALUES
(16, 4, 'fourth', 'Fourth Team', 'Fourth team designation'),
(17, 4, 'fourths', 'Fourths', 'British plural form'),
(18, 4, 'iv', 'IV', 'Roman numeral fourth team'),
(19, 4, 'd', 'D Team', 'D team designation'),
(20, 4, 'youth', 'Youth', 'Youth development team')
ON CONFLICT (id) DO NOTHING;

-- LEVEL 5: Fifth Team Names
INSERT INTO team_level_names (id, team_level_id, name, display_name, description) VALUES
(21, 5, 'fifth', 'Fifth Team', 'Fifth team designation'),
(22, 5, 'fifths', 'Fifths', 'British plural form'),
(23, 5, 'v', 'V', 'Roman numeral fifth team'),
(24, 5, 'e', 'E Team', 'E team designation'),
(25, 5, 'recreational', 'Recreational', 'Recreational/social team')
ON CONFLICT (id) DO NOTHING;

-- Reset sequence to continue from max id
SELECT setval('team_level_names_id_seq', (SELECT COALESCE(MAX(id), 0) FROM team_level_names));
