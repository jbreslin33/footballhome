-- 1095: owner 2026-11-05: "this was expensive 2 weeks. i am thinking we unload
-- some to next invoice but want to make sure we don't lose them … show both to
-- show they were not dupped or lost".
-- Opens James's next sheet 2026.23 (11/6–11/19, dated 11/20) and MOVES four
-- one-off lines off 2026.22 onto it — the same invoice_lines rows (ids 82, 94,
-- 95, 96) re-pointed, never copied, so nothing can be doubled or dropped.
-- Moved: Lighthouse Badge Logos $252.11, Refs paid deleted games $200.00,
-- Field rental $209.00, CASA Player Add fees $168.64 (total $829.75).

BEGIN;

INSERT INTO invoices (issuer_id, invoice_year, invoice_number, invoice_date, period_start, period_end)
SELECT 1, 2026, 23, DATE '2026-11-20', DATE '2026-11-06', DATE '2026-11-19'
 WHERE NOT EXISTS (SELECT 1 FROM invoices WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 23);

UPDATE invoice_lines l
   SET invoice_id = (SELECT id FROM invoices WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 23),
       sort_order = 100 + l.sort_order
 WHERE l.id IN (82, 94, 95, 96)
   AND l.invoice_id = (SELECT id FROM invoices WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 22 AND NOT is_final);

UPDATE invoices SET updated_at = now()
 WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number IN (22, 23);

COMMIT;
