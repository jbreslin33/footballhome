-- 338 — Purge the LA-membership churn rows left behind by the
-- parent/child identity collision fixed in commit 723a4ab6 (2026-08-15).
--
-- Owner 2026-09-06, on #person for Lee Tolbert: "massive dup entries
-- for boys active joined Aug 15 ... #5039252 ... and probably others".
--
-- What happened: until 723a4ab6, every LA sync pass re-bound a parent's
-- LA userId onto a same-named child (Tolbert Sr./Jr. and similar), so
-- PersonLinker::closeStaleMemberships closed the child's open row and
-- recordMembership immediately re-opened it — one open+close pair per
-- sync, ~2,800 rows apiece for the three worst cases, 9,000+ overall.
-- The last such row was created 2026-08-15; nothing has churned since.
--
-- The profile page (PersonProfileController → person.js
-- _renderMembershipsCard) lists every row, so those people show
-- thousands of "ended" lines under LeagueApps memberships.
--
-- Rule: delete an ENDED row that lived less than a day AND is not the
-- first row for its (person, program) — i.e. it's a re-open, never the
-- original registration. The 24 same-day rows that ARE a person's first
-- row for a program stay (a genuine sign-up-then-drop is history worth
-- keeping). Open rows are untouched. Nothing references this table by
-- FK, and trg_sweep_on_membership_change only reacts to deleting an
-- OPEN row, so no roster sweep fires.
--
-- Expected on prod: 9,074 rows across 8 people (verified before writing
-- this migration).

BEGIN;

DELETE FROM person_la_memberships m
 WHERE m.ended_at IS NOT NULL
   AND m.ended_at - m.joined_at < interval '1 day'
   AND EXISTS (SELECT 1 FROM person_la_memberships o
                WHERE o.person_id     = m.person_id
                  AND o.la_program_id = m.la_program_id
                  AND o.created_at    < m.created_at);

COMMIT;
