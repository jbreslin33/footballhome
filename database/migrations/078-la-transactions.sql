-- LA transaction history + sync cursor
--
-- Persists per-transaction rows fetched from
-- /v2/sites/{site}/export/transactions-2 so player cards can render
-- "Last: $35 · Jul 3" and the roster page can decide green (paid up)
-- vs red (behind) without extra LA calls per player.
--
-- The transactions-2 endpoint ignores its optional `program-id` filter
-- and returns cross-program history paginated by (last-updated, last-id).
-- We therefore keep a single global cursor.
--
-- Rows are UPSERTed by la_transaction_id so re-fetching the tail page
-- on every roster load is idempotent.
--
-- User directive 2026-07-02: "every time the roster page loads to
-- check vs la and update gui and db on payment amount and dates".
-- This table is the persistent side of that loop; the LA call side
-- runs in MensRoster::load / YouthRoster::load.

CREATE TABLE IF NOT EXISTS person_payments (
    la_transaction_id BIGINT PRIMARY KEY,          -- transactions-2.id
    la_user_id        BIGINT NOT NULL,             -- LA userId (join key)
    la_registration_id BIGINT,                     -- LA registrationId (nullable)
    la_program_id     BIGINT NOT NULL,             -- LA programId this txn was for
    la_invoice_id     BIGINT,                      -- LA invoiceId
    txn_type          TEXT   NOT NULL,             -- Charge / Bank / Offline Payment / Refund / Partial Refund
    amount            NUMERIC(12,2) NOT NULL,      -- dollars (positive; refunds appear as separate txn type)
    net_amount        NUMERIC(12,2),               -- after processor fees
    gateway           TEXT,                        -- StripeLAP / '' / etc.
    paid_at           TIMESTAMPTZ NOT NULL,        -- created_on (epoch ms → ts)
    last_updated      TIMESTAMPTZ NOT NULL,        -- lastUpdated (cursor)
    first_name        TEXT,                        -- audit/debug
    last_name         TEXT,
    program_name      TEXT,
    raw               JSONB,                       -- full record for debugging
    inserted_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_person_payments_user_program_paid
    ON person_payments (la_user_id, la_program_id, paid_at DESC);

CREATE INDEX IF NOT EXISTS idx_person_payments_program_paid
    ON person_payments (la_program_id, paid_at DESC);

-- One row expected — 'global' since transactions-2 is cross-program.
CREATE TABLE IF NOT EXISTS leagueapps_transaction_cursor (
    scope           TEXT PRIMARY KEY,
    last_updated_ms BIGINT NOT NULL DEFAULT 0,
    last_id         BIGINT NOT NULL DEFAULT 0,
    last_synced_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO leagueapps_transaction_cursor (scope) VALUES ('global')
ON CONFLICT (scope) DO NOTHING;
