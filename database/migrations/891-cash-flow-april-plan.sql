-- 891 (2026-10-30) — #cash-flow: April.
--
-- Owner: "april assume 2 apsl home and 2 liga 1 home. assume youth game like in
-- fall."  Referee fees at the ref_fee_policies rates: APSL $310, Liga 1 $130.
-- Youth is October's home games: U8 ×1, U10 ×2, U12 ×2.

INSERT INTO cash_flow_planned (ym, label, amount)
SELECT v.ym, v.label, v.amount
  FROM (VALUES ('2027-04', 'APSL referee fees, 2 home games', 620.00),
               ('2027-04', 'Liga 1 referee fees, 2 home games', 260.00),
               ('2027-04', 'Youth referee fees, like October', 145.00)) AS v(ym, label, amount)
 WHERE NOT EXISTS (SELECT 1 FROM cash_flow_planned p WHERE p.ym = v.ym AND p.label = v.label);
