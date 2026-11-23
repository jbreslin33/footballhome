-- 1658 (2026-11-23): SD card for the camera, $37.95, on James's 2026.24.
--
-- Owner: "ok add a sd card $37.95 for camera so put it under that" — a hand
-- Equipment line on the open sheet, sorted straight after the XbotGo Falcon
-- camera line (same sort_order, later id).  One payment, no installments.

BEGIN;

INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, sort_order)
SELECT v.id, 'equipment', 'SD card for XbotGo Falcon camera', 1, 37.95, 37.95,
       COALESCE((SELECT c.sort_order FROM invoice_lines c
                  WHERE c.invoice_id = v.id AND c.description = 'XbotGo Falcon camera' LIMIT 1), 50)
  FROM invoices v
 WHERE v.issuer_id = 1 AND v.invoice_year = 2026 AND v.invoice_number = 24 AND NOT v.is_final
   AND NOT EXISTS (SELECT 1 FROM invoice_lines l
                    WHERE l.invoice_id = v.id AND l.description = 'SD card for XbotGo Falcon camera');

UPDATE invoices SET updated_at = now() WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 24;

INSERT INTO schema_migrations (filename) VALUES ('1658-sd-card-invoice-24.sql') ON CONFLICT DO NOTHING;
COMMIT;
