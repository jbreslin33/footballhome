-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 270: months_overdue snapshot on person_la_memberships
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Payments-screen player cards need to bucket members by how many months
-- behind they are (owner directive 2026-08-08), computed from LA's
-- authoritative outstandingBalance (not a locally-derived total) so it's
-- correct for active AND inactive-tier members alike.
--
-- Written by LaProgramSync's per-sync snapshot flush (same place that
-- already writes la_amount_owed_cents/la_amount_paid_cents/
-- la_payment_status), as:
--     months_overdue = ceil(outstandingBalance / PersonPayments::kMonthlyDuesUsd)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

ALTER TABLE person_la_memberships
    ADD COLUMN IF NOT EXISTS months_overdue integer;

COMMENT ON COLUMN person_la_memberships.months_overdue IS
    'ceil(LA outstandingBalance / monthly dues rate) at last LA sync snapshot. NULL until first synced.';

COMMIT;
