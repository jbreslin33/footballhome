-- 475 (2026-09-27) — Jamie Arevalo's usual week: 2 hours every Sunday.
-- Owner: "for jamie it should default to 2 hours every sunday" — a flat
-- number, no from/till (mig 474 allows either).
INSERT INTO invoice_default_shifts (issuer_id, weekday, hours)
SELECT i.id, 0, 2.00 FROM invoice_issuers i
 WHERE i.person_id = 22193
   AND NOT EXISTS (SELECT 1 FROM invoice_default_shifts x WHERE x.issuer_id = i.id AND x.weekday = 0);
