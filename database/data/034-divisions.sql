-- Divisions
-- Divisions belong to conferences and seasons
-- Teams are assigned to divisions via the division_teams junction table
-- 
-- This file contains manually-managed division structures for APSL and CSL.

-- ==================================================
-- APSL 2025/2026 Divisions
-- ==================================================
INSERT INTO divisions (id, season_id, conference_id, name, source_system_id) VALUES
(1, 1, 1, 'Mayflower', 1),
(2, 1, 2, 'Constitution', 1),
(3, 1, 3, 'Metropolitan', 1),
(4, 1, 4, 'Delaware River', 1),
(5, 1, 5, 'Mid-Atlantic', 1),
(6, 1, 6, 'Terminus', 1);

-- ==================================================
-- CSL 2025/2026 Divisions (season_id=5, conference_id=24)
-- ==================================================
INSERT INTO divisions (id, season_id, conference_id, name, source_system_id, sort_order) VALUES
(24, 5, 24, 'Division 1', 3, 1),
(25, 5, 24, 'Division 1 Reserve', 3, 2),
(26, 5, 24, 'Division 2', 3, 3),
(27, 5, 24, 'Division 2 Reserve', 3, 4),
(28, 5, 24, 'Division 3', 3, 5),
(29, 5, 24, 'Division 4', 3, 6),
(30, 5, 24, 'Over-40 Division', 3, 7);

-- ==================================================
-- CSL 2022/2023 Divisions (season_id=6, conference_id=25)
-- ==================================================
INSERT INTO divisions (id, season_id, conference_id, name, source_system_id, sort_order) VALUES
(31, 6, 25, 'Division 1', 3, 1),
(32, 6, 25, 'Division 1 Reserve', 3, 2),
(33, 6, 25, 'Division 2', 3, 3),
(34, 6, 25, 'Division 2 Reserve', 3, 4),
(35, 6, 25, 'Division 3', 3, 5),
(36, 6, 25, 'Division 4', 3, 6),
(37, 6, 25, 'Spring Division', 3, 7),
(38, 6, 25, 'Over-40 Division', 3, 8);

-- ==================================================
-- CSL 2023/2024 Divisions (season_id=7, conference_id=26)
-- ==================================================
INSERT INTO divisions (id, season_id, conference_id, name, source_system_id, sort_order) VALUES
(39, 7, 26, 'Division 1', 3, 1),
(40, 7, 26, 'Division 1 Reserve', 3, 2),
(41, 7, 26, 'Division 2', 3, 3),
(42, 7, 26, 'Division 2 Reserve', 3, 4),
(43, 7, 26, 'Division 3', 3, 5),
(44, 7, 26, 'Division 4', 3, 6),
(45, 7, 26, 'Spring Division', 3, 7),
(46, 7, 26, 'Over-40 Division', 3, 8);

-- ==================================================
-- CSL 2024/2025 Divisions (season_id=8, conference_id=27)
-- ==================================================
INSERT INTO divisions (id, season_id, conference_id, name, source_system_id, sort_order) VALUES
(47, 8, 27, 'Division 1', 3, 1),
(48, 8, 27, 'Division 1 Reserve', 3, 2),
(49, 8, 27, 'Division 2', 3, 3),
(50, 8, 27, 'Division 2 Reserve', 3, 4),
(51, 8, 27, 'Division 3', 3, 5),
(52, 8, 27, 'Division 4', 3, 6),
(53, 8, 27, 'Over-40 Division', 3, 7);

-- Update sequence
SELECT setval('divisions_id_seq', (SELECT MAX(id) FROM divisions));
