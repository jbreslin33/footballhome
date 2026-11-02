-- 930: owner: "add 209.00 for field rental ... to invoice".  Hand Facilities
-- line on James's 2026.22, the open sheet.
INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, sort_order)
SELECT i.id, 'facilities', 'Field rental', 1, 209, 209, 15
  FROM invoices i
 WHERE i.issuer_id = 1 AND i.invoice_year = 2026 AND i.invoice_number = 22
   AND NOT EXISTS (SELECT 1 FROM invoice_lines l
                    WHERE l.invoice_id = i.id AND l.description = 'Field rental');

UPDATE invoices SET updated_at = now()
 WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 22;
