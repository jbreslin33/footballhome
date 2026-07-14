-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 208: sim_attribute_registry seed for physical.dribble_efficiency
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Adds the M1 dribble-mechanics attribute at stable id=10, following the
-- §22.9 hand-managed-integer pattern established by migrations 200 + 203.
--
-- Attribute contract (per DESIGN.md §23.3 Slice 16.1 + draft ADR §22.21):
--   * key         = 'physical.dribble_efficiency'
--   * category    = 'physical'
--   * weight      = 1.0                     (uniform in M1; per-player
--                                            distribution lands in M3 with
--                                            AiController-tunable profiles)
--   * description = human-readable role
--   * default val = 0.85  (Fixed64 in [0,1]; see m0::defaultPhysical() in
--                          sim/src/common/M0Attributes.cpp — matches the
--                          DESIGN.md §23.3 target. The value is not read
--                          by any mechanic in Slice 16.1; Slice 16.3's
--                          BallControl.cpp will pipe it into
--                          MechanicsParams as `dribble_speed_cap =
--                          max_walk_speed * dribble_efficiency`.)
--
-- Registry-id contract (§22.9):
--   * IDs are hand-managed integers ≥ 1.
--   * Every new attribute adds BOTH a DB row here AND a runtime constant
--     in sim/src/common/M0Registry.generated.hpp (auto-produced from
--     migrations 200 + 208 by sim/scripts/gen_registry_header.awk).
--   * sim_player_attribute.attr_id FKs into this table; ProfileStore uses
--     the stored id to reconstruct the per-person AttributeSet byte-for-
--     byte across replicas (rows loaded ORDER BY attr_id ASC).
--
-- ID assignments so far:
--    1..9 = migration 200 (physical baseline: max_walk_speed .. stamina_recovery_rate)
--   10    = physical.dribble_efficiency   (this migration)
--
-- Idempotent: `ON CONFLICT (key) DO NOTHING` makes reruns safe. The
-- setval at the end bumps the SMALLSERIAL sequence (dropped by migration
-- 203, but pg_get_serial_sequence still returns NULL cleanly — the
-- setval is skipped in that case via COALESCE) past every hand-assigned
-- id so any accidental SERIAL-driven insert won't collide.
--
-- See:
--   sim/DESIGN.md §23.3 Slice 16.1
--   sim/DESIGN.md §22.21 (draft ADR — landed alongside Slice 16.3 mechanic)
--   sim/src/common/M0Attributes.cpp (defaultPhysical extension)
--   sim/scripts/gen_registry_header.awk (reads migration 200 + 208)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

INSERT INTO sim_attribute_registry (id, key, category, weight, description) VALUES
    (10, 'physical.dribble_efficiency', 'physical', 1.0,
     'Fraction in [0,1] scaling walk-speed cap while carrying the ball')
ON CONFLICT (key) DO NOTHING;

-- Migration 203 dropped the SMALLSERIAL sequence, so
-- pg_get_serial_sequence returns NULL here; guard the setval with a
-- CASE so the migration doesn't error if run on a DB where the
-- sequence is gone. If the sequence has been re-added by a future
-- migration, bump it past the last hand-assigned id.
DO $$
DECLARE
    seq_name TEXT;
BEGIN
    seq_name := pg_get_serial_sequence('sim_attribute_registry', 'id');
    IF seq_name IS NOT NULL THEN
        PERFORM setval(seq_name,
                       GREATEST((SELECT MAX(id) FROM sim_attribute_registry), 1));
    END IF;
END $$;

-- -----------------------------------------------------------------------
-- Self-audit — belt AND suspenders (same pattern as migrations 204/207).
-- -----------------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sim_attribute_registry
                    WHERE key = 'physical.dribble_efficiency' AND id = 10) THEN
        RAISE EXCEPTION
            'migration 208 post-check failed: physical.dribble_efficiency is not at id=10';
    END IF;
END $$;

COMMIT;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- End of migration 208.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
