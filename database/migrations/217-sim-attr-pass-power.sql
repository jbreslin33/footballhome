-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 217: sim_attribute_registry seed for physical.pass_power
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Slice 26.1 (first slice of the M2 short-pass primitive per DESIGN.md
-- §24.3 Slice 26). Adds the attribute row that governs the initial ball
-- speed when a player asserts `Intent::wants_kick` (landing in Slice
-- 26.2). Follows the §22.9 hand-managed-integer pattern established by
-- migrations 200 / 208 / 209 / 216.
--
-- Attribute contract (per DESIGN.md §24.2 / §24.3 Slice 26.1):
--   * key         = 'physical.pass_power'
--   * category    = 'physical'
--   * weight      = 1.0                     (uniform in M1)
--   * default val = 15.0  m/s               (see m0::defaultPhysical() in
--                                            sim/src/common/M0Attributes.cpp)
--
-- Semantics: initial magnitude (m/s) of the impulse imparted to the ball
-- when this player fires a short pass — i.e. `ball.velocity = direction
-- × pass_power` at the tick the kick is accepted. Only the DEFAULT
-- (15 m/s) matters for M2's demo scenarios; per-player biasing arrives
-- when the profile editor lands (deferred per §24.5 non-goals). The
-- attribute is a physical velocity, not a rating in [0,1], matching the
-- other velocity-typed attributes in the registry (max_walk_speed,
-- max_jog_speed, max_sprint_speed, max_dribble_speed,
-- max_carry_sprint_speed).
--
-- Determinism impact (this migration, Slice 26.1):
--   NONE. The attribute is added and the runtime constant kPassPower is
--   emitted into M0Registry.generated.hpp, but NO code path reads the
--   value yet. Slice 26.3 introduces BallControl release-on-kick +
--   BallPhysics::applyImpulse which will be the first consumer. All 47
--   determinism goldens (Wander200, HumanSprint400, BallRoll400,
--   Dribble200, FirstTouch200, HalfPitchHard400, SoftDrill400,
--   BallOnPitchWithDefender400, and the M0 canonical hash) stay
--   byte-identical after this slice.
--
-- Registry-id contract (§22.9):
--   * Hand-managed integer id.
--   * Every new attribute adds BOTH a DB row here AND a runtime
--     constant in sim/src/common/M0Registry.generated.hpp (auto-produced
--     by sim/scripts/gen_registry_header.awk from migrations
--     200 + 208 + 209 + 216 + 217).
--
-- ID assignments so far:
--    1..9  = migration 200 (physical baseline)
--   10     = physical.dribble_efficiency       (migration 208)
--   11     = physical.max_dribble_speed        (migration 209)
--   12     = physical.max_carry_sprint_speed   (migration 209)
--   13     = physical.press_resistance         (migration 216)
--   14     = physical.pass_power               (this migration)
--
-- Idempotent: ON CONFLICT (key) DO NOTHING makes reruns safe.
--
-- See:
--   sim/DESIGN.md §24.2 (M2 deliverables — short-pass primitive)
--   sim/DESIGN.md §24.3 Slice 26.1
--   sim/src/common/M0Attributes.cpp (defaultPhysical extension)
--   sim/scripts/gen_registry_header.awk (reads migrations 200+208+209+216+217)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

INSERT INTO sim_attribute_registry (id, key, category, weight, description) VALUES
    (14, 'physical.pass_power', 'physical', 1.0,
     'Initial ball speed (m/s) when this player kicks a short pass; consumed by BallPhysics::applyImpulse in Slice 26.3')
ON CONFLICT (key) DO NOTHING;

-- Same guarded setval as migrations 208 / 216: sequence may or may not
-- exist depending on which migration path the DB has been through.
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
-- Self-audit — belt AND suspenders (same pattern as migrations
-- 204/207/208/216).
-- -----------------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sim_attribute_registry
                    WHERE key = 'physical.pass_power' AND id = 14) THEN
        RAISE EXCEPTION
            'migration 217 post-check failed: physical.pass_power is not at id=14';
    END IF;
END $$;

COMMIT;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- End of migration 217.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
