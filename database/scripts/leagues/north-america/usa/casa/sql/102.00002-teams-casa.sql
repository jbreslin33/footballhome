-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Teams - CASA (Curated)
-- Teams with curated club_id references. Total: 0
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Lighthouse Boys Club U23', '9096430-lighthouse-boys-club-u23', (SELECT id FROM clubs WHERE name = 'Lighthouse Boys Club U23' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Phoenix SCR', '9096430-phoenix-scr', (SELECT id FROM clubs WHERE name = 'Phoenix SCR' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Lighthouse Boys Club', '9096430-lighthouse-boys-club', (SELECT id FROM clubs WHERE name = 'Lighthouse' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Philadelphia SC Select', '9096430-philadelphia-sc-select', (SELECT id FROM clubs WHERE name = 'Philadelphia SC Select' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Ade United FC', '9096430-ade-united-fc', (SELECT id FROM clubs WHERE name = 'Ade United FC' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Persepolis FC II', '9096430-persepolis-fc-ii', (SELECT id FROM clubs WHERE name = 'Persepolis FC' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Philly Black Stars', '9096430-philly-black-stars', (SELECT id FROM clubs WHERE name = 'Philly Black Stars' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Sewell''s Old Boys', '9096430-sewell''s-old-boys', (SELECT id FROM clubs WHERE name = 'Sewell''s' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Oaklyn United Nor''Easters II', '9096430-oaklyn-united-nor''easters-ii', (SELECT id FROM clubs WHERE name = 'Oaklyn United Nor''Easters' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Philadelphia Sierra Stars', '9096430-philadelphia-sierra-stars', (SELECT id FROM clubs WHERE name = 'Philadelphia Sierra Stars' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
SELECT 'Illyrians', '9096430-illyrians', (SELECT id FROM clubs WHERE name = 'Illyrians' LIMIT 1), d.id, 2
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = 'Philadelphia Liga 2'
  AND s.name = '2025/2026'
  AND s.league_id = 2
ON CONFLICT DO NOTHING;
