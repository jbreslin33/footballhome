-- 1204 (2026-11-09): every youth coach on every winter age team.
-- Owner: "make sure youth coaches can see all practices".  Migs 1189–1192
-- built ❄️ U5–U16 with only James as coach, so Anthony, Ali, Sheldon, Luke,
-- Victor and Joseph saw no winter practice.  Each fall youth coach (U8/U10/
-- U12) now sits on every active winter boys/girls team with his fall role.
-- Which days each one sees is still #coach-schedule (coach_schedules).

BEGIN;

INSERT INTO team_coaches (team_id, coach_id, coach_role_id)
SELECT w.id, f.coach_id, f.coach_role_id
  FROM (SELECT DISTINCT ON (tc.coach_id) tc.coach_id, tc.coach_role_id
          FROM team_coaches tc
          JOIN teams t ON t.id = tc.team_id AND t.is_active AND t.gender_category IN ('boys', 'girls')
          JOIN team_terms tt ON tt.team_id = t.id AND tt.term = 'fall'
         WHERE tc.ended_at IS NULL
         ORDER BY tc.coach_id, tc.coach_role_id NULLS LAST) f
 CROSS JOIN (SELECT t.id FROM teams t JOIN team_terms tt ON tt.team_id = t.id AND tt.term = 'winter'
              WHERE t.is_active AND t.gender_category IN ('boys', 'girls')) w
 WHERE NOT EXISTS (SELECT 1 FROM team_coaches x WHERE x.team_id = w.id AND x.coach_id = f.coach_id AND x.ended_at IS NULL);

INSERT INTO schema_migrations (filename) VALUES ('1204-winter-youth-coaches.sql') ON CONFLICT DO NOTHING;

COMMIT;
