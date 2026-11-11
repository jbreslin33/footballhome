-- 1242 (2026-11-11) — Women's Tri County league fee on James's next invoice.
--
-- Owner 2026-11-11: "add 94.42 to next invoice for womens tri county league
-- fee".  Next invoice = James's 2026.23 (11/6–11/19, due Fri 11/20, invoices
-- id 24, unsent).  League Dues line beside APSL / CASA Liga 1, against budget
-- line 3 (Tri County league dues, Womens).

INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, sort_order, budget_line_id)
SELECT i.id, 'league_dues', 'Tri County League Dues (Womens)', 1, 94.42, 94.42, 12, 3
  FROM invoices i
 WHERE i.issuer_id = 1 AND i.invoice_year = 2026 AND i.invoice_number = 23 AND NOT i.is_final
   AND NOT EXISTS (SELECT 1 FROM invoice_lines l
                    WHERE l.invoice_id = i.id AND l.budget_line_id = 3 AND l.amount = 94.42);
