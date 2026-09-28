-- 478 (2026-09-28) — James's 2026.19 gets its days from his usual 2 weeks.
-- Owner: "for my invoice i gave you the hours for #19 so why don't they
-- show. some over write the defaults but defaults should show for #20
-- when we do that next cycle."  #19 was seeded from the PDF as a 60 h
-- total with no day rows; lay the usual 2 weeks under it so the days can
-- be edited to what was actually worked.  The invoice is final, so the
-- hours line stays at the billed 60 h until Final is un-ticked
-- (Invoice::syncLabor skips final invoices from this migration on).
INSERT INTO invoice_work_shifts (invoice_id, work_date, start_at, end_at, hours, note)
SELECT v.id, (v.period_start + s.day_index)::date, s.start_at, s.end_at, s.hours, s.note
  FROM invoices v
  JOIN invoice_issuers i ON i.id = v.issuer_id AND i.person_id = 1
  JOIN invoice_default_shifts s ON s.issuer_id = i.id
 WHERE v.invoice_year = 2026 AND v.invoice_number = 19
   AND NOT EXISTS (SELECT 1 FROM invoice_work_shifts w WHERE w.invoice_id = v.id)
 ORDER BY s.day_index, s.start_at NULLS LAST;
