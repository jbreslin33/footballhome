-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 117: Normalized billing due-date on person_la_memberships
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Divorces "how much they owe" (LA) from "when they owe it" (us).
--
-- LA snapshot cols  — mirror of LA's invoice/payment state at last sync.
--                     Amount owed is authoritative from LA.
-- next_due_at       — OUR calendar anchor for their next payment.
--                     Advances on qualifying $35+ payment.  Operator can
--                     override via the dropdown on the payments card.
-- next_due_source   — audit trail: how did this value get here?
--
-- Billing cadence (encoded in helper `first_friday_of_month`):
--   - Registration → next 1st Friday of month.
--   - Every subsequent $35 payment → advance one month's 1st Friday.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

-- ──────────────────────────────────────────────────────────────────────
-- 1. Helper: first Friday of the month containing `ts` (UTC).
-- ──────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION first_friday_of_month(ts timestamptz)
RETURNS date
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    mstart date := (date_trunc('month', ts AT TIME ZONE 'UTC'))::date;
    dow    int  := EXTRACT(DOW FROM mstart)::int;   -- 0 = Sun … 5 = Fri
BEGIN
    RETURN mstart + ((5 - dow + 7) % 7);
END;
$$;

COMMENT ON FUNCTION first_friday_of_month(timestamptz) IS
    'Returns the first Friday (calendar date, UTC) of the month that contains ts.';

-- ──────────────────────────────────────────────────────────────────────
-- 2. Add columns.
-- ──────────────────────────────────────────────────────────────────────
ALTER TABLE person_la_memberships
    ADD COLUMN IF NOT EXISTS next_due_at             timestamptz,
    ADD COLUMN IF NOT EXISTS next_due_source         text
        CHECK (next_due_source IN ('la_seed', 'payment_advance', 'operator_override')),
    ADD COLUMN IF NOT EXISTS next_due_updated_at     timestamptz,
    ADD COLUMN IF NOT EXISTS next_due_updated_by     integer REFERENCES admins(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS next_due_note           text,
    ADD COLUMN IF NOT EXISTS la_amount_owed_cents    integer,
    ADD COLUMN IF NOT EXISTS la_amount_paid_cents    integer,
    ADD COLUMN IF NOT EXISTS la_payment_status       text,
    ADD COLUMN IF NOT EXISTS la_next_invoice_due_at  timestamptz,
    ADD COLUMN IF NOT EXISTS la_snapshot_at          timestamptz;

COMMENT ON COLUMN person_la_memberships.next_due_at IS
    'Our anchor for the next expected payment. Advances on $35+ payment; may be overridden by operator.';
COMMENT ON COLUMN person_la_memberships.next_due_source IS
    'la_seed | payment_advance | operator_override';
COMMENT ON COLUMN person_la_memberships.la_amount_owed_cents IS
    'LA-authoritative total_due (integer cents) at last snapshot.';
COMMENT ON COLUMN person_la_memberships.la_amount_paid_cents IS
    'LA-authoritative amount_paid (integer cents) at last snapshot.';
COMMENT ON COLUMN person_la_memberships.la_payment_status IS
    'LA payment_status verbatim at last snapshot (PAID | PARTIAL | UNPAID | …).';
COMMENT ON COLUMN person_la_memberships.la_next_invoice_due_at IS
    'LA next-invoice due date at last snapshot (if any).';
COMMENT ON COLUMN person_la_memberships.la_snapshot_at IS
    'When we last wrote the la_* fields on this row.';

CREATE INDEX IF NOT EXISTS person_la_memberships_next_due_idx
    ON person_la_memberships (next_due_at)
    WHERE ended_at IS NULL;

-- ──────────────────────────────────────────────────────────────────────
-- 3. Backfill next_due_at from existing payment history.
--
--    Approximation used at migration time (later corrected on-demand by
--    LaProgramSync as canonical LA payment data arrives):
--        cycles_paid = ROUND(net_local_paid / 35.0)   (min 0)
--        next_due_at = first_friday_of_month(la_registered_at
--                                             + (cycles_paid + 1) months)
--    Operator can dropdown-override any row post-migration.
-- ──────────────────────────────────────────────────────────────────────
WITH sums AS (
    SELECT
        m.id AS mid,
        m.la_registered_at,
        COALESCE(SUM(
            CASE
                WHEN pp.txn_type ILIKE 'REFUND%' THEN -pp.amount
                ELSE pp.amount
            END
        ), 0)::numeric AS net_paid
    FROM person_la_memberships m
    LEFT JOIN person_payments pp
      ON pp.la_registration_id = m.la_registration_id
    WHERE m.ended_at IS NULL
      AND m.la_registration_id IS NOT NULL
      AND m.next_due_at IS NULL
    GROUP BY m.id, m.la_registered_at
),
computed AS (
    SELECT
        mid,
        la_registered_at,
        GREATEST(0, ROUND(net_paid / 35.0)::int) AS cycles_paid
    FROM sums
)
UPDATE person_la_memberships m
   SET next_due_at         = (first_friday_of_month(
                                COALESCE(m.la_registered_at, now())
                                + ((c.cycles_paid + 1) * interval '1 month')
                              )::timestamptz),
       next_due_source     = 'la_seed',
       next_due_updated_at = now()
  FROM computed c
 WHERE c.mid = m.id;

COMMIT;
