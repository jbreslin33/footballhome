-- 4019 Puerto Rico subs: Daouda Elegbe (22255), Moussa Camara (22269),
-- Joey Benzing (22241 — "bening"), Diego Quintero (22490) depth → subs.
-- Owner 11/27 "add elegbe,camara, bening, diego to subs". (Gap number.)
BEGIN;
UPDATE team_persons SET lineup_role_id = 2
 WHERE person_id IN (22255, 22269, 22241, 22490) AND removed_at IS NULL
   AND team_id = (SELECT id FROM teams WHERE slug = 'lighthouse-mens-club-puerto-rico');
INSERT INTO schema_migrations (filename) VALUES ('4019-pr-four-subs.sql') ON CONFLICT DO NOTHING;
COMMIT;
