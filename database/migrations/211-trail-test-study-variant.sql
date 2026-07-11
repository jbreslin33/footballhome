-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 211: Trail Test — replace 'kids' variant with 'study' (16-node)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Product decision: the "kids (10)" variant was an arbitrary ramp with
-- no published protocol behind it. Replacing it with a 16-node "study"
-- variant that mirrors the D-KEFS Trail Making Test structure used in
-- the Vestberg (2012) soccer executive-function research:
--
--   Part A: numbers 1..16  (single-category sequencing)
--   Part B: 1-A-2-B-...-8-H  (16 nodes, 8 numbers + 8 letters, equal split)
--
-- 25-node 'standard' variant (classic Reitan TMT) is unchanged.
--
-- Safe because no live rows use 'kids' — the results table was empty
-- at the point this migration ran (only local smoke-test rows existed
-- and were deleted).
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

-- Belt-and-braces: if any 'kids' rows slipped in, rename them to
-- 'study' so the new CHECK doesn't reject them.  Idempotent.
UPDATE trail_test_results  SET variant = 'study' WHERE variant = 'kids';
UPDATE trail_test_attempts SET variant = 'study' WHERE variant = 'kids';

ALTER TABLE trail_test_results
    DROP CONSTRAINT IF EXISTS trail_test_results_variant_check;
ALTER TABLE trail_test_results
    ADD CONSTRAINT trail_test_results_variant_check
    CHECK (variant IN ('study','standard'));

ALTER TABLE trail_test_attempts
    DROP CONSTRAINT IF EXISTS trail_test_attempts_variant_check;
ALTER TABLE trail_test_attempts
    ADD CONSTRAINT trail_test_attempts_variant_check
    CHECK (variant IN ('study','standard'));

COMMIT;
