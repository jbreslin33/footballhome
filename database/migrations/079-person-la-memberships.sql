-- 079-person-la-memberships.sql
--
-- Person ↔ LA sub-program membership junction table.  A person is a
-- Lighthouse "member" iff they have a current row here (ended_at IS NULL).
-- Their membership *variant* — 'active' or 'paused' — comes from the
-- referenced program row in `leagueapps_programs`.
--
-- This replaces ad-hoc live-fetches to the LA API for "is this person
-- paused?" questions.  PersonLinker::linkLa keeps rows fresh: on every LA
-- registration seen for a person, if their current membership program_id
-- differs from what LA now says, the old row is closed (`ended_at = now()`)
-- and a new row inserted for the new program.  A person moved from
-- "Men's Club Membership" (5039300) to "Men's Club Paused Membership"
-- (5064676) therefore leaves an audit trail: prior row closed, new row open.
--
-- Roster / pool / RSVP queries can then anti-join against the set of
-- currently-paused persons to hide them from playing surfaces while
-- keeping them visible in the dedicated "Paused Membership" admin view.

BEGIN;

CREATE TABLE IF NOT EXISTS person_la_memberships (
    id            SERIAL PRIMARY KEY,
    person_id     INTEGER     NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    la_program_id BIGINT      NOT NULL REFERENCES leagueapps_programs(program_id),
    joined_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    ended_at      TIMESTAMPTZ,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- One current membership per (person, program): closing a row and inserting
-- a new one for the same program is allowed (audit), but two OPEN rows for
-- the same person+program are not.
CREATE UNIQUE INDEX IF NOT EXISTS person_la_memberships_current_unique
    ON person_la_memberships (person_id, la_program_id)
    WHERE ended_at IS NULL;

-- Fast lookup "which persons are currently on program X?"
CREATE INDEX IF NOT EXISTS person_la_memberships_program_current_idx
    ON person_la_memberships (la_program_id)
    WHERE ended_at IS NULL;

-- Fast lookup "give me all of person X's currently-open memberships"
CREATE INDEX IF NOT EXISTS person_la_memberships_person_current_idx
    ON person_la_memberships (person_id)
    WHERE ended_at IS NULL;

COMMIT;
