-- 892 (2026-10-30) — #cash-flow: May.
--
-- Owner: "may 1 home game for apsl and liga 1".  One each, at the
-- ref_fee_policies rates: APSL $310, Liga 1 $130.

INSERT INTO cash_flow_planned (ym, label, amount)
SELECT v.ym, v.label, v.amount
  FROM (VALUES ('2027-05', 'APSL referee fees, 1 home game', 310.00),
               ('2027-05', 'Liga 1 referee fees, 1 home game', 130.00)) AS v(ym, label, amount)
 WHERE NOT EXISTS (SELECT 1 FROM cash_flow_planned p WHERE p.ym = v.ym AND p.label = v.label);
