-- Owner 11/6: get James's 2026.22 (invoice 20) under $3,000 with payment plans,
-- sized off 2026.23's projection (~$2,520: $637 on it + ~$910 labor + ~$975
-- refs), "make sure we don't lose the stuff".
-- The SAME invoice_lines rows move (re-pointed, never copied) onto 2026.23
-- (invoice 24) and become 2-payment plans there: payment 1 of 2 on 2026.23,
-- payment 2 of 2 added by itself when 2026.24 is created (open plans), the
-- last payment absorbing the odd cent.  Plan totals = the original amounts.
--   CASA Player Registrations   $339.26 → $169.63 on .23, $169.63 on .24
--   CASA Liga 1 League payment  $250.19 → $125.10 on .23, $125.09 on .24
-- 2026.22: $3,429.99 → $2,840.54.  2026.23: $637.09 → $931.82 so far.
BEGIN;

UPDATE invoice_lines
   SET invoice_id = 24, line_date = NULL
 WHERE invoice_id = 20 AND id IN (84, 86) AND plan_id IS NULL
   AND ((id = 84 AND amount = 339.26) OR (id = 86 AND amount = 250.19));

WITH plans AS (
  INSERT INTO invoice_installment_plans (issuer_id, category, description, total_amount, installment_count, show_total, budget_line_id)
  SELECT 1, l.category, l.description, l.amount, 2, true, l.budget_line_id
    FROM invoice_lines l
   WHERE l.id IN (84, 86) AND l.invoice_id = 24 AND l.plan_id IS NULL
  RETURNING id, description, total_amount
)
UPDATE invoice_lines l
   SET plan_id = p.id, installment_no = 1,
       rate = round(p.total_amount / 2, 2), amount = round(p.total_amount / 2, 2)
  FROM plans p
 WHERE l.id IN (84, 86) AND l.invoice_id = 24 AND l.description = p.description AND l.amount = p.total_amount;

UPDATE invoices SET updated_at = now() WHERE id IN (20, 24);

COMMIT;
