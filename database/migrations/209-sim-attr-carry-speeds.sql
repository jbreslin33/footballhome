-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 209: sim_attribute_registry seed for the ball-carry speed pair
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Adds the Slice 25.2 speed-hierarchy attributes at stable ids 11 and 12,
-- following the §22.9 hand-managed-integer pattern established by
-- migrations 200, 203, 208.
--
-- Attribute contracts (per DESIGN.md §23.3 Slice 25.2):
--
--   id=11  physical.max_dribble_speed
--          Ceiling m/s while owning the ball with NO sprint intent — i.e.
--          "dribble under control". Replaces the prior "walk × efficiency"
--          formula (which capped dribble at 1.7 m/s, a slow shuffle).
--          Realistic value: 4.0 m/s (fast walking / slow jog with the ball
--          at close feet-touch cadence).
--
--   id=12  physical.max_carry_sprint_speed
--          Ceiling m/s while owning the ball with wants_sprint asserted —
--          i.e. "sprint with ball". Before this slice, wants_sprint had no
--          effect once you owned the ball; you were capped at the dribble
--          speed regardless. Realistic value: 6.0 m/s (below the 7.5 m/s
--          no-ball sprint, because ball-touch cadence limits top speed).
--
-- Physics (Slice 25.2, BallControl.cpp fillOwnedFields):
--
--   base_speed  = wants_sprint ? max_carry_sprint_speed : max_dribble_speed
--   dribble_cap = base_speed * dribble_efficiency
--
-- dribble_efficiency (id=10, migration 208) is kept as a per-player
-- attenuation knob so future skill-differentiated profiles can slow down
-- weaker dribblers without changing the ceiling. Default = 0.85 (from
-- M0Attributes.cpp), so out-of-the-box effective caps are:
--   * dribble       = 4.0 × 0.85 = 3.4 m/s
--   * carry-sprint  = 6.0 × 0.85 = 5.1 m/s
--
-- Registry-id contract (§22.9):
--   * IDs are hand-managed integers ≥ 1.
--   * Every new attribute adds BOTH a DB row here AND a runtime constant
--     in sim/src/common/M0Registry.generated.hpp (auto-produced from
--     migrations 200 + 208 + 209 by sim/scripts/gen_registry_header.awk).
--   * sim_player_attribute.attr_id FKs into this table; ProfileStore uses
--     the stored id to reconstruct the per-person AttributeSet byte-for-
--     byte across replicas (rows loaded ORDER BY attr_id ASC).
--
-- ID assignments so far:
--    1..9 = migration 200 (physical baseline: max_walk_speed .. stamina_recovery_rate)
--   10    = physical.dribble_efficiency          (migration 208)
--   11    = physical.max_dribble_speed           (this migration)
--   12    = physical.max_carry_sprint_speed      (this migration)
--
-- Idempotent: `ON CONFLICT (key) DO NOTHING` makes reruns safe. The
-- setval at the end bumps the SMALLSERIAL sequence (dropped by migration
-- 203, but pg_get_serial_sequence still returns NULL cleanly — the
-- setval is skipped in that case via a NULL guard) past every hand-
-- assigned id so any accidental SERIAL-driven insert won't collide.
--
-- See:
--   sim/DESIGN.md §23.3 Slice 25.2 (speed hierarchy)
--   sim/src/common/M0Attributes.cpp (defaultPhysical extension)
--   sim/src/match/Mechanics.hpp (MechanicsParams extension)
--   sim/src/mechanics/BallControl.cpp (fillOwnedFields formula)
--   sim/scripts/gen_registry_header.awk (reads migrations 200 + 208 + 209)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

INSERT INTO sim_attribute_registry (id, key, category, weight, description) VALUES
    (11, 'physical.max_dribble_speed', 'physical', 1.0,
     'Ceiling m/s while owning the ball under control (no sprint intent)'),
    (12, 'physical.max_carry_sprint_speed', 'physical', 1.0,
     'Ceiling m/s while owning the ball WITH sprint intent asserted')
ON CONFLICT (key) DO NOTHING;

-- Migration 203 dropped the SMALLSERIAL sequence, so
-- pg_get_serial_sequence returns NULL here; guard the setval so the
-- migration doesn't error on a DB where the sequence is gone. If a
-- future migration re-adds it, bump past the last hand-assigned id.
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
-- Self-audit — belt AND suspenders (same pattern as migrations 204/207/208).
-- -----------------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sim_attribute_registry
                    WHERE key = 'physical.max_dribble_speed' AND id = 11) THEN
        RAISE EXCEPTION
            'migration 209 post-check failed: physical.max_dribble_speed is not at id=11';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM sim_attribute_registry
                    WHERE key = 'physical.max_carry_sprint_speed' AND id = 12) THEN
        RAISE EXCEPTION
            'migration 209 post-check failed: physical.max_carry_sprint_speed is not at id=12';
    END IF;
END $$;

COMMIT;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- End of migration 209.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
