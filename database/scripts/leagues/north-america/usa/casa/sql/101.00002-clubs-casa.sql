-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Clubs - CASA (Curated)
-- Only new clubs not in APSL or CSL. Matched teams use existing club IDs. Total new: 21
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO clubs (id, name, organization_id) VALUES (20000, 'Adé United FC', 20000) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20001, 'Philadelphia Sierra Stars', 20001) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20002, 'Persepolis FC', 20002) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20003, 'Illyrians FC', 20003) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20004, 'Phoenix SCM', 20004) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20005, 'Philly BlackStars', 20005) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20006, 'Club de Futbol Armada', 20006) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20007, 'South Shore FC', 20007) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20008, 'Jaguars United FC', 20008) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20009, 'Strictly Nos Fc', 20009) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20010, 'BCFC All Stars', 20010) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20011, 'Flatley FC', 20011) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20012, 'Gambeta FC', 20012) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20013, 'Kutztown Men''s Soccer', 20013) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20014, 'Lancaster City FC', 20014) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20015, 'Keystone Elite', 20015) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20016, 'F&M FC', 20016) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20017, 'Millersville Men''s Club Soccer', 20017) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20018, 'Lancaster Bible College', 20018) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20019, 'West Chester University Club', 20019) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20020, 'YorkPA FC', 20020) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
