-- 1428 (2026-11-16): futsal balls ($302, mig 1427) spread over 3 invoices.
-- Owner: "spread it over 3 invoices". Same as the field paint / camera: an
-- installment plan (issuer James, 3 × ~$100.67, total shown), installment 1 =
-- the line already on this week's invoice (2026 #23); the next two invoices
-- pick up 2 and 3 when they're made.
BEGIN;
WITH p AS (
  INSERT INTO invoice_installment_plans (issuer_id, category, description, total_amount, installment_count, show_total, budget_line_id)
  SELECT 1, 'equipment', 'Futsal balls', 302.00, 3, true, 46
   WHERE NOT EXISTS (SELECT 1 FROM invoice_installment_plans WHERE issuer_id = 1 AND description = 'Futsal balls')
  RETURNING id
)
UPDATE invoice_lines l SET plan_id = p.id, installment_no = 1, rate = 100.67, amount = 100.67
  FROM p WHERE l.invoice_id = 24 AND l.description = 'Futsal balls';
INSERT INTO schema_migrations (filename) VALUES ('1428-futsal-balls-three-installments.sql') ON CONFLICT DO NOTHING;
COMMIT;
