-- 840: owner 2026-10-29: "i bought paint too. add field paint 122.21 total".
-- Same sheet as mig 839 (James's 2026.22, 10/23–11/5).  Facilities, beside
-- the seed / top soil field upkeep.  Skipped if already there or final.
INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, sort_order)
SELECT i.id, 'facilities', 'Field Paint', 1, 122.21, 122.21,
       COALESCE((SELECT MAX(sort_order) FROM invoice_lines WHERE invoice_id = i.id), 0) + 1
  FROM invoices i
 WHERE i.issuer_id = 1 AND i.invoice_year = 2026 AND i.invoice_number = 22 AND NOT i.is_final
   AND NOT EXISTS (SELECT 1 FROM invoice_lines l
                    WHERE l.invoice_id = i.id AND l.description = 'Field Paint');
UPDATE invoices SET updated_at = now()
 WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 22;
