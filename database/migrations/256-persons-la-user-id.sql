-- 256-persons-la-user-id.sql (2026-08-02)
--
-- Replace external_person_aliases as the LA-identity source with a single
-- column directly on persons.  external_person_aliases let one person
-- accumulate multiple LeagueApps userId rows over time (LA reissues a
-- user's id occasionally; PersonLinker::linkLa inserted a new alias row
-- per reissue and never touched the old one).  Every read site then had
-- to independently guess "which alias is current" -- and disagreed with
-- each other (ORDER BY epa.id DESC in some places, MAX(external_user_id)
-- in another, a bare LIMIT 1 in another).  That disagreement between the
-- write path (MensTeamAssignments::addAssignment, resolves via ANY
-- alias) and the read path (MensTeamAssignments::loadAll, picks ONE
-- alias to key board cards) is what let a boys-roster move silently
-- fail to show up for multi-alias players.
--
-- persons.la_user_id is the single current LA userId for a person,
-- overwritten in place on every sync (see PersonLinker.cpp).  Uniqueness
-- is enforced by the DB, not by convention, so a person can no longer
-- end up with two live identity rows.  Every call site (backend + scripts
-- + verification SQL) was cut over in the same change that introduced this
-- migration, so external_person_aliases is dropped here rather than staged
-- as a follow-up: nothing reads or writes it after this migration runs.

BEGIN;

ALTER TABLE persons ADD COLUMN IF NOT EXISTS la_user_id TEXT NULL;

COMMENT ON COLUMN persons.la_user_id IS
'Current LeagueApps userId for this person (single value, overwritten in place on reissue). Replaces external_person_aliases as the LA identity bridge -- see migration 256.';

CREATE UNIQUE INDEX IF NOT EXISTS uq_persons_la_user_id
    ON persons (la_user_id) WHERE la_user_id IS NOT NULL;

-- Backfill: one row per person, picking the same "most recently inserted
-- alias" convention MensTeamAssignments::loadAll() already used, so the
-- visible LA id on every card doesn't change out from under anyone at
-- cutover.
UPDATE persons p
   SET la_user_id = sub.external_user_id
  FROM (
        SELECT DISTINCT ON (person_id) person_id, external_user_id
          FROM external_person_aliases
         WHERE provider = 'leagueapps' AND external_user_id IS NOT NULL
         ORDER BY person_id, id DESC
       ) sub
 WHERE p.id = sub.person_id;

DROP TABLE external_person_aliases;

COMMIT;
