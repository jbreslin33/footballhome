-- 1659 (2026-11-23): Wet & Forget, $78.62, on James's 2026.24.
--
-- Owner: "add wet and forget for facilites or whatever we have for that
-- $37.95" … "wait no wrong cost" … "78.62 for wet and forget" — a hand Facilities line on the open sheet, sorted after the last
-- Facilities line already there (Field Paint (Nov)).  One payment.

BEGIN;

INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, sort_order)
SELECT v.id, 'facilities', 'Wet & Forget', 1, 78.62, 78.62,
       COALESCE((SELECT MAX(c.sort_order) FROM invoice_lines c
                  WHERE c.invoice_id = v.id AND c.category = 'facilities'), 50)
  FROM invoices v
 WHERE v.issuer_id = 1 AND v.invoice_year = 2026 AND v.invoice_number = 24 AND NOT v.is_final
   AND NOT EXISTS (SELECT 1 FROM invoice_lines l
                    WHERE l.invoice_id = v.id AND l.description = 'Wet & Forget');

UPDATE invoices SET updated_at = now() WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 24;

INSERT INTO schema_migrations (filename) VALUES ('1659-wet-and-forget-invoice-24.sql') ON CONFLICT DO NOTHING;
COMMIT;
