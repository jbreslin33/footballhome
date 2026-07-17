-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 224: sim_concept_registry seed for 'pressing'
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Adds the first M3 concept at stable id=3, following the §22.9 hand-
-- managed-integer pattern established by migrations 200 + 208 for
-- attributes and by migration 200's `run_to_point` (id=1) for concepts.
--
-- Concept contract (per DESIGN.md §25.2 debug-replay bullet 4, §25.3 Slice 30.2):
--   * key         = 'pressing'
--   * category    = 'defensive'   (first row in this category)
--   * weight      = 1.0           (uniform in M3 opening; per-slot
--                                   mastery-driven weighting lands
--                                   with the M3 attribute batch in
--                                   Slice 31.3 / migration 226)
--   * description = human-readable role
--
-- Runtime meaning:
--   Presence of `pressing` in a slot's ConceptSet gates
--   `PursueBallCarrierBehavior` (Slice 30.2). `ConceptSet::has(id, min)`
--   returns TRUE when the concept is present at any value ≥ min; with
--   minMastery = 0 the behavior is presence-gated, not skill-gated.
--   Slice 30.2 wires the concept into the defender slot's ConceptSet
--   via `Scenario::applyConceptOverrides` — no change to
--   `m0::defaultConcepts()` so the 11 non-defender determinism goldens
--   stay byte-identical.
--
-- Registry-id contract (§22.9):
--   * IDs are hand-managed integers ≥ 1.
--   * Every new concept adds BOTH a DB row here AND a runtime constant
--     in sim/src/common/M0Registry.generated.hpp (auto-produced from
--     migrations 200 + 208 + 209 + 216 + 217 + 220 + 224 by
--     sim/scripts/gen_registry_header.awk).
--   * sim_player_concept.concept_id FKs into this table.
--
-- Concept-id assignments so far:
--    1 = run_to_point   (migration 200, movement) — M0 baseline
--    2 = <unused>       (reserved gap — no historical claim)
--    3 = pressing       (this migration, defensive) — first M3 concept
--
-- Migration slot 223 was taken by the parallel OOP-LA-sync work
-- (223-external-aliases-drop-name-uniqueness.sql, unrelated to sim),
-- so the M3 concept schedule shifts up one slot from the original §25
-- reservation. Follow-on M3 concept migrations per §25.2:
--    225 = marking + jockey   (Slice 31.1)
--    227 = 1v1_beat           (Slice 33.1)
--
-- Idempotent: `ON CONFLICT (key) DO NOTHING` makes reruns safe. The
-- setval at the end is guarded the same way as migrations 208/216 —
-- pg_get_serial_sequence may return NULL after migration 203 dropped
-- the sequence.
--
-- See:
--   sim/DESIGN.md §25.2 debug-replay bullet 4 (Slice 30.2 concept spec)
--   sim/DESIGN.md §25.3 Slice 30.2 (deliverable list)
--   sim/src/behavior/PursueBallCarrierBehavior.{hpp,cpp} (consumer)
--   sim/scripts/gen_registry_header.awk (reads migration 224 as part
--     of the M0 registry generator chain)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

INSERT INTO sim_concept_registry (id, key, category, weight, description) VALUES
    (3, 'pressing', 'defensive', 1.0,
     'Presence-gate concept for PursueBallCarrierBehavior — a slot with pressing plugged into its ConceptSet will chase the ball carrier every tick')
ON CONFLICT (key) DO NOTHING;

-- Same guarded setval as migrations 208/216: the SMALLSERIAL sequence
-- was dropped by migration 203; pg_get_serial_sequence returns NULL in
-- that case and we skip the bump cleanly.
DO $$
DECLARE
    seq_name TEXT;
BEGIN
    seq_name := pg_get_serial_sequence('sim_concept_registry', 'id');
    IF seq_name IS NOT NULL THEN
        PERFORM setval(seq_name,
                       GREATEST((SELECT MAX(id) FROM sim_concept_registry), 1));
    END IF;
END $$;

-- -----------------------------------------------------------------------
-- Self-audit — belt AND suspenders (same pattern as migrations 204/207/208/216).
-- -----------------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sim_concept_registry
                    WHERE key = 'pressing' AND id = 3) THEN
        RAISE EXCEPTION
            'migration 224 post-check failed: pressing is not at id=3';
    END IF;
END $$;

COMMIT;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- End of migration 224.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
