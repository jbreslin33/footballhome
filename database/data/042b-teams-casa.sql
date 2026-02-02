-- CASA Select Teams (2025/2026 Season)
-- Generated: 2026-02-02
-- Source: Standings pages from casasoccerleagues.com
-- Teams parsed: 25

INSERT INTO teams (name, source_system_id) VALUES ('Adé United FC', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('Alloy Soccer Club Reserves', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('BCFC All Stars', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('Club de Futbol Armada', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('F&M FC', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('Flatley FC', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('Gambeta FC', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('Illyrians FC', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('Jaguars United FC', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('Keystone Elite', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('Kutztown Men''s Soccer', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('Lancaster City FC', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('Lighthouse Boys Club', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('Lighthouse Old Timers Club', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('Oaklyn United FC II', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('Persepolis FC', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('Persepolis United FC II', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('Philadelphia SC II', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('Philadelphia Sierra Stars', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('Philly BlackStars', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('Phoenix SCM', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('Phoenix SCR', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('South Shore FC', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('Strictly Nos Fc', 2) ON CONFLICT (source_system_id, name) DO NOTHING;
INSERT INTO teams (name, source_system_id) VALUES ('Teams', 2) ON CONFLICT (source_system_id, name) DO NOTHING;

-- Update sequence
SELECT setval('teams_id_seq', (SELECT COALESCE(MAX(id), 0) FROM teams));
