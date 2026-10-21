-- 624 (2026-10-21) — Ref fees default ONTO the sheet; red = left off.
--
-- Owner TODO: "Ref fees: green (on the invoice) by default, with a
-- toggle to turn one red = leave off the invoice.  Ref fees: amount
-- editable per fee."  A draft invoice now auto-adds every played,
-- in-gcal, in-window referee fee on open; this table remembers the ones
-- deliberately turned OFF so the auto-add never puts them back.  The
-- fee's amount lives on its ref_fee_payments row (amount_usd) and is now
-- editable per fee from the 📅 calendar chip.

CREATE TABLE IF NOT EXISTS invoice_ref_declines (
    id         SERIAL PRIMARY KEY,
    invoice_id INTEGER NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    source     TEXT NOT NULL,          -- 'event' | 'fixture', as Expenses::games keys them
    ref_id     BIGINT NOT NULL,        -- fh_event id or league_fixture id
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (invoice_id, source, ref_id)
);
COMMENT ON TABLE invoice_ref_declines IS
  'mig 624: a referee fee deliberately left OFF this invoice (the red chip) — the default-on auto-add skips these.';

-- Client copy for the new chip zones (never hardcode copy).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'Invoices — ref fee on tooltip', 'invoices', 'ref_on_tip', NULL,
       'On the sheet — tap to leave this fee off the invoice', 43, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'invoices' AND tier = 'ref_on_tip');

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'Invoices — ref fee off tooltip', 'invoices', 'ref_off_tip', NULL,
       'Left off the invoice — tap to put this fee back on', 44, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'invoices' AND tier = 'ref_off_tip');

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'Invoices — ref fee amount tooltip', 'invoices', 'ref_amt_tip', NULL,
       'Edit this fee''s amount', 45, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'invoices' AND tier = 'ref_amt_tip');
