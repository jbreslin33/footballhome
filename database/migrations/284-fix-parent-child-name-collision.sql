-- ═══════════════════════════════════════════════════════════════════════
-- 284-fix-parent-child-name-collision.sql
-- ═══════════════════════════════════════════════════════════════════════
--
-- persons had a UNIQUE(first_name, last_name) constraint, which silently
-- assumed no two real people ever share a full name.  That's false for
-- this club: a parent can share their child's exact name (Lee Tolbert
-- Sr./Jr. and similar).  PersonLinker::ensureParentLink's name-match
-- fallback (backend/src/models/PersonLinker.cpp) had no guard against
-- matching the CHILD's own row when resolving the parent, so on every
-- LA sync pass it bound the PARENT's LeagueApps userId onto the CHILD's
-- persons.la_user_id — immediately un-matching the child's own
-- registration on the *next* sync pass (fast-path miss -> name/DOB
-- match -> corrected briefly -> ensureParentLink clobbers it again).
--
-- Found 2026-08-15 via 3 youth players (Lee Tolbert, Sierra Walker,
-- Melinda Zambrana) whose team_persons rows kept getting auto-swept by
-- fn_sweep_invalid_rosters() (migration 281) within under a second of
-- being added by a coach — their person_la_memberships row was being
-- closed and reopened ~100+ times/day since 2026-07-03, because
-- persons.la_user_id flip-flopped to the parent's id on every sync.
-- Confirmed against live LeagueApps data via /api/admin/la-probe:
-- Lee Tolbert's registration has userId=57321368 (his own) but our DB
-- had la_user_id=57321358 (his parent's parentUserId).
--
-- The corruption signature is persons.parent_person_id = persons.id
-- (ensureParentLink's step 6 pointed the child at itself, since the
-- "parent" row it resolved WAS the child's own row).  4 people club-wide
-- had it.
--
-- Fix: drop the false-uniqueness constraint (identity is tracked via
-- la_user_id + explicit linking, not name), and PersonLinker.cpp now
-- excludes the child's own row when resolving the parent.  This
-- migration also repairs the 4 already-corrupted records so the next
-- sync pass can create the parent as a genuinely separate person.
-- ═══════════════════════════════════════════════════════════════════════

BEGIN;

ALTER TABLE persons DROP CONSTRAINT IF EXISTS persons_first_name_last_name_key;

-- Clear the corruption: la_user_id currently holds the PARENT's LA
-- userId (wrong) and parent_person_id points at the row itself (wrong).
-- Nulling both lets the next LA sync pass re-derive the child's own
-- correct la_user_id (name+DOB match, since DOB is unaffected) and
-- create a genuinely distinct parent row via the now-fixed
-- ensureParentLink.
UPDATE persons
   SET la_user_id       = NULL,
       parent_person_id = NULL,
       updated_at       = NOW()
 WHERE parent_person_id = id;

COMMIT;
