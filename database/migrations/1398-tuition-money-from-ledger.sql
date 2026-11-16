-- 1398 (2026-11-16) — #tuition money boxes from the payments, not the members
-- (owner: "tuition for nov looks off. if so are others off too?" → "we
-- should be counting money gotten from pickup guys … we are couning their
-- money lol"). GET /api/payments/ledger (DuesLedger): every counted soccer
-- payment by section + month since the books start (Aug 1), pickup and
-- people who left included — as #finances. Collected = since Aug 1; Avg =
-- the last finished months (up to 3, as #finances projects). Words only.
UPDATE message_templates SET body = 'MONEY IN · SINCE {start}'
 WHERE kind = 'payments_overview' AND tier = 'split_row_collected';
UPDATE message_templates SET body = 'MONEY IN · AVG / MONTH (last {months} finished)'
 WHERE kind = 'payments_overview' AND tier = 'split_row_avg';
