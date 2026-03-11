-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Clubs - CASA (Curated)
-- Only new clubs not in APSL or CSL. Matched teams use existing club IDs. Total new: 19
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO clubs (id, name, organization_id) VALUES (20000, 'Adé United FC', 20000) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20001, 'Persepolis FC', 20001) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20002, 'Phoenix SCM', 20002) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20003, 'Philly BlackStars', 20003) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20004, 'Illyrians FC', 20004) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20005, 'South Shore FC', 20005) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20006, 'Jaguars United FC', 20006) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20007, 'Strictly Nos Fc', 20007) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20008, 'BCFC All Stars', 20008) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20009, 'Flatley FC', 20009) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20010, 'Gambeta FC', 20010) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20011, 'Kutztown Men''s Soccer', 20011) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20012, 'F&M FC', 20012) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20013, 'Lancaster City FC', 20013) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20014, 'Keystone Elite', 20014) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20015, 'Millersville Men''s Club Soccer', 20015) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20016, 'Lancaster Bible College', 20016) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20017, 'YorkPA FC', 20017) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20018, 'West Chester University Club', 20018) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
