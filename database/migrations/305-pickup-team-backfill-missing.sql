-- 305 — Add the pickup members team 909 was missing.
--
-- Migration 304 fixed the half of the drift that put people on the Pickup
-- team who had never registered. This fixes the other half: 18 men hold a
-- current LA pickup registration (program 5070075) and have no row at all.
--
-- Nothing was wrong with the writer here — LaPool 3c inserts exactly these
-- rows. The problem is WHEN it runs: only on the club LA-pool endpoint, so
-- 909 converges lazily, whenever someone happens to open that screen. A
-- paid member should not be waiting on a page view to exist. This runs the
-- same INSERT once, now, so prod is correct immediately; LaPool keeps it
-- that way (and, as of today, closes rows too).
--
-- Same predicate as LaPool's own INSERT — the pool team resolved through
-- club_id / is_pool / name / team_eligible_genders rather than the literal
-- 909, so this cannot write to the wrong team if ids ever move.
INSERT INTO team_persons (team_id, person_id, on_roster)
SELECT t.id, p.id, false
  FROM persons p
  JOIN person_la_memberships plm
    ON plm.person_id = p.id
   AND plm.la_program_id = 5070075
   AND plm.ended_at IS NULL
  CROSS JOIN teams t
  JOIN team_eligible_genders teg
    ON teg.team_id = t.id AND teg.gender = 'mens'
 WHERE t.is_pool = true
   AND t.name = 'Pickup'
   AND t.club_id = 134
ON CONFLICT (team_id, person_id) WHERE removed_at IS NULL DO NOTHING;
