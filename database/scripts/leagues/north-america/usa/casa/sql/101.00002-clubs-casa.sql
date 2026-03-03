-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Clubs - CASA (Curated)
-- Only new clubs not in APSL or CSL. Matched teams use existing club IDs. Total new: 25
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
INSERT INTO clubs (id, name, organization_id) VALUES (20009, 'Club de Futbol Armada', 20009) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20010, 'Sewell''s', 20010) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20011, 'South Shore FC', 20011) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20012, 'Jaguars United FC', 20012) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20013, 'Strictly Nos Fc', 20013) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20014, 'BCFC All Stars', 20014) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20015, 'Flatley FC', 20015) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20016, 'Gambeta FC', 20016) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20017, 'Kutztown Men''s Soccer', 20017) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20018, 'Lancaster City FC', 20018) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20019, 'Keystone Elite', 20019) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20020, 'F&M FC', 20020) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20021, 'Millersville Men''s Club Soccer', 20021) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20022, 'Lancaster Bible College', 20022) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20023, 'West Chester University Club', 20023) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
INSERT INTO clubs (id, name, organization_id) VALUES (20024, 'YorkPA FC', 20024) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, organization_id = EXCLUDED.organization_id;
