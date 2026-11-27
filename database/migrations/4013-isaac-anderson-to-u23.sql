-- 4013 Isaac Anderson Puerto Rico → U23 (957). Owner 11/27 "move isaac to
-- u23 as we get 2 players that are u25 or u24" — the U23 league allows two
-- overage players (U24/U25); Isaac is U24. Ends his PR row, adds U23 (depth).
-- (Gap number.)
BEGIN;
UPDATE team_persons SET removed_at = now(), removed_reason = 'moved to U23 as an overage player (mig 4013)'
 WHERE person_id = (SELECT id FROM persons WHERE first_name = 'Isaac' AND last_name = 'Anderson')
   AND removed_at IS NULL
   AND team_id = (SELECT id FROM teams WHERE slug = 'lighthouse-mens-club-puerto-rico');
INSERT INTO team_persons (team_id, person_id, roster_status_id)
SELECT 957, p.id, 1 FROM persons p
 WHERE p.first_name = 'Isaac' AND p.last_name = 'Anderson'
   AND NOT EXISTS (SELECT 1 FROM team_persons x WHERE x.team_id = 957 AND x.person_id = p.id AND x.removed_at IS NULL);
INSERT INTO schema_migrations (filename) VALUES ('4013-isaac-anderson-to-u23.sql') ON CONFLICT DO NOTHING;
COMMIT;
