-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Clubs - CASA (Curated)
-- Only new clubs not in APSL or CSL. Matched teams use existing club IDs. Total new: 24
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO clubs (id, name, organization_id) VALUES (20000, 'Adé United FC', 20000) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20001, 'Philadelphia Sierra Stars', 20001) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20002, 'Persepolis FC', 20002) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20003, 'Illyrians FC', 20003) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20004, 'Phoenix SCM', 20004) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20005, 'Philly BlackStars', 20005) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20006, 'Lighthouse Boys Club', 20006) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20007, 'Philadelphia SC Select', 20007) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20008, 'Lighthouse Old Timers Club', 20008) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20009, 'Sewell''s', 20009) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20010, 'South Shore FC', 20010) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20011, 'Jaguars United FC', 20011) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20012, 'Strictly Nos Fc', 20012) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20013, 'BCFC All Stars', 20013) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20014, 'Flatley FC', 20014) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20015, 'Gambeta FC', 20015) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20016, 'Kutztown Men''s Soccer', 20016) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20017, 'Lancaster City FC', 20017) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20018, 'Keystone Elite', 20018) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20019, 'F&M FC', 20019) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20020, 'Millersville Men''s Club Soccer', 20020) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20021, 'Lancaster Bible College', 20021) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20022, 'West Chester University Club', 20022) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20023, 'YorkPA FC', 20023) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
