-- 053: per-person billing (next bill date + amount).
-- Tracks when a LeagueApps member will next be invoiced and for how
-- much.  Default is $35 on 2026-07-01.  Free agents (e.g. Casa-paid
-- players whose fees are reimbursed) get amount = 0.  Admins edit this
-- on the Men's Roster page; same fields can later be surfaced on Youth.
--
-- Keyed by leagueapps_user_id so a person on multiple teams (U23 +
-- country) still has exactly one monthly charge.

CREATE TABLE IF NOT EXISTS person_billing (
    leagueapps_user_id BIGINT PRIMARY KEY,
    next_bill_date     DATE          NOT NULL DEFAULT DATE '2026-07-01',
    next_bill_amount   NUMERIC(8, 2) NOT NULL DEFAULT 35.00,
    updated_at         TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_by_user_id INTEGER       REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_person_billing_next_bill_date
    ON person_billing(next_bill_date);

COMMENT ON TABLE person_billing IS
    'Per-LeagueApps-user upcoming bill date + amount. Amount 0 = free agent.';
