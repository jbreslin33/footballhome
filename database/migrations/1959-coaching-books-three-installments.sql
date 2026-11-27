-- 1959 (2026-11-27): coaching books on James's invoices.
-- Owner: "add 144.97 for each of next 3 invoices for coaching books".
-- Installment plan (issuer James, 3 × $144.97 = $434.91, total shown),
-- category Other. Installment 1 goes on the current draft (2026 #24,
-- invoice id 28, 11/20–12/3); #25 and #26 pick up 2 and 3 when drafted.
BEGIN;
WITH p AS (
  INSERT INTO invoice_installment_plans (issuer_id, category, description, total_amount, installment_count, show_total)
  SELECT 1, 'other', 'Coaching books', 434.91, 3, true
   WHERE NOT EXISTS (SELECT 1 FROM invoice_installment_plans WHERE issuer_id = 1 AND description = 'Coaching books')
  RETURNING id
)
INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, plan_id, installment_no, sort_order)
SELECT 28, 'other', 'Coaching books', 1, 144.97, 144.97, p.id, 1, 11 FROM p;
INSERT INTO schema_migrations (filename) VALUES ('1959-coaching-books-three-installments.sql') ON CONFLICT DO NOTHING;
COMMIT;
