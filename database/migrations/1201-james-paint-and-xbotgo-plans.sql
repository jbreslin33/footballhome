-- 1201 (2026-11-09): two purchases on James's invoices, spread as payment plans.
-- Owner: "add $140.88 for paint to invoices spread over 3 payments. add
-- 830.52 to camera xbot falcon. spread over next 8 payments."
--   Field Paint             facilities  140.88 / 3 = 46.96 each   (budget line 17, Field paint — Fall)
--   XbotGo Falcon camera    equipment   830.52 / 8 = 103.82 ×7 + 103.78
-- Payment 1 lands on the open draft 2026.23 (11/6–11/19); later sheets take
-- the next "k of N" as they are created (Invoice::openPlans; the last one
-- absorbs rounding).  Skipped if the plan already exists.

BEGIN;

CREATE TEMP TABLE np ON COMMIT DROP AS
WITH v(category, description, total, n, budget_line_id) AS (
  VALUES ('facilities', 'Field Paint (Nov)', 140.88::numeric, 3, 17),
         ('equipment',  'XbotGo Falcon camera', 830.52::numeric, 8, NULL::int))
, ins AS (
  INSERT INTO invoice_installment_plans (issuer_id, category, description, total_amount, installment_count, show_total, budget_line_id)
  SELECT 1, v.category, v.description, v.total, v.n, true, v.budget_line_id FROM v
   WHERE NOT EXISTS (SELECT 1 FROM invoice_installment_plans p
                      WHERE p.issuer_id = 1 AND p.description = v.description AND p.total_amount = v.total)
  RETURNING id, category, description, total_amount, installment_count, budget_line_id)
SELECT * FROM ins;

INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, plan_id, installment_no, sort_order, budget_line_id)
SELECT i.id, np.category, np.description, 1,
       round(np.total_amount / np.installment_count, 2), round(np.total_amount / np.installment_count, 2),
       np.id, 1,
       COALESCE((SELECT MAX(sort_order) FROM invoice_lines WHERE invoice_id = i.id), 0) + row_number() OVER (ORDER BY np.id),
       np.budget_line_id
  FROM np
  JOIN invoices i ON i.issuer_id = 1 AND i.invoice_year = 2026 AND i.invoice_number = 23 AND NOT i.is_final;

UPDATE invoices SET updated_at = now() WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 23;

INSERT INTO schema_migrations (filename) VALUES ('1201-james-paint-and-xbotgo-plans.sql') ON CONFLICT DO NOTHING;

COMMIT;
