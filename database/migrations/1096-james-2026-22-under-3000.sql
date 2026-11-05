-- 1096: owner 2026-11-05: "bring this week under 3000 unload to next one".
-- 2026.22 stood at $3,097.20; Field Paint ($122.21, invoice_lines id 87) moves
-- to 2026.23 — the same row re-pointed, as mig 1095 — leaving $2,974.99.
UPDATE invoice_lines l
   SET invoice_id = (SELECT id FROM invoices WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 23),
       sort_order = 100 + l.sort_order
 WHERE l.id = 87
   AND l.invoice_id = (SELECT id FROM invoices WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 22 AND NOT is_final);
UPDATE invoices SET updated_at = now() WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number IN (22, 23);
