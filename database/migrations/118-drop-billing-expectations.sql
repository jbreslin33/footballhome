-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 118: Drop the abandoned billing_expectations subsystem.
--
-- Migration 090 introduced a per-Friday projected/actual invoice line
-- table (billing_expectations), fed by the BillingProjector service and
-- exposed via BillingController at /api/billing/*.  The frontend never
-- consumed it — the payments card was ultimately rewritten to read the
-- normalized `next_due_at` column on person_la_memberships (migration
-- 117) instead.  All backing C++ files were deleted in the same commit
-- as this migration.
--
-- Nothing outside the dead trio references this table, so dropping is
-- safe.  Rebuildable from LA at any time if we ever want it back.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

DROP TRIGGER IF EXISTS billing_expectations_touch ON billing_expectations;
DROP FUNCTION IF EXISTS billing_expectations_touch_updated_at();
DROP INDEX  IF EXISTS billing_expectations_open_idx;
DROP INDEX  IF EXISTS billing_expectations_user_idx;
DROP INDEX  IF EXISTS billing_expectations_unpaid_idx;
DROP TABLE  IF EXISTS billing_expectations;

COMMIT;
