-- ========================================
-- CASA TEAMS
-- ========================================
-- Generated: 2025-12-12T14:54:10.781Z
-- Source: CASA Website
-- ========================================

INSERT INTO teams (id, name, division_id, league_division_id, season, is_active)
VALUES ('04b164cd-4e35-4302-84b0-60e2a5e71500', 'Lighthouse Boys Club', '7edd10c4-c7d4-447a-8446-595226c325b8', 'ad505cc1-202e-47be-8bb1-27f0f42857cf', '2024-2025', true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO teams (id, name, division_id, league_division_id, season, is_active)
VALUES ('449ef257-2d8f-43c0-8ae1-6374894d17f1', 'Lighthouse Old Timers', '0915072e-e2c9-46fe-81f0-8da72c286a4b', '2ec1c004-1dc2-4384-8679-4de64e9add18', '2024-2025', true)
ON CONFLICT (id) DO NOTHING;
