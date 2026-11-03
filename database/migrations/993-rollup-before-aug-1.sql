-- 993 (2026-11-03) — roll-up: a "Before Aug 1" column for season money paid
-- before the budget year (budget_lines.paid_before_usd, e.g. APSL installments
-- 1–13).  Owner: "for year we need to account for all expenses for leagues as
-- they all are contained within aug 1 to july 31".  Counted in the year's
-- cost, never in a month's cash.
UPDATE message_templates SET body = 'Kind|Before Aug 1|Actual|Ahead|Year' WHERE kind = 'cash_flow' AND tier = 'rollup_cols';
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Finances', 'Roll-up line — paid before the year', 'cash_flow', 'prepaid_tag', NULL, 'Paid before Aug 1', 57, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'cash_flow' AND tier = 'prepaid_tag');
