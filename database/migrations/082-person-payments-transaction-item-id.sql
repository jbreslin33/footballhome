-- 082-person-payments-transaction-item-id.sql
--
-- FIX: LA transactions-2 feed returns MULTIPLE rows per `id` when a
-- single payment covers multiple invoice line items (e.g. a parent
-- pays for 3 children in one Stripe charge — 3 rows all share the
-- same `id` but have distinct `invoiceId`, `registrationId`, and
-- `transactionItemId`).  Our previous UPSERT keyed on
-- `la_transaction_id` (PRIMARY KEY) collapsed those into a single
-- row, silently dropping every line item after the first.
--
-- Symptom: Angel Terrero's Boys Club dues (June 29, one of three
-- $35 charges from parent Lina Bono under LA txn 81184143) never
-- landed in person_payments — LA said `amountPaid=35` on his
-- registration, but our DB had zero rows.  Same pattern affected
-- every multi-child household.
--
-- Fix: use `transactionItemId` (the per-line-item id) as the
-- uniqueness key instead of `id`.  Backfill it for existing rows
-- from `raw->>'transactionItemId'` (populated by PersonPayments'
-- upsert since migration 078), then swap the primary key.  Finally
-- rewind the transactions cursor so the next sync re-ingests the
-- line items we previously dropped.

BEGIN;

-- 1. Add the new column.
ALTER TABLE person_payments
    ADD COLUMN IF NOT EXISTS la_transaction_item_id BIGINT;

-- 2. Backfill from raw JSON.  Every row inserted since migration 078
--    stored the full LA transaction payload, which always contains a
--    numeric `transactionItemId`.
UPDATE person_payments
   SET la_transaction_item_id = (raw->>'transactionItemId')::bigint
 WHERE la_transaction_item_id IS NULL
   AND (raw->>'transactionItemId') ~ '^[0-9]+$';

-- 3. Fail loudly if any row is still missing the item id — we do not
--    want a partial migration that leaves a NOT NULL column with holes.
DO $$
DECLARE bad INTEGER;
BEGIN
    SELECT COUNT(*) INTO bad
      FROM person_payments
     WHERE la_transaction_item_id IS NULL;
    IF bad > 0 THEN
        RAISE EXCEPTION 'person_payments has % rows without la_transaction_item_id; aborting migration', bad;
    END IF;
END $$;

-- 4. Swap the primary key.  la_transaction_id becomes a regular
--    (non-unique) indexed column so joins by transaction still work.
ALTER TABLE person_payments DROP CONSTRAINT person_payments_pkey;

ALTER TABLE person_payments
    ALTER COLUMN la_transaction_item_id SET NOT NULL;

ALTER TABLE person_payments
    ADD CONSTRAINT person_payments_pkey PRIMARY KEY (la_transaction_item_id);

CREATE INDEX IF NOT EXISTS idx_person_payments_transaction_id
    ON person_payments (la_transaction_id);

-- 5. Rewind the transactions cursor so the next sync re-fetches
--    recent transactions and picks up the line items we dropped when
--    upserting on la_transaction_id alone.  We only rewind — never
--    advance — so this is safe to run repeatedly.
UPDATE leagueapps_transaction_cursor
   SET last_updated_ms = LEAST(COALESCE(last_updated_ms, 0), 1735689600000),  -- 2026-01-01
       last_id = 0
 WHERE scope = 'global';

COMMIT;
