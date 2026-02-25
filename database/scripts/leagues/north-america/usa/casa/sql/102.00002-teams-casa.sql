-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Teams - CASA (Curated)
-- Teams with curated club_id references. Total: 25
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Adé United FC', '9090889-adé-united-fc', 20000, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Oaklyn United FC II', '9090889-oaklyn-united-fc-ii', 127, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Philadelphia Sierra Stars', '9090889-philadelphia-sierra-stars', 20001, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Persepolis FC', '9090889-persepolis-fc', 20002, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Phoenix SCM', '9090889-phoenix-scm', 20003, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Philly BlackStars', '9090889-philly-blackstars', 20004, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Illyrians FC', '9090889-illyrians-fc', 20005, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Lighthouse Boys Club', '9090889-lighthouse-boys-club', 20006, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Persepolis United FC II', '9096430-persepolis-united-fc-ii', 20002, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Phoenix SCR', '9096430-phoenix-scr', 20003, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Philadelphia SC Select', '9096430-philadelphia-sc-select', 20007, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Lighthouse Old Timers Club', '9096430-lighthouse-old-timers-club', 20008, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Club de Futbol Armada', '9096430-club-de-futbol-armada', 20009, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Sewell''s Old Boys', '9096430-sewell''s-old-boys', 20010, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'South Shore FC', '9090891-south-shore-fc', 20011, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Jaguars United FC', '9090891-jaguars-united-fc', 20012, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Strictly Nos Fc', '9090891-strictly-nos-fc', 20013, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'BCFC All Stars', '9090891-bcfc-all-stars', 20014, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Flatley FC', '9090891-flatley-fc', 20015, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Gambeta FC', '9090891-gambeta-fc', 20016, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Boston Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Kutztown Men''s Soccer', '9090893-kutztown-men''s-soccer', 20017, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Lancaster Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Alloy Soccer Club Reserves', '9090893-alloy-soccer-club-reserves', 126, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Lancaster Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Keystone Elite', '9090893-keystone-elite', 20018, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Lancaster Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'F&M FC', '9090893-f&m-fc', 20019, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Lancaster Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Lancaster City FC', '9090893-lancaster-city-fc', 20020, d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Lancaster Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT (division_id, name) DO NOTHING;
