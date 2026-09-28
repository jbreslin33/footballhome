-- 479 (2026-09-28) — Undo 478: James's 2026.19 stays as billed, 60 h and
-- no day rows.  Owner, on seeing the sheet's 60 h next to blank days:
-- "oh your right … that is ok. my bad … leave it."  The days begin with
-- the next invoice; 478 had already run, so this puts #19 back.
DELETE FROM invoice_work_shifts w
 USING invoices v JOIN invoice_issuers i ON i.id = v.issuer_id
 WHERE w.invoice_id = v.id AND i.person_id = 1 AND v.invoice_year = 2026 AND v.invoice_number = 19;
