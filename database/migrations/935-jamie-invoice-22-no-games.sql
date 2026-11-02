-- Jamie's 2026.22 has no worked events left: both women's games in the window
-- (Rose Tree 10/25, Gaels 11/1) were cancelled, so its day rows came off, but
-- the hours line kept its 2 h / $30 because syncLabor skips a sheet with no
-- rows.  Owner: "canceled events should not be in invoice".
UPDATE invoice_lines l
   SET quantity = 0, amount = 0
  FROM invoices i
 WHERE l.invoice_id = i.id AND i.issuer_id = 3 AND i.invoice_year = 2026 AND i.invoice_number = 22
   AND NOT i.is_final AND l.category = 'labor'
   AND NOT EXISTS (SELECT 1 FROM invoice_work_shifts s WHERE s.invoice_id = i.id);

UPDATE invoices SET updated_at = now()
 WHERE issuer_id = 3 AND invoice_year = 2026 AND invoice_number = 22;
