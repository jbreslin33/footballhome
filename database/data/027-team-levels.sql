-- Team Levels - Numeric ranks drive all business logic
-- Lower rank number = higher tier (1 = first team, 2 = reserves, etc.)
-- Description is human-readable documentation only

INSERT INTO team_levels (id, level_rank, description) VALUES
(1, 1, 'First team - top competitive level'),
(2, 2, 'Reserve/second team - feeder to first team'),
(3, 3, 'Third team/academy - development level'),
(4, 4, 'Fourth team/youth - early development'),
(5, 5, 'Fifth team/recreational - grassroots level')
ON CONFLICT (id) DO NOTHING;

-- Reset sequence to continue from max id
SELECT setval('team_levels_id_seq', (SELECT COALESCE(MAX(id), 0) FROM team_levels));
