-- 043-external-person-aliases-user-id.sql
-- Add an optional external_user_id to external_person_aliases so the
-- LeagueApps ↔ person bridge can be locked by the stable LA `userId`
-- (the same identifier used everywhere else: mens_team_assignments,
-- person_billing, /api/mens-roster).  Name-based lookups still work as
-- a fallback for legacy rows.
--
-- A NULL external_user_id means "match by (provider, first, last)
-- only" (the original behavior).  When external_user_id is set the
-- lookup is by (provider, external_user_id) and the name fields become
-- a human-friendly label (last known LA spelling).

ALTER TABLE external_person_aliases
    ADD COLUMN IF NOT EXISTS external_user_id TEXT NULL;

COMMENT ON COLUMN external_person_aliases.external_user_id IS
'Stable provider-side user id (e.g. LeagueApps userId).  Preferred over
name-based lookup when present.  NULL allowed for historical/manual rows.';

CREATE UNIQUE INDEX IF NOT EXISTS uq_external_person_aliases_provider_user_id
    ON external_person_aliases (provider, external_user_id)
    WHERE external_user_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_external_person_aliases_user_id_lookup
    ON external_person_aliases (provider, external_user_id);
