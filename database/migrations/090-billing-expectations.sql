-- 090: billing_expectations state machine + la_registered_at backfill column
--
-- What this migration adds:
--   1. `person_la_memberships.la_registered_at`  (nullable timestamptz)
--      Real LeagueApps registration timestamp for this (person, program).
--      NULL until backfilled from LA's registrations-2 export or set by
--      a future sync-time populator.  When NULL the projector treats the
--      membership as "established" (no pro-rate window, only 1st-Friday
--      $35 monthly billing).
--
--   2. `billing_expectations`
--      Per-Friday projected invoice line for a (leagueapps_user_id,
--      program_id, charge_date).  Fed by BillingProjector; consumed by
--      the admin queue (which lines need $$ added on LA today?) and by
--      BillingReconciler (which lines just cleared?).
--
--   Kinds:
--     'monthly'  = $35.00 on the 1st Friday of a calendar month
--     'prorate'  = $8.75 on any Friday strictly between the registration
--                  date and the first 1st-Friday-of-month that comes on
--                  or after registration (skipped entirely when that gap
--                  is ≤ 5 days — LA charges the $35 directly instead).
--
--   Lifecycle timestamps (monotonic — never nulled once set):
--     invoice_added_at  set when the reconciler observes LA balance ≥ expected
--     paid_at           set when the reconciler observes LA balance = 0 AND
--                       paymentStatus = PAID
--     waived_at         set manually via admin action (skip this line)
--
--   State derivation (view convenience, code equivalent):
--     waived_at  IS NOT NULL                          → 'waived'
--     paid_at    IS NOT NULL                          → 'paid'
--     invoice_added_at IS NOT NULL                    → 'invoice-added'
--     charge_date <= now()                            → 'due'
--     else                                            → 'projected'

ALTER TABLE person_la_memberships
  ADD COLUMN IF NOT EXISTS la_registered_at TIMESTAMPTZ NULL;

COMMENT ON COLUMN person_la_memberships.la_registered_at IS
  'True LA registration timestamp (from registrations-2.registrationDate). '
  'NULL when unknown — projector treats NULL as established (no pro-rate).';

CREATE TABLE IF NOT EXISTS billing_expectations (
    id                 SERIAL       PRIMARY KEY,
    leagueapps_user_id BIGINT       NOT NULL,
    la_program_id      BIGINT       NOT NULL,
    charge_date        DATE         NOT NULL,          -- always a Friday in America/NY
    kind               TEXT         NOT NULL
      CHECK (kind IN ('monthly','prorate')),
    expected_amount    NUMERIC(8,2) NOT NULL
      CHECK (expected_amount >= 0),
    invoice_added_at   TIMESTAMPTZ  NULL,
    paid_at            TIMESTAMPTZ  NULL,
    waived_at          TIMESTAMPTZ  NULL,
    notes              TEXT         NULL,              -- reconciler / manual notes
    created_at         TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at         TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- One expectation per (user, program, date) — projector uses ON CONFLICT
-- to upsert, and the reconciler / admin queue rely on this uniqueness.
CREATE UNIQUE INDEX IF NOT EXISTS billing_expectations_uniq
  ON billing_expectations (leagueapps_user_id, la_program_id, charge_date);

-- Queue lookups: "which expectations are due today and not yet on LA?"
CREATE INDEX IF NOT EXISTS billing_expectations_open_idx
  ON billing_expectations (charge_date)
  WHERE invoice_added_at IS NULL AND waived_at IS NULL;

-- Per-user timeline lookups (roster card + admin drill-down).
CREATE INDEX IF NOT EXISTS billing_expectations_user_idx
  ON billing_expectations (leagueapps_user_id, charge_date DESC);

-- Reconciler scan: everything not-yet-paid we still need to watch.
CREATE INDEX IF NOT EXISTS billing_expectations_unpaid_idx
  ON billing_expectations (leagueapps_user_id, charge_date)
  WHERE paid_at IS NULL AND waived_at IS NULL;

-- updated_at trigger — mirrors the pattern used elsewhere in this DB.
CREATE OR REPLACE FUNCTION billing_expectations_touch_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS billing_expectations_touch ON billing_expectations;
CREATE TRIGGER billing_expectations_touch
  BEFORE UPDATE ON billing_expectations
  FOR EACH ROW EXECUTE FUNCTION billing_expectations_touch_updated_at();

COMMENT ON TABLE billing_expectations IS
  'Per-Friday projected/actual invoice line. Written by BillingProjector; '
  'consumed by admin queue + BillingReconciler.';
