-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 229: sim_concept_registry seed for '1v1_beat'
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Slice 33.1: adds the first M3 on-ball attacker concept at stable id=6.
-- Migration slots 227 and 228 were taken by non-sim work, so this lands
-- in the next available slot while preserving the concept id promised by
-- the M3 design.
--
-- Runtime meaning:
--   Presence of `1v1_beat` in a slot's ConceptSet gates
--   Feint1v1Behavior (Slice 33.2). The behavior consumes the already-
--   seeded technical.feint and mental.composure attributes from migration
--   226.
--
-- Idempotent: ON CONFLICT (key) DO NOTHING makes reruns safe.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

INSERT INTO sim_concept_registry (id, key, category, weight, description) VALUES
    (6, '1v1_beat', 'on_ball', 1.0,
     'Presence-gate concept for Feint1v1Behavior — a ball carrier with 1v1_beat plugged into its ConceptSet can attempt a lateral feint to beat one defender')
ON CONFLICT (key) DO NOTHING;

-- Same guarded setval as other registry migrations.
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

-- Self-audit for the new concept ID.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sim_concept_registry
                   WHERE key = '1v1_beat' AND id = 6) THEN
        RAISE EXCEPTION 'migration 229 post-check failed: 1v1_beat is not at id=6';
    END IF;
END $$;

COMMIT;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- End of migration 229.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
