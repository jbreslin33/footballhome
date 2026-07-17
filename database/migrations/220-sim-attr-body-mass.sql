-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 220: sim_attribute_registry seed for physical.body_mass
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Slice 27.3 (third slice of the M2 player-player collision chain per
-- DESIGN.md §24.3 / §24.5 Slice 27, ADR §22.24 drafted 2026-07-17). Adds
-- the attribute row that governs the split ratio when two players
-- overlap in `BasicPhysics::step`. Follows the §22.9 hand-managed-
-- integer pattern established by migrations 200 / 208 / 209 / 216 / 217.
--
-- Attribute contract (per ADR §22.24 "Attribute contract" section):
--   * key         = 'physical.body_mass'
--   * category    = 'physical'
--   * weight      = 1.0                     (uniform in M1)
--   * default val = 1.0                     (see m0::defaultPhysical() in
--                                            sim/src/common/M0Attributes.cpp)
--   * runtime clamp = [0.5, 1.5]            (enforced by BasicPhysics::step
--                                            in Slice 27.2)
--
-- Semantics: relative body mass used by the positional-clamp +
-- tangential-slide collision resolver (ADR §22.24 option B). When two
-- players overlap by penetration `p`, entity a is displaced by
-- `p × b.body_mass / (a.body_mass + b.body_mass)` along the normal and
-- entity b by the symmetric term — Newton's inverse-mass convention.
-- Equal masses (both at default 1.0) each move p/2. A defender at 1.5
-- vs an attacker at 1.0 is displaced only 40% of the penetration per
-- contact. Values outside [0.5, 1.5] are silently clamped at read time
-- so a mis-authored profile can't destabilise the resolver.
--
-- Determinism impact (this migration, Slice 27.3):
--   NONE. The attribute is added and the runtime constant kBodyMass is
--   emitted into M0Registry.generated.hpp, but NO code path reads the
--   value yet — `BasicPhysics::step` lands in Slice 27.2 as the first
--   consumer. All 50 determinism goldens (Wander200, HumanSprint400,
--   BallRoll400, Dribble200, FirstTouch200, HalfPitchHard400,
--   SoftDrill400, BallOnPitchWithDefender400, PassEast400,
--   PassReceive200, GoalFromKickEast200) stay byte-identical after this
--   slice. Slice 27.4 is the byte-changing slice — it rotates three
--   existing goldens (FirstTouch200, BallOnPitchWithDefender400, and
--   verifies Dribble200 / PassEast400 / PassReceive200) once
--   BasicPhysics is wired into the Match factory in Slice 27.2.
--
--   No canonical-hash lock exists on `m0::defaultPhysical()` output as
--   of 2026-07-17, so growing the AttributeSet by one row cannot
--   perturb any test (verified 2026-07-17 by grepping sim/tests for
--   'defaultPhysical.*hash' and 'attribute.*hash' — zero matches).
--
-- Registry-id contract (§22.9):
--   * Hand-managed integer id.
--   * Every new attribute adds BOTH a DB row here AND a runtime
--     constant in sim/src/common/M0Registry.generated.hpp (auto-produced
--     by sim/scripts/gen_registry_header.awk from migrations
--     200 + 208 + 209 + 216 + 217 + 220).
--
-- ID assignments so far:
--    1..9  = migration 200 (physical baseline)
--   10     = physical.dribble_efficiency       (migration 208)
--   11     = physical.max_dribble_speed        (migration 209)
--   12     = physical.max_carry_sprint_speed   (migration 209)
--   13     = physical.press_resistance         (migration 216)
--   14     = physical.pass_power               (migration 217)
--   15     = physical.body_mass                (this migration)
--
-- Idempotent: ON CONFLICT (key) DO NOTHING makes reruns safe.
--
-- Migration number 220 was reserved as the gap between the Slice 26
-- attribute chain (217) and the Slice 28 event-schema chain (221 goal
-- event decoder, 222 goal-drill scenario). Attribute-registry additions
-- get low numbers to keep the CMake generator include list contiguous
-- with the other attr migrations.
--
-- See:
--   sim/DESIGN.md §22.24 (ADR — player-player collision resolution)
--   sim/DESIGN.md §24.3 Slice 27
--   sim/DESIGN.md §24.5 Slice 27.3
--   sim/src/common/M0Attributes.cpp (defaultPhysical extension)
--   sim/scripts/gen_registry_header.awk (reads migrations 200+208+209+216+217+220)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

INSERT INTO sim_attribute_registry (id, key, category, weight, description) VALUES
    (15, 'physical.body_mass', 'physical', 1.0,
     'Relative body mass (default 1.0, runtime-clamped to [0.5, 1.5]) used by BasicPhysics::step to split the positional-clamp displacement between two colliding entities via Newtons inverse-mass convention. Consumed in Slice 27.2 (ADR §22.24).')
ON CONFLICT (key) DO NOTHING;

-- Same guarded setval as migrations 208 / 216 / 217: sequence may or
-- may not exist depending on which migration path the DB has been
-- through.
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
-- 204/207/208/216/217).
-- -----------------------------------------------------------------------
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sim_attribute_registry
                    WHERE key = 'physical.body_mass' AND id = 15) THEN
        RAISE EXCEPTION
            'migration 220 post-check failed: physical.body_mass is not at id=15';
    END IF;
END $$;

COMMIT;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- End of migration 220.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
