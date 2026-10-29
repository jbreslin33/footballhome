-- 841: owner 2026-10-29: "add 25.80 more for casa player reg".  Same sheet
-- as migs 839/840 (James's 2026.22, 10/23–11/5).  Its own Registrations row
-- beside mig 779's $97.22 so each charge stays traceable.  Skipped if
-- already there or the sheet is final.
INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, sort_order)
SELECT i.id, 'registrations', 'CASA Player Registration fees', 1, 25.80, 25.80,
       COALESCE((SELECT MAX(sort_order) FROM invoice_lines WHERE invoice_id = i.id), 0) + 1
  FROM invoices i
 WHERE i.issuer_id = 1 AND i.invoice_year = 2026 AND i.invoice_number = 22 AND NOT i.is_final
   AND NOT EXISTS (SELECT 1 FROM invoice_lines l
                    WHERE l.invoice_id = i.id AND l.description = 'CASA Player Registration fees'
                      AND l.amount = 25.80);
UPDATE invoices SET updated_at = now()
 WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 22;
