-- 877 (2026-10-30) — James coaches every club team.
--
-- Owner: "it should show me as a coach for all teams".  Live rows stood at
-- APSL, Reserves, Liga 1 and the three Travel teams; the intramurals ended
-- 9/22, Indoor and the USASA Cup never had one, and Women's went to staff
-- in mig 442 ("for tri county i can be staff") — this supersedes that.
-- Assistant, as on the Travel teams; no roster status, since these rows
-- say nothing to a league.

INSERT INTO team_coaches (team_id, coach_id, coach_role_id, started_at)
SELECT t.id, c.id, (SELECT id FROM coach_roles WHERE name = 'assistant'), now()
  FROM teams t
  JOIN coaches c ON c.person_id = 1
 WHERE t.id IN (901, 931, 932, 934, 935, 936, 937, 939, 940, 941, 942)
   AND t.is_active
   AND NOT EXISTS (SELECT 1 FROM team_coaches x
                    WHERE x.team_id = t.id AND x.coach_id = c.id AND x.ended_at IS NULL);
