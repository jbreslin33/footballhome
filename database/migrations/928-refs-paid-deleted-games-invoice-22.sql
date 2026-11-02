-- 928: owner: "add to refs 200. games were deleted but we paid refs."  Hand
-- Referees line on James's 2026.22.  Deleted games leave the ref picker, so
-- there is no ref_fee_payments row to pin; its own row, like migs 707 and 927.
INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, sort_order)
SELECT i.id, 'referees', 'Refs paid, deleted games', 1, 200, 200, 14
  FROM invoices i
 WHERE i.issuer_id = 1 AND i.invoice_year = 2026 AND i.invoice_number = 22
   AND NOT EXISTS (SELECT 1 FROM invoice_lines l
                    WHERE l.invoice_id = i.id AND l.description = 'Refs paid, deleted games');

UPDATE invoices SET updated_at = now()
 WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 22;
