-- 471 (2026-09-27) — Email the invoice to Lighthouse's deputy director.
-- Owner: "i need to be able to hit email deputy directory for each one and
-- it oepns my gmail like for reminders etc. deputy.director@lighthouse1893.org"
-- and "the title should be Invoice #18 8/31 & 09/07, Breslin, Luke" (the
-- dates are the Mondays of the two weeks).  The address lives on the BILL
-- TO row; subject / body are message copy (kind 'invoices', tier 'email').
-- The PDF is attached by hand in Gmail — a compose link cannot carry a file.
ALTER TABLE invoice_bill_to ADD COLUMN IF NOT EXISTS email TEXT;
ALTER TABLE invoice_bill_to ADD COLUMN IF NOT EXISTS email_label TEXT;
UPDATE invoice_bill_to SET email = 'deputy.director@lighthouse1893.org', email_label = 'Deputy Director' WHERE email IS NULL;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', 'Invoices — email to the deputy director', 'invoices', 'email',
       '{title}',
       'Hi,

Attached is invoice #{number} for {name}, covering the weeks of {week1} and {week2}. Total {total}.

Thank you,
{sender}',
       13, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'invoices' AND tier = 'email');
