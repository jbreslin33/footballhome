-- 223-external-aliases-drop-name-uniqueness.sql
--
-- Problem being fixed
-- ───────────────────
-- LA sync silently drops registrants whose display name collides with
-- an existing alias row for a DIFFERENT LA userId.  Recent observed
-- casualties (2026-07-16 sync logs):
--
--   [PersonLinker::linkLa] duplicate key value violates unique constraint
--   "uq_external_person_aliases_provider_name" (laUserId=57603437)     ← boys
--   [PersonLinker::linkLa] duplicate key value violates unique constraint
--   "uq_external_person_aliases_provider_name" (laUserId=56495153)     ← men-pickup
--
-- Both are legitimate members who share a first+last name with an
-- earlier-linked person (namesake / relative).  linkLa's ON CONFLICT
-- clause targets the (provider, external_user_id) partial index, so
-- when the (provider, alias_first_name, alias_last_name) constraint
-- fires instead the whole INSERT aborts, no alias is created, and the
-- membership row is never opened.  The person then disappears from
-- every LA-derived surface (rosters, members list, payments, pool)
-- until an operator manually intervenes.
--
-- Root cause
-- ──────────
-- `uq_external_person_aliases_provider_name` (migration 042) predates
-- migration 043 which introduced `external_user_id` as the authoritative
-- identifier.  With external_user_id in play, two humans legitimately
-- can (and do) share a name.  The name-based uniqueness is only
-- meaningful for legacy / manual rows that have NO external_user_id
-- (e.g. groupme aliases like "VictorB / (GroupMe)").
--
-- Fix
-- ───
-- Replace the total-uniqueness constraint with a partial unique index
-- scoped to `WHERE external_user_id IS NULL`.  This keeps name-based
-- identity for legacy rows (where it's the only key we have) but
-- allows any number of rows to share (provider, name) as long as each
-- has a distinct external_user_id — which the pre-existing partial
-- index `uq_external_person_aliases_provider_user_id`
-- (WHERE external_user_id IS NOT NULL) already enforces.
--
-- Effect on the sync loop
-- ───────────────────────
-- After this migration, PersonLinker::linkLa's alias INSERT succeeds
-- for both LA-userId collisions above.  No code change is required —
-- the existing `ON CONFLICT (provider, external_user_id) WHERE
-- external_user_id IS NOT NULL DO UPDATE …` clause is already
-- correctly targeting the surviving partial index.

BEGIN;

ALTER TABLE external_person_aliases
    DROP CONSTRAINT IF EXISTS uq_external_person_aliases_provider_name;

-- Keep name-based uniqueness for legacy / manual rows that have no
-- external_user_id (e.g. groupme aliases created before we adopted
-- provider-side stable ids).  Without this a merge-tool bug could
-- otherwise silently double-insert the same manual alias.
CREATE UNIQUE INDEX IF NOT EXISTS
    uq_external_person_aliases_provider_name_no_uid
    ON external_person_aliases (provider, alias_first_name, alias_last_name)
    WHERE external_user_id IS NULL;

-- Case-insensitive lookup index survives untouched (created in migration
-- 042).  It is intentionally NOT unique — the LA fast-path just uses it
-- for name-based fallback matching in linkLa step 2.

COMMIT;
