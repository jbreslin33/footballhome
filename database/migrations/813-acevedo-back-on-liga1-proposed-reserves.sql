-- 813 (2026-10-29) — Anthony Acevedo (22397) back on Liga 1, proposed for
-- APSL Reserves.
--
-- Swept off every team 8/14 (fn_sweep_invalid_rosters, no valid
-- membership); he re-registered for the Men's Club Soccer Membership
-- today, which cleared his ✂ cut flag on the CASA Liga 1 list (mig 810).
-- Owner: "put acevedo on liga 1 and proposed reserves".
--   Liga 1 (120)        — on_roster: he is on the CASA official list
--   APSL Reserves (938) — needs_docs: the first PROPOSED ADDS step

INSERT INTO team_persons (team_id, person_id, roster_status_id)
SELECT v.team_id, 22397, rs.id
  FROM (VALUES (120, 'on_roster'), (938, 'needs_docs')) AS v(team_id, code)
  JOIN roster_statuses rs ON rs.code = v.code
 WHERE NOT EXISTS (SELECT 1 FROM team_persons tp
                    WHERE tp.team_id = v.team_id AND tp.person_id = 22397 AND tp.removed_at IS NULL);
