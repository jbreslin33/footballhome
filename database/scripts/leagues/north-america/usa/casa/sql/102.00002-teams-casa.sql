-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Teams - CASA (Curated)
-- Teams with curated club_id references. Total: 0
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Adé United FC', '9090889-adé-united-fc', (SELECT id FROM clubs WHERE name = 'Adé United FC' LIMIT 1), d.id, 2
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
SELECT 'Oaklyn United FC II', '9090889-oaklyn-united-fc-ii', (SELECT id FROM clubs WHERE name = 'Oaklyn United FC' LIMIT 1), d.id, 2
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
SELECT 'Philadelphia Sierra Stars', '9090889-philadelphia-sierra-stars', (SELECT id FROM clubs WHERE name = 'Philadelphia Sierra Stars' LIMIT 1), d.id, 2
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
SELECT 'Persepolis FC', '9090889-persepolis-fc', (SELECT id FROM clubs WHERE name = 'Persepolis FC' LIMIT 1), d.id, 2
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
SELECT 'Illyrians FC', '9090889-illyrians-fc', (SELECT id FROM clubs WHERE name = 'Illyrians FC' LIMIT 1), d.id, 2
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
SELECT 'Lighthouse Boys Club', '9090889-lighthouse-boys-club', (SELECT id FROM clubs WHERE name = 'Lighthouse' LIMIT 1), d.id, 2
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
SELECT 'Philly BlackStars', '9090889-philly-blackstars', (SELECT id FROM clubs WHERE name = 'Philly BlackStars' LIMIT 1), d.id, 2
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
SELECT 'Phoenix SCM', '9090889-phoenix-scm', (SELECT id FROM clubs WHERE name = 'Phoenix SCM' LIMIT 1), d.id, 2
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
SELECT 'Persepolis FC II', '9096430-persepolis-fc-ii', (SELECT id FROM clubs WHERE name = 'Persepolis FC' LIMIT 1), d.id, 2
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
SELECT 'Philadelphia SC Select', '9096430-philadelphia-sc-select', (SELECT id FROM clubs WHERE name = 'Philadelphia SC Select' LIMIT 1), d.id, 2
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
SELECT 'Sewell''s Old Boys', '9096430-sewell''s-old-boys', (SELECT id FROM clubs WHERE name = 'Sewell''s' LIMIT 1), d.id, 2
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
SELECT 'Phoenix SCR', '9096430-phoenix-scr', (SELECT id FROM clubs WHERE name = 'Phoenix SCM' LIMIT 1), d.id, 2
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
SELECT 'Lighthouse Boys Club U23', '9096430-lighthouse-boys-club-u23', (SELECT id FROM clubs WHERE name = 'Lighthouse Boys Club U23' LIMIT 1), d.id, 2
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
SELECT 'Club de Futbol Armada', '9096430-club-de-futbol-armada', (SELECT id FROM clubs WHERE name = 'Club de Futbol Armada' LIMIT 1), d.id, 2
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
SELECT 'Jaguars United FC', '9090891-jaguars-united-fc', (SELECT id FROM clubs WHERE name = 'Jaguars United FC' LIMIT 1), d.id, 2
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
SELECT 'South Shore FC', '9090891-south-shore-fc', (SELECT id FROM clubs WHERE name = 'South Shore FC' LIMIT 1), d.id, 2
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
SELECT 'BCFC All Stars', '9090891-bcfc-all-stars', (SELECT id FROM clubs WHERE name = 'BCFC All Stars' LIMIT 1), d.id, 2
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
SELECT 'Strictly Nos Fc', '9090891-strictly-nos-fc', (SELECT id FROM clubs WHERE name = 'Strictly Nos Fc' LIMIT 1), d.id, 2
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
SELECT 'Flatley FC', '9090891-flatley-fc', (SELECT id FROM clubs WHERE name = 'Flatley FC' LIMIT 1), d.id, 2
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
SELECT 'Somerville United FC II', '9090891-somerville-united-fc-ii', (SELECT id FROM clubs WHERE name = 'Somerville United FC' LIMIT 1), d.id, 2
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
SELECT 'Gambeta FC', '9090891-gambeta-fc', (SELECT id FROM clubs WHERE name = 'Gambeta FC' LIMIT 1), d.id, 2
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
SELECT 'Alloy Soccer Club Reserves', '9090893-alloy-soccer-club-reserves', (SELECT id FROM clubs WHERE name = 'Alloy Soccer Club' LIMIT 1), d.id, 2
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
SELECT 'Kutztown Men''s Soccer', '9090893-kutztown-men''s-soccer', (SELECT id FROM clubs WHERE name = 'Kutztown Men''s Soccer' LIMIT 1), d.id, 2
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
SELECT 'Lancaster City FC', '9090893-lancaster-city-fc', (SELECT id FROM clubs WHERE name = 'Lancaster City FC' LIMIT 1), d.id, 2
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
SELECT 'Keystone Elite', '9090893-keystone-elite', (SELECT id FROM clubs WHERE name = 'Keystone Elite' LIMIT 1), d.id, 2
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
SELECT 'F&M FC', '9090893-f&m-fc', (SELECT id FROM clubs WHERE name = 'F&M FC' LIMIT 1), d.id, 2
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
SELECT 'Millersville Men''s Club Soccer', '9270318-millersville-men''s-club-soccer', (SELECT id FROM clubs WHERE name = 'Millersville Men''s Club Soccer' LIMIT 1), d.id, 2
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
SELECT 'West Chester University Club', '9270318-west-chester-university-club', (SELECT id FROM clubs WHERE name = 'West Chester University Club' LIMIT 1), d.id, 2
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
SELECT 'Lancaster Bible College', '9270318-lancaster-bible-college', (SELECT id FROM clubs WHERE name = 'Lancaster Bible College' LIMIT 1), d.id, 2
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
SELECT 'YorkPA FC', '9270318-yorkpa-fc', (SELECT id FROM clubs WHERE name = 'YorkPA FC' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Lancaster Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO UPDATE SET
  external_id = EXCLUDED.external_id,
  club_id = EXCLUDED.club_id,
  source_system_id = EXCLUDED.source_system_id;
