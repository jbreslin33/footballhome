-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 225: sim_concept_registry seed for 'marking' + 'jockey'
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Adds the next M3 defensive concepts at stable ids 4 and 5, following
-- the §22.9 hand-managed-integer pattern established by migrations 200 + 224.
--
-- Concept contract:
--   * key      = 'marking' / 'jockey'
--   * category = 'defensive'
--   * weight   = 1.0
--   * description = human-readable role
--
-- Runtime meaning:
--   These concepts gate the first defender behaviors in Slice 31:
--   - marking : used by MarkOpponentBehavior
--   - jockey  : used by JockeyBehavior
--
-- Registry-id contract (§22.9):
--   * IDs are hand-managed integers ≥ 1.
--   * Every new concept adds BOTH a DB row here AND a runtime constant
--     in sim/src/common/M0Registry.generated.hpp (auto-produced from
--     migrations 200 + 208 + 209 + 216 + 217 + 220 + 224 + 225 by
--     sim/scripts/gen_registry_header.awk).
--
-- Concept-id assignments so far:
--    1 = run_to_point   (migration 200, movement) — M0 baseline
--    2 = <unused>       (reserved gap — no historical claim)
--    3 = pressing       (migration 224, defensive) — first M3 concept
--    4 = marking        (this migration, defensive)
--    5 = jockey         (this migration, defensive)
--
-- Idempotent: ON CONFLICT (key) DO NOTHING makes reruns safe.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

INSERT INTO sim_concept_registry (id, key, category, weight, description) VALUES
    (4, 'marking', 'defensive', 1.0,
     'Presence-gate concept for MarkOpponentBehavior — a slot with marking
 plugged into its ConceptSet will shadow a designated opponent'),
    (5, 'jockey', 'defensive', 1.0,
     'Presence-gate concept for JockeyBehavior — a slot with jockey
 plugged into its ConceptSet will backpedal + shepherd a dribbling ball carrier
 away from goal')
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

-- Self-audit for the new concept IDs.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sim_concept_registry
                   WHERE key = 'marking' AND id = 4) THEN
        RAISE EXCEPTION 'migration 225 post-check failed: marking is not at id=4';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM sim_concept_registry
                   WHERE key = 'jockey' AND id = 5) THEN
        RAISE EXCEPTION 'migration 225 post-check failed: jockey is not at id=5';
    END IF;
END $$;

COMMIT;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- End of migration 225.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
