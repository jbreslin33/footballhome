-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Teams - CASA (Curated)
-- Teams with curated club_id references. Total: 30
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Adé United FC', '9090889-adé-united-fc', 20000, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Oaklyn United FC II', '9090889-oaklyn-united-fc-ii', 127, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Philadelphia Sierra Stars', '9090889-philadelphia-sierra-stars', 171, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Persepolis FC', '9090889-persepolis-fc', 20001, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Philly BlackStars', '9090889-philly-blackstars', 20002, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Phoenix SCM', '9090889-phoenix-scm', 20003, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Illyrians FC', '9090889-illyrians-fc', 20004, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Lighthouse Boys Club', '9090889-lighthouse-boys-club', 134, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Philadelphia SC Select', '9096430-philadelphia-sc-select', 129, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Persepolis FC II', '9096430-persepolis-fc-ii', 20001, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Phoenix SCR', '9096430-phoenix-scr', 20003, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Sewell''s Old Boys', '9096430-sewell''s-old-boys', 136, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Lighthouse Boys Club U23', '9096430-lighthouse-boys-club-u23', 134, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Club de Futbol Armada', '9096430-club-de-futbol-armada', 146, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'South Shore FC', '9090891-south-shore-fc', 20005, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Jaguars United FC', '9090891-jaguars-united-fc', 20006, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Strictly Nos Fc', '9090891-strictly-nos-fc', 20007, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'BCFC All Stars', '9090891-bcfc-all-stars', 20008, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Flatley FC', '9090891-flatley-fc', 20009, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Gambeta FC', '9090891-gambeta-fc', 20010, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Somerville United FC II', '9090891-somerville-united-fc-ii', 107, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Alloy Soccer Club Reserves', '9090893-alloy-soccer-club-reserves', 126, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Lancaster Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Kutztown Men''s Soccer', '9090893-kutztown-men''s-soccer', 20011, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Lancaster Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Lancaster City FC', '9090893-lancaster-city-fc', 20012, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Lancaster Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'F&M FC', '9090893-f&m-fc', 20013, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Lancaster Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Keystone Elite', '9090893-keystone-elite', 20014, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Lancaster Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Millersville Men''s Club Soccer', '9270318-millersville-men''s-club-soccer', 20015, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Lancaster Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Lancaster Bible College', '9270318-lancaster-bible-college', 20016, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Lancaster Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'West Chester University Club', '9270318-west-chester-university-club', 20017, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Lancaster Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'YorkPA FC', '9270318-yorkpa-fc', 20018, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Lancaster Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
