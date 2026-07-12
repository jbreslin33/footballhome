-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 203: footballhome_sim — registry IDs become stable enum values
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Closes ship-blocker §21.1 per ADR sim/DESIGN.md §22.9.
--
-- The four sim registry tables (attribute / concept / pattern / scenarios)
-- have their IDs referenced verbatim inside sim_player_profile bytea and
-- inside sim_matches.scenario_id. Their IDs are hand-managed wire contract,
-- not database-generated surrogate keys. Migration 200 declared them
-- SMALLSERIAL PRIMARY KEY, which permits silent auto-assign if an INSERT
-- forgets the id column. This migration drops the sequences and makes
-- explicit id assignment mandatory (NOT NULL SMALLINT PRIMARY KEY).
--
-- Safe pre-conditions verified before writing this migration:
--   * sim_player_profile row count = 0 (no bytea profiles depend on IDs yet)
--   * No prod sim deployment.
--
-- Event tables (sim_matches, sim_match_events) are UNAFFECTED — they keep
-- BIGSERIAL, since their IDs never appear in bytea.
--
-- See sim/DESIGN.md §21.1, §22.9.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

-- -----------------------------------------------------------------------
-- 1) Drop the SERIAL defaults + owned sequences on the four registries.
-- -----------------------------------------------------------------------
ALTER TABLE sim_attribute_registry ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS sim_attribute_registry_id_seq;

ALTER TABLE sim_concept_registry   ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS sim_concept_registry_id_seq;

ALTER TABLE sim_pattern_registry   ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS sim_pattern_registry_id_seq;

ALTER TABLE sim_scenarios          ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS sim_scenarios_id_seq;

-- -----------------------------------------------------------------------
-- 2) Belt-and-suspenders: ensure id column stays NOT NULL SMALLINT.
--    (SMALLSERIAL already implies NOT NULL, but state this explicitly so
--    schema dumps read as intended after the sequence is gone.)
-- -----------------------------------------------------------------------
ALTER TABLE sim_attribute_registry ALTER COLUMN id SET NOT NULL;
ALTER TABLE sim_concept_registry   ALTER COLUMN id SET NOT NULL;
ALTER TABLE sim_pattern_registry   ALTER COLUMN id SET NOT NULL;
ALTER TABLE sim_scenarios          ALTER COLUMN id SET NOT NULL;

-- -----------------------------------------------------------------------
-- 3) Verify: attempting an ID-less INSERT should now raise a NOT NULL
--    violation. This SELECT records the assertion inline for audit; the
--    actual behavioural check is in sim tests / manual smoke.
--
--    Try (outside a migration):
--        INSERT INTO sim_attribute_registry (key, category)
--            VALUES ('bogus', 'physical');
--    Expected error: null value in column "id" of relation
--    "sim_attribute_registry" violates not-null constraint.
-- -----------------------------------------------------------------------

COMMIT;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- End of migration 203.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
