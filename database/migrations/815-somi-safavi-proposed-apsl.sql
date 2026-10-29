-- 815 (2026-10-29) — Som(i) Safavi (10878) proposed for APSL.
--
-- On the APSL team (35) in FH with no roster status and not on the APSL
-- TeamPass list, so the Roster pill had nowhere to show him.  Owner: add
-- him to proposed adds for APSL — needs_docs, the first PROPOSED ADDS step.
-- His Team dropdown stays Plays (full player, not invite-only).

UPDATE team_persons
   SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'needs_docs')
 WHERE team_id = 35 AND person_id = 10878 AND removed_at IS NULL AND roster_status_id IS NULL;
