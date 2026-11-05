-- 1100: owner 2026-11-05: "we can just spread some items as well to smooth it
-- till we get fully to winter" … "payment plans work well but as long as we
-- can fit all on invoice" (the printed sheet has 14 rows; 2026.23 stays at 7,
-- 2026.24 gains 3).
-- Three one-off lines on James's 2026.23 become 2-payment plans.  The SAME
-- invoice_lines rows (82, 95, 96) become payment 1 of 2; payment 2 of 2 is
-- added by itself when 2026.24 is created (Invoice::createNumbered → open
-- plans), the last payment absorbing any odd cent.  Plan totals = the
-- original amounts, so nothing is lost or doubled.
--   Lighthouse Badge Logos  $252.11 → $126.06 now, $126.05 on 2026.24
--   Field rental            $209.00 → $104.50 now, $104.50 on 2026.24
--   CASA Player Add fees    $168.64 →  $84.32 now,  $84.32 on 2026.24

BEGIN;

WITH src(line_id) AS (VALUES (82), (95), (96)),
plans AS (
  INSERT INTO invoice_installment_plans (issuer_id, category, description, total_amount, installment_count, show_total)
  SELECT 1, l.category, l.description, l.amount, 2, true
    FROM invoice_lines l JOIN src ON src.line_id = l.id
   WHERE l.plan_id IS NULL
     AND l.invoice_id = (SELECT id FROM invoices WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 23 AND NOT is_final)
  RETURNING id, description, total_amount
)
UPDATE invoice_lines l
   SET plan_id = p.id, installment_no = 1,
       rate = round(p.total_amount / 2, 2), amount = round(p.total_amount / 2, 2)
  FROM plans p
 WHERE l.id IN (82, 95, 96) AND l.description = p.description AND l.amount = p.total_amount;

UPDATE invoices SET updated_at = now() WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 23;

COMMIT;
