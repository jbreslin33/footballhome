-- 701: Luke (issuer 2, person 3463) is owed $160 youth-game ref fees from
-- last cycle. Coach issuers don't bill expenses yet (ref picker is James-only),
-- so for now it rides his 2026.21 sheet as one hand line beside his hours.
-- No ref_fee_payments rows — syncRefLine never runs for bills_expenses=false.
INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, sort_order)
SELECT i.id, 'referees', 'Youth games ref fees', 1, 160.00, 160.00, 2
  FROM invoices i
 WHERE i.issuer_id = 2 AND i.invoice_year = 2026 AND i.invoice_number = 21
   AND NOT EXISTS (SELECT 1 FROM invoice_lines l
                    WHERE l.invoice_id = i.id AND l.description = 'Youth games ref fees');
UPDATE invoices SET updated_at = now()
 WHERE issuer_id = 2 AND invoice_year = 2026 AND invoice_number = 21;
