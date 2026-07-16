-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 216: sim_attribute_registry seed for physical.press_resistance
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Adds the Slice 24.3b touch-to-steal attribute at stable id=13, following
-- the §22.9 hand-managed-integer pattern established by migrations 200 /
-- 208 / 209.
--
-- Attribute contract (per DESIGN.md §23.3 Slice 24.3b):
--   * key         = 'physical.press_resistance'
--   * category    = 'physical'
--   * weight      = 1.0                     (uniform in M1)
--   * default val = 0.75  (Fixed64 in [0,1]; see m0::defaultPhysical() in
--                          sim/src/common/M0Attributes.cpp)
--
-- Semantics: rating in [0,1] describing how strongly a defender can
-- destabilize an opposing dribbler when in contest range of the ball.
-- BallControl computes a per-tick contest outcome by comparing the
-- current owner's `physical.dribble_efficiency` (attr 10) against the
-- closest non-owner presser's `physical.press_resistance`. Higher
-- press_resistance ⇒ more likely to strip. Default 0.75 is deliberately
-- below the default dribble_efficiency (0.85) so a default defender
-- against a default attacker does NOT strip — a defender needs to be
-- genuinely more resistant than the attacker's carry skill to win the
-- contest. This preserves the M0 canonical goldens (no default profile
-- interacts differently) while giving future scenarios room to demo
-- either outcome by biasing the two attributes.
--
-- Registry-id contract (§22.9):
--   * Hand-managed integer id.
--   * Every new attribute adds BOTH a DB row here AND a runtime
--     constant in sim/src/common/M0Registry.generated.hpp (auto-produced
--     by sim/scripts/gen_registry_header.awk from migrations
--     200 + 208 + 209 + 216).
--
-- ID assignments so far:
--    1..9  = migration 200 (physical baseline)
--   10     = physical.dribble_efficiency       (migration 208)
--   11     = physical.max_dribble_speed        (migration 209)
--   12     = physical.max_carry_sprint_speed   (migration 209)
--   13     = physical.press_resistance         (this migration)
--
-- Idempotent: ON CONFLICT (key) DO NOTHING makes reruns safe.
--
-- See:
--   sim/DESIGN.md §23.3 Slice 24.3b
--   sim/src/common/M0Attributes.cpp (defaultPhysical extension)
--   sim/src/mechanics/BallControl.cpp (contest logic)
--   sim/scripts/gen_registry_header.awk (reads migrations 200+208+209+216)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

INSERT INTO sim_attribute_registry (id, key, category, weight, description) VALUES
    (13, 'physical.press_resistance', 'physical', 1.0,
     'Rating in [0,1] weighting a defender''s ability to strip an opposing dribbler while within contest range of the ball')
ON CONFLICT (key) DO NOTHING;

-- Same guarded setval as migration 208: sequence may or may not exist
-- depending on which migration path the DB has been through.
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
                    WHERE key = 'physical.press_resistance' AND id = 13) THEN
        RAISE EXCEPTION
            'migration 216 post-check failed: physical.press_resistance is not at id=13';
    END IF;
END $$;

COMMIT;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- End of migration 216.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
