-- 927: owner: "add to invoice ref fee for women. 94.42".  A hand Referees line
-- on James's 2026.22, the open sheet (only James bills expenses).  It is its
-- own row, not folded into the picked Referees line: that one is rebuilt from
-- ref_fee_payments, so a fee folded into it would vanish (same as mig 707).
INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, sort_order)
SELECT i.id, 'referees', 'Women''s ref fee', 1, 94.42, 94.42, 13
  FROM invoices i
 WHERE i.issuer_id = 1 AND i.invoice_year = 2026 AND i.invoice_number = 22
   AND NOT EXISTS (SELECT 1 FROM invoice_lines l
                    WHERE l.invoice_id = i.id AND l.description = 'Women''s ref fee');

UPDATE invoices SET updated_at = now()
 WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 22;
