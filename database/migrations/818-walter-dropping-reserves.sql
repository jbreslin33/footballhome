-- 818 (2026-10-29) — Walter Juarez de Leon (22536): Dropping on APSL
-- Reserves, Not on Roster on Liga 1.
--
-- Owner: "walter needs cut from reserves even though he is la member. he
-- is just simply not available yet so no need to have him take up roster
-- spot".  A live member the club chooses to drop is the DROPPING lane
-- (possible_drop), not ✂ cut (mig 810 — no playing membership).
-- Liga 1: his On Roster status was stale — he is not on the CASA list
-- (all 35 names match other players), so it is parked at not_on_roster.

UPDATE team_persons tp
   SET roster_status_id = rs.id
  FROM (VALUES (938, 'possible_drop'), (120, 'not_on_roster')) AS v(team_id, code)
  JOIN roster_statuses rs ON rs.code = v.code
 WHERE tp.team_id = v.team_id AND tp.person_id = 22536 AND tp.removed_at IS NULL;
