-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 205: footballhome_sim — normalize sim_player_profile storage
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Closes DESIGN.md ADR §22.18 (new — normalize sim_player_profile storage).
-- §22.14 write policy (first-touch INSERT only in M0) is UNCHANGED and
-- still enforced by sim/scripts/check_profile_write_policy.sh — the policy
-- just now targets 4 tables instead of 1 (the child rows land inside the
-- same transaction as the parent INSERT, so first-touch semantics survive
-- verbatim).
--
-- Preconditions verified before writing this migration (2026-07-13):
--   * sim_player_profile: 0 rows → no data migration needed.
--   * sim_matches: 1 row → not touched by this migration.
--   * sim_attribute_registry / sim_concept_registry / sim_pattern_registry:
--     rows have stable explicit ids (migration 203) → FKs work cleanly.
--   * No other sim table references sim_player_profile → DROP is safe.
--
-- If sim_player_profile ever gains rows before this migration is applied,
-- STOP and write a data migration before dropping the table. The
-- production DB always has 0 rows in M0 (§22.14 first-touch semantics
-- means rows only appear after a real client connects, which the
-- footballhome_sim service does not do in unattended startup).
--
-- What changes:
--   1. DROP the 3 bytea-payload sim_decode_* helpers from migration 201
--      (sim_decode_attributes / sim_decode_concepts / sim_decode_recognition).
--      They only made sense for the bytea-in-profile world; after this
--      migration the equivalent view is a plain JOIN against the registry
--      tables. The other two helpers (sim_decode_input, sim_decode_event)
--      still decode sim_match_inputs.payload and sim_match_events.payload
--      which stay bytea (immutable wire audit rows) — those are kept.
--   2. DROP sim_player_profile (the 4-column bytea version).
--   3. CREATE sim_player_profile (parent, person_id + updated_at only).
--   4. CREATE sim_player_attribute / sim_player_concept / sim_player_recognition
--      (child tables, FK to parent + FK to matching registry, ordered
--      queries deterministic via primary key on the id column).
--
-- What does NOT change:
--   * sim_matches / sim_match_inputs / sim_match_events schemas (untouched).
--   * The three registry tables (untouched).
--   * §22.14 write policy (still first-touch INSERT only).
--   * sim_decode_input / sim_decode_event / sim_read_f32_le / sim_event_type_name
--     helpers (kept — they decode wire audit rows, not profile columns).
--   * Runtime wire protocol (§7): sim_player_profile is a persistence
--     concern only; the wire never carried attribute bytes. Confirmed via
--     `grep -RIn AttributeSet sim/src/net/` → zero matches.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

-- -----------------------------------------------------------------------
-- 1) Drop the three attribute/concept/recognition decode helpers from
--    migration 201. Their input was `sim_player_profile.*` bytea columns;
--    after this migration those columns don't exist. Ops queries that
--    previously invoked `sim_decode_attributes(payload)` now use a plain
--    JOIN against sim_attribute_registry (see verification path in the
--    handoff / DESIGN.md §8 usage examples).
--
--    DROP FUNCTION ... IF EXISTS keeps the migration re-runnable and safe
--    against manual DROPs performed during ad-hoc ops.
-- -----------------------------------------------------------------------
DROP FUNCTION IF EXISTS sim_decode_attributes(BYTEA);
DROP FUNCTION IF EXISTS sim_decode_concepts(BYTEA);
DROP FUNCTION IF EXISTS sim_decode_recognition(BYTEA);

-- -----------------------------------------------------------------------
-- 2) Precondition guard: refuse to run if the old table has rows.
--    Migration is safe under the M0 invariant (0 rows in the wild) but
--    a re-run on a populated DB would silently DROP data — fail loud
--    instead.
-- -----------------------------------------------------------------------
DO $$
DECLARE
    row_count BIGINT;
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'sim_player_profile'
    ) THEN
        SELECT COUNT(*) INTO row_count FROM sim_player_profile;
        IF row_count > 0 THEN
            RAISE EXCEPTION
                'migration 205 refuses to run: sim_player_profile has % row(s). '
                'Write a data migration to translate bytea payloads into '
                'sim_player_attribute / sim_player_concept / '
                'sim_player_recognition rows before dropping the old table.',
                row_count;
        END IF;
    END IF;
END $$;

-- -----------------------------------------------------------------------
-- 3) Drop the old sim_player_profile (bytea layout from migration 200).
-- -----------------------------------------------------------------------
DROP TABLE IF EXISTS sim_player_profile;

-- -----------------------------------------------------------------------
-- 4) Recreate sim_player_profile as the parent (per-person envelope,
--    no payload of its own; children hold the values).
--
--    person_id is INTEGER to match persons.id (SERIAL, INTEGER in this
--    DB — see migration 021). DESIGN.md §8 shows BIGINT aspirationally;
--    matching persons.id exactly avoids a FK type mismatch.
-- -----------------------------------------------------------------------
CREATE TABLE sim_player_profile (
    person_id  INTEGER PRIMARY KEY REFERENCES persons(id) ON DELETE CASCADE,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE sim_player_profile IS
    'Parent envelope for a person''s sim profile. Actual attribute/concept/'
    'recognition values live in sim_player_attribute / sim_player_concept / '
    'sim_player_recognition. First-touch INSERT-only per §22.14 write policy '
    '(enforced by sim/scripts/check_profile_write_policy.sh in the sim CI '
    'gate). updated_at stays equal to created_at through all of M0 as a '
    'smoke check for the write policy.';

-- -----------------------------------------------------------------------
-- 5) Attributes child table (physical / technical / mental scalars).
--
--    (person_id, attr_id) primary key means each attribute appears at
--    most once per person. attr_id FK to sim_attribute_registry means
--    stale profile rows referencing a deleted registry entry are
--    impossible — Postgres refuses the write (§22.9 stable-id invariant
--    prevents this in practice, but the FK is defence in depth).
--
--    value REAL matches DESIGN.md §8 / §5.2 — the on-disk representation
--    is f32; the sim runtime converts to Fixed64 at load time. Rows are
--    read `ORDER BY attr_id ASC` in PgClient::loadProfile so a byte-
--    identical PlayerProfile is reproduced across replicas.
-- -----------------------------------------------------------------------
CREATE TABLE sim_player_attribute (
    person_id INTEGER  NOT NULL
              REFERENCES sim_player_profile(person_id) ON DELETE CASCADE,
    attr_id   SMALLINT NOT NULL
              REFERENCES sim_attribute_registry(id),
    value     REAL     NOT NULL,
    PRIMARY KEY (person_id, attr_id)
);
CREATE INDEX sim_player_attribute_by_attr_idx
    ON sim_player_attribute (attr_id);

COMMENT ON TABLE sim_player_attribute IS
    'One row per (person, attribute). Loaded ORDER BY attr_id ASC so the '
    'reconstructed AttributeSet is byte-identical across replicas.';

-- -----------------------------------------------------------------------
-- 6) Concepts child table (learned AI behaviors + mastery).
-- -----------------------------------------------------------------------
CREATE TABLE sim_player_concept (
    person_id  INTEGER  NOT NULL
               REFERENCES sim_player_profile(person_id) ON DELETE CASCADE,
    concept_id SMALLINT NOT NULL
               REFERENCES sim_concept_registry(id),
    mastery    REAL     NOT NULL,
    PRIMARY KEY (person_id, concept_id)
);
CREATE INDEX sim_player_concept_by_concept_idx
    ON sim_player_concept (concept_id);

COMMENT ON TABLE sim_player_concept IS
    'One row per (person, concept). Loaded ORDER BY concept_id ASC so the '
    'reconstructed ConceptSet is byte-identical across replicas.';

-- -----------------------------------------------------------------------
-- 7) Recognition child table (perception pattern skill; empty in M0).
-- -----------------------------------------------------------------------
CREATE TABLE sim_player_recognition (
    person_id  INTEGER  NOT NULL
               REFERENCES sim_player_profile(person_id) ON DELETE CASCADE,
    pattern_id SMALLINT NOT NULL
               REFERENCES sim_pattern_registry(id),
    skill      REAL     NOT NULL,
    PRIMARY KEY (person_id, pattern_id)
);
CREATE INDEX sim_player_recognition_by_pattern_idx
    ON sim_player_recognition (pattern_id);

COMMENT ON TABLE sim_player_recognition IS
    'One row per (person, pattern). Loaded ORDER BY pattern_id ASC so the '
    'reconstructed RecognitionSet is byte-identical across replicas. '
    'Empty in M0 — no rows in sim_pattern_registry until M4.';

COMMIT;
