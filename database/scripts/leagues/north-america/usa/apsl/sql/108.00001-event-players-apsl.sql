-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Event Players - APSL (auto-created from match events)
-- Players found in match events but not on any roster page
-- Total Records: 1
--
-- Architecture: Name-based lookups (no hardcoded IDs)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO persons (first_name, last_name)
VALUES ('Kevin', 'Davis')
ON CONFLICT (first_name, last_name) DO NOTHING;
INSERT INTO players (person_id, source_system_id)
SELECT id, 1 FROM persons
WHERE first_name = 'Kevin' AND last_name = 'Davis'
ON CONFLICT (person_id) DO NOTHING;
INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id)
SELECT pl.id, 1, 'ny-athletic-club-kevin-davis', '114830'
FROM players pl JOIN persons per ON pl.person_id = per.id
WHERE per.first_name = 'Kevin' AND per.last_name = 'Davis'
ON CONFLICT (source_system_id, external_id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
SELECT t.id, pl.id, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Kevin' AND per.last_name = 'Davis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

