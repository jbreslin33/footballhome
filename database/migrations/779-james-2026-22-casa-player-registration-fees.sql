-- 779: owner 2026-10-28: "add to my invoice next cycle coming 97.22 more for
-- casa player registration fees".  Next cycle = James's 2026.22 (10/23–11/5),
-- which already carries "CASA Player Add fees" $216.24 (added on the page).
-- The $97.22 is its own Registrations row beside it so each charge stays
-- traceable.  Skipped if already there or the sheet is final.
INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, sort_order)
SELECT i.id, 'registrations', 'CASA Player Registration fees', 1, 97.22, 97.22,
       COALESCE((SELECT MAX(sort_order) FROM invoice_lines WHERE invoice_id = i.id), 0) + 1
  FROM invoices i
 WHERE i.issuer_id = 1 AND i.invoice_year = 2026 AND i.invoice_number = 22 AND NOT i.is_final
   AND NOT EXISTS (SELECT 1 FROM invoice_lines l
                    WHERE l.invoice_id = i.id AND l.description = 'CASA Player Registration fees');
UPDATE invoices SET updated_at = now()
 WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 22;
