-- 720 (2026-10-26) — owner's wording for 702's line on James's 2026.21:
-- "Seed for entire Sports Complex".
UPDATE invoice_lines l SET description = 'Seed for entire Sports Complex'
  FROM invoices v
 WHERE v.id = l.invoice_id AND NOT v.is_final AND l.description = 'Seed for field'
   AND v.issuer_id = 1 AND v.invoice_year = 2026 AND v.invoice_number = 21;
UPDATE invoices SET updated_at = now() WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 21;
