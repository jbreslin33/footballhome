-- Conferences
-- Conferences belong to seasons and group divisions
-- APSL has multiple conferences per season, CSL has one "Main" conference
-- 
-- This file contains manually-managed conference structures.

-- APSL 2025/2026 Conferences
INSERT INTO conferences (id, season_id, name) VALUES
(1, 1, 'Mayflower Conference'),
(2, 1, 'Constitution Conference'),
(3, 1, 'Metropolitan Conference'),
(4, 1, 'Delaware River Conference'),
(5, 1, 'Mid-Atlantic Conference'),
(6, 1, 'Terminus Conference');

-- APSL 2024/2025 Conferences
INSERT INTO conferences (id, season_id, name) VALUES
(19, 4, 'Mayflower Conference'),
(20, 4, 'Constitution Conference'),
(21, 4, 'Metropolitan Conference'),
(22, 4, 'Delaware River Conference'),
(23, 4, 'Mid-Atlantic Conference');

-- APSL 2023/2024 Conferences
INSERT INTO conferences (id, season_id, name) VALUES
(11, 3, 'Northeast Conference-Fall'),
(12, 3, 'Northeast Conference-Spring'),
(13, 3, 'Metropolitan Conference'),
(14, 3, 'Delaware River Conference'),
(15, 3, 'Mid-Atlantic Conference - Fall'),
(16, 3, 'Mid-Atlantic Conference- Spring'),
(17, 3, 'State Cup'),
(18, 3, 'Mid-Atlantic WL');

-- APSL 2022/2023 Conferences  
INSERT INTO conferences (id, season_id, name) VALUES
(7, 2, 'Northeast Conference-Fall'),
(8, 2, 'Metropolitan Conference'),
(9, 2, 'Delaware River Conference'),
(10, 2, 'Mid-Atlantic Conference - Fall');

-- CSL Conferences (one "Main" conference per season)
INSERT INTO conferences (id, season_id, name) VALUES
(24, 5, 'Main'),   -- 2025/2026
(25, 6, 'Main'),  -- 2022/2023
(26, 7, 'Main'),  -- 2023/2024
(27, 8, 'Main');  -- 2024/2025

-- Update sequence
SELECT setval('conferences_id_seq', (SELECT MAX(id) FROM conferences));
