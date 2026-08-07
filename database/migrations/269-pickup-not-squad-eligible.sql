-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 269: Pickup membership no longer satisfies real-squad
-- membership requirements
--
-- Migration 097's own design intent for the Pickup sub-program: "Pickup
-- pool team (909) ONLY. Can RSVP to match_type_id=7 pickup events,
-- cannot see Practice/Games." But team_membership_requirements listed
-- the mens+boys pickup program ids (5070075, 5064618) as satisfying
-- membership for APSL (35), Liga 1 (120), Liga 2 (121), and Adult
-- League (122) — real competitive squads, contradicting that intent.
--
-- Caught via Kay Asante (person 22430): active membership ended
-- 2026-08-06, immediately re-registered on Pickup same day, and stayed
-- fully visible/eligible on the Liga 1 (120) roster because Pickup
-- satisfied that team's requirement row. Owner directive 2026-08-07:
-- remove pickup eligibility for these four squads so this can't happen
-- again — no schema change needed, this is purely dropping the four
-- now-incorrect requirement rows. The existing team_membership_requirements
-- -driven sweep (fn_sweep_invalid_rosters, extended in migration 267)
-- picks up the change on the very next roster load — no new logic
-- needed here.
--
-- Deliberately scoped to ONLY 35/120/121/122 (the teams actually named
-- in the owner's decision) — leaves 456/903/904/905/908/909 untouched;
-- those weren't part of this decision and may have different intended
-- semantics (exhibition teams, the pool teams themselves).
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

DELETE FROM team_membership_requirements
 WHERE team_id IN (35, 120, 121, 122)
   AND la_program_id IN (5070075, 5064618);

-- Catch up immediately rather than waiting for the next roster page load.
SELECT fn_sweep_invalid_rosters();

COMMIT;
