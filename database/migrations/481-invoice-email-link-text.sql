-- 481 (2026-09-28) — "Invoice #19" is the link in the email.
-- Owner: "it does not look like hyper link in email can we make it a link?
-- can the link be 'Invoice #19'".  A Gmail compose URL carries plain text
-- only, so the page now puts the message on the clipboard as rich text
-- (text/html + text/plain) and opens Gmail with To/Cc/Subject filled and
-- the body empty; one paste drops in "Breslin, James: Invoice #19" with
-- the invoice number as the hyperlink.  The link's wording and the paste
-- hint are rows here, like the rest of the invoice copy.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', 'Invoices — the words that carry the link in the email', 'invoices', 'email_link_text', NULL,
       'Invoice #{number}', 16, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'invoices' AND tier = 'email_link_text');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', 'Invoices — hint under the email button (clipboard paste)', 'invoices', 'email_hint', NULL,
       'Email opens in Gmail with To, Cc and Subject filled in. The message below is copied to your clipboard when you tap Email — paste it into the body (Ctrl+V, or long-press → Paste) and the invoice number comes through as a link. Gmail adds your signature.', 17, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'invoices' AND tier = 'email_hint');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', 'Invoices — flash after the email button copies the message', 'invoices', 'email_copied', NULL,
       'Message copied — paste it into the Gmail body (Ctrl+V).', 18, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'invoices' AND tier = 'email_copied');
