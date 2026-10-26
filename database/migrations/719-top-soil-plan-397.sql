-- 719 (2026-10-26) — Top Soil was ONE $397 purchase, already billed whole
-- on 2026.18 (owner: "it was 397 total … take it off this and all future
-- invoices. unless we order more of course").  465 seeded it as a 4×$397
-- plan ($1,588), so new invoices kept carrying "k of 4".  The plan becomes
-- $397 in 1 — closed, openPlans() stops carrying it — and James's 2026.21
-- loses its line.  2026.20 (may already be sent) is left for the owner.
-- More soil later = a new plan from the calendar's ＋.
UPDATE invoice_installment_plans SET total_amount = 397.00, installment_count = 1
 WHERE id = 9 AND issuer_id = 1 AND description = 'Top Soil';
DELETE FROM invoice_lines l USING invoices v
 WHERE v.id = l.invoice_id AND NOT v.is_final AND l.plan_id = 9
   AND v.issuer_id = 1 AND v.invoice_year = 2026 AND v.invoice_number = 21;
UPDATE invoices SET updated_at = now() WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 21;
