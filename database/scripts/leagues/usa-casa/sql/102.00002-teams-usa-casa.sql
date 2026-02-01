-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Teams - CASA (Curated)
-- Teams linked to existing clubs where matched. Total: 20
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (20000, 'Adé United FC', '9090889-adé-united-fc', 20000, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (20001, 'Oaklyn United FC II', '9090889-oaklyn-united-fc-ii', 127, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (20002, 'Persepolis FC', '9090889-persepolis-fc', 20001, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (20003, 'Phoenix SCM', '9090889-phoenix-scm', 20002, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (20004, 'Illyrians FC', '9090889-illyrians-fc', 20003, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (20005, 'Lighthouse Boys Club', '9090889-lighthouse-boys-club', 20004, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (20006, 'Persepolis United FC II', '9096430-persepolis-united-fc-ii', 20001, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (20007, 'Phoenix SCR', '9096430-phoenix-scr', 20002, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (20008, 'Philadelphia SC II', '9096430-philadelphia-sc-ii', 129, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (20009, 'Lighthouse Old Timers Club', '9096430-lighthouse-old-timers-club', 20005, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (20010, 'Club de Futbol Armada', '9096430-club-de-futbol-armada', 20006, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (20011, 'South Shore FC', '9090891-south-shore-fc', 20007, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (20012, 'Jaguars United FC', '9090891-jaguars-united-fc', 20008, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (20013, 'Strictly Nos Fc', '9090891-strictly-nos-fc', 20009, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (20014, 'BCFC All Stars', '9090891-bcfc-all-stars', 20010, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (20015, 'Flatley FC', '9090891-flatley-fc', 20011, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (20016, 'Gambeta FC', '9090891-gambeta-fc', 20012, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (20017, 'Alloy Soccer Club Reserves', '9090893-alloy-soccer-club-reserves', 126, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (20018, 'F&M FC', '9090893-f&m-fc', 20013, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
INSERT INTO teams (id, name, external_id, club_id, source_system_id) VALUES (20019, 'Lancaster City FC', '9090893-lancaster-city-fc', 20014, 2) ON CONFLICT (source_system_id, external_id) DO UPDATE SET club_id = EXCLUDED.club_id;
