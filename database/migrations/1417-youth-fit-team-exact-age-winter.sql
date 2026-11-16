-- 1417 (2026-11-16): new winter kids landed on U16. Owner: "why does Noah
-- Randley show in u16 but says u10 on pill lol".
--   fh_youth_fit_team picked only teams with games_need_roster (mig 1034:
--   "teams that play games"). Mig 1413 turned that flag OFF on the winter
--   U6–U13 groups (it also drives the league-list status rule), so the only
--   winter candidate left for an age-10 kid was U16 956 — the oldest band,
--   pri 3. Noah Randley (person 22791, born 2017-07-02, US age 10) was
--   re-placed by fh_youth_place at 17:11 UTC and went to U16; his fall U10
--   (913) row is right.
--   Fix: an exact-age team counts whether or not it has a league roster
--   (games_need_roster OR age_exact) — every winter U6–U13 group is
--   age_exact. Then Noah's U16 row moves to winter U10 (942), plain Active
--   like the rest since mig 1413. He was the only kid on U16.

BEGIN;

CREATE OR REPLACE FUNCTION fh_youth_fit_team(p_age integer, p_term text) RETURNS integer
LANGUAGE sql STABLE AS $$
    WITH c AS (
        SELECT t.id, fh_team_age(t.id) AS a, t.age_exact
          FROM teams t JOIN team_terms tt ON tt.team_id = t.id AND tt.term = p_term
         WHERE t.is_active AND (t.games_need_roster OR t.age_exact)
           AND t.gender_category IN ('boys', 'girls') AND t.name ~ '^U[0-9]+$')
    SELECT id FROM (
        SELECT id, 1 AS pri, a FROM c WHERE age_exact AND a = p_age
        UNION ALL SELECT id, 2, a FROM c WHERE NOT age_exact AND a >= p_age
        UNION ALL SELECT id, 3, -a FROM c WHERE NOT age_exact
    ) x ORDER BY pri, a, id LIMIT 1
$$;

UPDATE team_persons
   SET removed_at = now(), removed_reason = 'admin_remove'
 WHERE person_id = 22791 AND team_id = 956 AND removed_at IS NULL;

INSERT INTO team_persons (team_id, person_id, on_roster, invite_only, call_in, squad_status_id)
SELECT 942, 22791, false, false, false, NULL
 WHERE NOT EXISTS (SELECT 1 FROM team_persons
                    WHERE team_id = 942 AND person_id = 22791 AND removed_at IS NULL);

COMMIT;
