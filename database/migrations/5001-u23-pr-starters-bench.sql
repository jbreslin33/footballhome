-- 5001 Lineup roles for U23 (957) and Puerto Rico (973). Owner 11/27: "for
-- each team lets list starter, bench, reserve (on roster but may not get in
-- always). lets do u23 first. starters: Sheldon, Ali, Sangin, Lucca, Luke,
-- Victor, Andy, Amir, Mars. List everyone else as bench for now." · "pr
-- starters: Owen, Gian, Fletcher, Tolu, Oladele, Evan list others as bench".
-- Ali = Ali Salah Alshami (3509, the APSL Ali). lineup_roles: 1 starter,
-- 2 bench, 3 reserve. Re-runnable (numbered clear of a parallel session).
BEGIN;
UPDATE team_persons SET lineup_role_id = CASE WHEN person_id IN
         (22433,   -- Sheldon Rhoden
          3509,    -- Ali Salah Alshami
          3510,    -- Hedayatullah Sangin
          22698,   -- Lucca Santos
          3463,    -- Luke Breslin
          22301,   -- Victor Baidal
          3498,    -- Andy Hizdri
          1275,    -- Amir Khan
          22445)   -- Mars Milligan
       THEN 1 ELSE 2 END
 WHERE team_id = 957 AND removed_at IS NULL;

UPDATE team_persons SET lineup_role_id = CASE WHEN person_id IN
         (3477,    -- Owen Magee
          14454,   -- Gian Maldonado
          1361,    -- Christopher Fletcher
          22598,   -- Tolu Asekun-Masha
          3480,    -- John Oladele
          22589)   -- Evan Watson
       THEN 1 ELSE 2 END
 WHERE team_id = (SELECT id FROM teams WHERE slug = 'lighthouse-mens-club-puerto-rico') AND removed_at IS NULL;

INSERT INTO schema_migrations (filename) VALUES ('5001-u23-pr-starters-bench.sql') ON CONFLICT DO NOTHING;
COMMIT;
