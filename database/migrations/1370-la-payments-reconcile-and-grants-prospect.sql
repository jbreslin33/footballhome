-- 1370 (2026-11-14) — LA payments reconcile + grants back to "Looking into it".
--
-- 1. person_payments only ever UPSERTed from the transactions-2 cursor, so a
--    row LeagueApps later deleted (26 returned/failed ACH "Bank" rows, $1,050,
--    found 11/10) stayed counted in #finances Actuals, Budget vs Actual and
--    every dues balance — money in ~12% high. PersonPayments::reconcileFromLa
--    (LaSyncScheduler, at most every 6 h) re-pulls everything LA updated since
--    reconcile_from_ms, refreshes each row (payout ids LA adds without bumping
--    lastUpdated) and moves rows LA no longer has into
--    person_payments_la_dropped (whole row kept, so it can be put back).
--
-- 2. Owner 2026-11-14: "grants can be added later. just leave functionality".
--    The nine soccer-grant rows (2026-27 → 2028-29) were 'awarded' and counted
--    as $30k/yr revenue; they go to 'prospect' (Looking into it), which the
--    Budget does not count. Setting a row to 'awarded' or 'received' brings
--    it back.
BEGIN;

ALTER TABLE leagueapps_transaction_cursor
    ADD COLUMN IF NOT EXISTS reconcile_from_ms bigint NOT NULL DEFAULT 1767225600000,  -- 2026-01-01 UTC
    ADD COLUMN IF NOT EXISTS last_reconciled_at timestamptz;

CREATE TABLE IF NOT EXISTS person_payments_la_dropped (
    id                     serial PRIMARY KEY,
    la_transaction_item_id bigint      NOT NULL,
    row_data               jsonb       NOT NULL,   -- to_jsonb(person_payments row)
    dropped_at             timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS person_payments_la_dropped_item ON person_payments_la_dropped (la_transaction_item_id);
COMMENT ON TABLE person_payments_la_dropped IS
  'person_payments rows LeagueApps no longer returns (deleted / returned ACH), moved here by PersonPayments::reconcileFromLa (mig 1370). Restore: INSERT INTO person_payments SELECT (jsonb_populate_record(NULL::person_payments, row_data)).*';

UPDATE income_awards SET status = 'prospect'
 WHERE kind = 'grant' AND status = 'awarded' AND source_name = 'Soccer grant (3 years)';

COMMIT;
