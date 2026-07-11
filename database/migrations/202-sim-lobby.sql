-- 202-sim-lobby.sql
--
-- Seed a single M0 sim match so /api/sim/matches/1/join has something
-- concrete to hand out a token for. The `footballhome_sim` daemon
-- currently serves ONE match_id (SIM_MATCH_ID env, default 1); this
-- row must therefore have id = 1.
--
-- When the sim daemon gains multi-match support (post-M0), POST
-- /api/sim/matches will INSERT additional rows and the daemon will
-- lazily materialise them. Until then, treat id=1 as the only playable
-- match and let POST /api/sim/matches be a no-op that re-returns it.

BEGIN;

INSERT INTO sim_matches (id, scenario_id, seed, tick_hz, server_version,
                         created_by, visibility, started_at, ended_at)
SELECT 1,
       s.id,
       42,
       20,
       'm0-slice-12',
       NULL,
       0,           -- public
       NOW(),
       NULL         -- open
FROM sim_scenarios s
WHERE s.code_id = 'empty_pitch'
ON CONFLICT (id) DO NOTHING;

-- Bump the sequence past any hand-seeded ids so future auto-inserts
-- don't collide.
SELECT setval(
    pg_get_serial_sequence('sim_matches', 'id'),
    GREATEST((SELECT MAX(id) FROM sim_matches), 1)
);

COMMIT;
