-- 1960 (2026-11-27): coaching books belong under COACHES, not Other.
-- Owner: "it should be under coaches". New invoice line category 'coaches'
-- ("Coaches:") — its own section on the printed sheet and its own row on
-- the #finances grid — and the mig-1959 Coaching books plan + its
-- installment line move into it.
BEGIN;
INSERT INTO invoice_line_categories (code, label, sort_order)
VALUES ('coaches', 'Coaches:', 14)
ON CONFLICT (code) DO NOTHING;

UPDATE message_templates SET body = body || '|coaches', updated_at = now()
 WHERE kind = 'finances' AND tier = 'category_order' AND body NOT LIKE '%coaches%';

UPDATE invoice_installment_plans SET category = 'coaches'
 WHERE issuer_id = 1 AND description = 'Coaching books';
UPDATE invoice_lines SET category = 'coaches'
 WHERE plan_id = (SELECT id FROM invoice_installment_plans WHERE issuer_id = 1 AND description = 'Coaching books');
INSERT INTO schema_migrations (filename) VALUES ('1960-coaches-invoice-category.sql') ON CONFLICT DO NOTHING;
COMMIT;
