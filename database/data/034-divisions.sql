-- Divisions
-- Divisions belong to conferences and seasons
-- Teams are assigned to divisions via the division_teams junction table
-- 
-- This file contains manually-managed division structures for APSL and CSL.

-- ==================================================
-- APSL 2025/2026 Divisions
-- ==================================================
INSERT INTO divisions (id, season_id, conference_id, name, source_system_id, is_active) VALUES
(1, 1, 1, 'Mayflower', 1, true),
(2, 1, 2, 'Constitution', 1, true),
(3, 1, 3, 'Metropolitan', 1, true),
(4, 1, 4, 'Delaware River', 1, true),
(5, 1, 5, 'Mid-Atlantic', 1, true),
(6, 1, 6, 'Terminus', 1, true);

-- ==================================================
-- CSL 2025/2026 Divisions (season_id=5, conference_id=24)
-- ==================================================
INSERT INTO divisions (id, season_id, conference_id, name, source_system_id, sort_order, is_active) VALUES
(24, 5, 24, 'Division 1', 3, 1, true),
(25, 5, 24, 'Division 1 Reserve', 3, 2, true),
(26, 5, 24, 'Division 2', 3, 3, true),
(27, 5, 24, 'Division 2 Reserve', 3, 4, true),
(28, 5, 24, 'Division 3', 3, 5, true),
(29, 5, 24, 'Division 4', 3, 6, true),
(30, 5, 24, 'Over-40 Division', 3, 7, true);

-- ==================================================
-- CSL 2022/2023 Divisions (season_id=6, conference_id=25)
-- ==================================================
INSERT INTO divisions (id, season_id, conference_id, name, source_system_id, sort_order, is_active) VALUES
(31, 6, 25, 'Division 1', 3, 1, false),
(32, 6, 25, 'Division 1 Reserve', 3, 2, false),
(33, 6, 25, 'Division 2', 3, 3, false),
(34, 6, 25, 'Division 2 Reserve', 3, 4, false),
(35, 6, 25, 'Division 3', 3, 5, false),
(36, 6, 25, 'Division 4', 3, 6, false),
(37, 6, 25, 'Spring Division', 3, 7, false),
(38, 6, 25, 'Over-40 Division', 3, 8, false);

-- ==================================================
-- CSL 2023/2024 Divisions (season_id=7, conference_id=26)
-- ==================================================
INSERT INTO divisions (id, season_id, conference_id, name, source_system_id, sort_order, is_active) VALUES
(39, 7, 26, 'Division 1', 3, 1, false),
(40, 7, 26, 'Division 1 Reserve', 3, 2, false),
(41, 7, 26, 'Division 2', 3, 3, false),
(42, 7, 26, 'Division 2 Reserve', 3, 4, false),
(43, 7, 26, 'Division 3', 3, 5, false),
(44, 7, 26, 'Division 4', 3, 6, false),
(45, 7, 26, 'Spring Division', 3, 7, false),
(46, 7, 26, 'Over-40 Division', 3, 8, false);

-- ==================================================
-- CSL 2024/2025 Divisions (season_id=8, conference_id=27)
-- ==================================================
INSERT INTO divisions (id, season_id, conference_id, name, source_system_id, sort_order, is_active) VALUES
(47, 8, 27, 'Division 1', 3, 1, false),
(48, 8, 27, 'Division 1 Reserve', 3, 2, false),
(49, 8, 27, 'Division 2', 3, 3, false),
(50, 8, 27, 'Division 2 Reserve', 3, 4, false),
(51, 8, 27, 'Division 3', 3, 5, false),
(52, 8, 27, 'Division 4', 3, 6, false),
(53, 8, 27, 'Over-40 Division', 3, 7, false);

-- Update sequence
SELECT setval('divisions_id_seq', (SELECT MAX(id) FROM divisions));
