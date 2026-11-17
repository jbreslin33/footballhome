-- 1427 (2026-11-16): futsal balls $302 on this week's invoice — James's
-- 2026 #23 (invoice 24, dated Nov 20, Nov 6–19). Owner: "add $302 futsal
-- balls to invoice for this week". Equipment, against the club-wide "Balls"
-- budget line for 2026-27 (budget_lines 46) so Budget vs Actual counts it.
BEGIN;
INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, sort_order, budget_line_id)
SELECT 24, 'equipment', 'Futsal balls', 1, 302.00, 302.00, 45, 46
 WHERE NOT EXISTS (SELECT 1 FROM invoice_lines WHERE invoice_id = 24 AND description = 'Futsal balls');
INSERT INTO schema_migrations (filename) VALUES ('1427-invoice-23-futsal-balls.sql') ON CONFLICT DO NOTHING;
COMMIT;
