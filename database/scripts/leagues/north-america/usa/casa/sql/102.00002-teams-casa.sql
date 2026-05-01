-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Teams - CASA (Curated)
-- Teams with curated club_id references. Total: 0
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Lighthouse Boys Club', '9090889-lighthouse-boys-club', (SELECT id FROM clubs WHERE name = 'Lighthouse' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Oaklyn United FC II', '9090889-oaklyn-united-fc-ii', (SELECT id FROM clubs WHERE name = 'Oaklyn United FC' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Illyrians FC', '9090889-illyrians-fc', (SELECT id FROM clubs WHERE name = 'Illyrians FC' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Phoenix Reserves', '9090889-phoenix-reserves', (SELECT id FROM clubs WHERE name = 'Phoenix' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Lighthouse Old Timers Club', '9090889-lighthouse-old-timers-club', (SELECT id FROM clubs WHERE name = 'Lighthouse Old Timers Club' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Adé United FC', '9090889-adé-united-fc', (SELECT id FROM clubs WHERE name = 'Adé United FC' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Philadelphia Sierra Stars', '9090889-philadelphia-sierra-stars', (SELECT id FROM clubs WHERE name = 'Philadelphia Sierra Stars' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Lighthouse Old Timers Club', '9090889-lighthouse-old-timers-club', (SELECT id FROM clubs WHERE name = 'Lighthouse Old Timers Club' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Lighthouse Old Timers Club', '9090889-lighthouse-old-timers-club', (SELECT id FROM clubs WHERE name = 'Lighthouse Old Timers Club' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Persepolis FC', '9090889-persepolis-fc', (SELECT id FROM clubs WHERE name = 'Persepolis FC' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Lighthouse Old Timers Club', '9090889-lighthouse-old-timers-club', (SELECT id FROM clubs WHERE name = 'Lighthouse Old Timers Club' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Philly BlackStars', '9090889-philly-blackstars', (SELECT id FROM clubs WHERE name = 'Philly BlackStars' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Philadelphia SC II', '9090889-philadelphia-sc-ii', (SELECT id FROM clubs WHERE name = 'Philadelphia SC' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Lighthouse Boys Club U23', '9090889-lighthouse-boys-club-u23', (SELECT id FROM clubs WHERE name = 'Lighthouse Boys Club U23' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Phoenix SCM', '9090889-phoenix-scm', (SELECT id FROM clubs WHERE name = 'Phoenix' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 1'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
