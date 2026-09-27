-- 473 (2026-09-27) — The invoice email, as James actually writes it.
-- Owner pasted both: for a coach — "This is a coaching invoice for Luke
-- Breslin. He is included in this email. / Invoice #18 8/31 & 09/07
-- Breslin, Luke: Invoice #18 / Thanks!" (the coach is cc'd, "Invoice #18"
-- links to the PDF); for himself — "Hi Julian, … Invoice #16 08/31 &
-- 09/07, Breslin: Invoice #18 / Thanks!", simplified now that Julian knows
-- it is itemised.  Gmail adds James's signature itself.  A compose link
-- carries plain text only, so the PDF link is written out after the title.
ALTER TABLE invoice_bill_to ADD COLUMN IF NOT EXISTS email_to_name TEXT;   -- "Hi Julian,"
UPDATE invoice_bill_to SET email_to_name = 'Julian' WHERE email_to_name IS NULL;
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS link_url TEXT;              -- the PDF in Drive, pasted after saving it
COMMENT ON COLUMN invoices.link_url IS 'Share link to the saved PDF (Drive); goes in the email after the title (mig 473).';

UPDATE message_templates
   SET subject = '{title}',
       body = 'Hi {to_name},

{title}: {link}

Thanks!',
       label = 'Invoices — email, own invoice'
 WHERE kind = 'invoices' AND tier = 'email';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', 'Invoices — email, a coach''s invoice (coach cc''d)', 'invoices', 'email_coach',
       '{title}',
       'Hi {to_name},

This is a coaching invoice for {name}, who is copied on this email.

{title}: {link}

Thanks!',
       14, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'invoices' AND tier = 'email_coach');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', 'Invoices — email link when no PDF link is set', 'invoices', 'email_no_link', NULL,
       'attached', 15, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'invoices' AND tier = 'email_no_link');
