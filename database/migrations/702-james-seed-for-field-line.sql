-- 702: James's 2026.21 sheet gets a 'Seed for field' facilities line,
-- $3,353.88 — files beside Top Soil (same category).
INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, sort_order)
SELECT i.id, 'facilities', 'Seed for field', 1, 3353.88, 3353.88, 5
  FROM invoices i
 WHERE i.issuer_id = 1 AND i.invoice_year = 2026 AND i.invoice_number = 21
   AND NOT EXISTS (SELECT 1 FROM invoice_lines l
                    WHERE l.invoice_id = i.id AND l.description = 'Seed for field');
UPDATE invoices SET updated_at = now()
 WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 21;
