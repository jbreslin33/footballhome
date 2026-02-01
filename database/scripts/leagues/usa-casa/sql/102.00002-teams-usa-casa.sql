-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Teams - CASA (Curated)
-- Teams linked to existing clubs where matched. Total: 20
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (262, 'Adé United FC', NULL, 20000, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (263, 'Alloy Soccer Club Reserves', NULL, 126, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (264, 'BCFC All Stars', NULL, 20001, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (265, 'Club de Futbol Armada', NULL, 20002, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (266, 'F&M FC', NULL, 20003, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (267, 'Flatley FC', NULL, 20004, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (268, 'Gambeta FC', NULL, 20005, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (269, 'Illyrians FC', NULL, 20006, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (270, 'Jaguars United FC', NULL, 20007, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (271, 'Lancaster City FC', NULL, 20008, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (272, 'Lighthouse Boys Club', NULL, 134, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (273, 'Lighthouse Old Timers Club', NULL, 134, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (274, 'Oaklyn United FC II', NULL, 127, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (275, 'Persepolis FC', NULL, 20009, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (276, 'Persepolis United FC II', NULL, 20009, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (277, 'Philadelphia SC II', NULL, 131, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (278, 'Phoenix SCM', NULL, 20010, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (279, 'Phoenix SCR', NULL, 20010, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (280, 'South Shore FC', NULL, 20011, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (281, 'Strictly Nos Fc', NULL, 20012, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
