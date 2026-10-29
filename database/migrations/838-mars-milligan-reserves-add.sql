-- 838 (2026-10-29) — Mars Milligan (22445): his proposed add is APSL
-- Reserves, not the APSL first team.
--
-- Owner, reading the roster-moves email (migs 829/837): "somi should be
-- add to APSL main. the others are add to APSL reserves."  Mars was
-- Needs Docs on APSL (35); the step moves to Reserves (938), and his APSL
-- card goes back to Not on Roster (still on the team in FH, off the email).

INSERT INTO team_persons (team_id, person_id, roster_status_id)
SELECT 938, 22445, rs.id FROM roster_statuses rs
 WHERE rs.code = 'needs_docs'
   AND NOT EXISTS (SELECT 1 FROM team_persons tp
                    WHERE tp.team_id = 938 AND tp.person_id = 22445 AND tp.removed_at IS NULL);

UPDATE team_persons tp SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'not_on_roster')
 WHERE tp.team_id = 35 AND tp.person_id = 22445 AND tp.removed_at IS NULL
   AND tp.roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'needs_docs');
