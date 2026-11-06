-- James's 2026.23 (invoice 24) had day rows (23.65 h on 11/6) but no labor
-- line, so syncLabor had nothing to write the hours into and the sheet billed
-- $0 for them.  Every sheet is created with one (Invoice::createNumbered);
-- put it back at the issuer's rate, summed from the rows.
INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, sort_order)
SELECT 24, 'labor', COALESCE(NULLIF(ii.duty_description, ''), 'Hours'), h.hours, ii.hourly_rate, ROUND(h.hours * ii.hourly_rate, 2), 1
  FROM invoices v JOIN invoice_issuers ii ON ii.id = v.issuer_id,
       LATERAL (SELECT ROUND(COALESCE(SUM(COALESCE(s.hours, EXTRACT(EPOCH FROM (s.end_at - s.start_at)) / 3600.0)), 0)::numeric, 2) AS hours
                  FROM invoice_work_shifts s WHERE s.invoice_id = v.id) h
 WHERE v.id = 24 AND NOT v.is_final
   AND NOT EXISTS (SELECT 1 FROM invoice_lines l WHERE l.invoice_id = 24 AND l.category = 'labor');
UPDATE invoices SET updated_at = now() WHERE id = 24;
