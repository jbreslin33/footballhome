-- 893 (2026-10-30) — #cash-flow: the Liga 1 payments still to come.
--
-- Owner: "liga 1 payment schedule left: dec 27 250.19, feb 25 250.19, apr 26
-- 250.19".

INSERT INTO cash_flow_planned (ym, label, amount)
SELECT v.ym, v.label, v.amount
  FROM (VALUES ('2026-12', 'Liga 1 league payment, Dec 27', 250.19),
               ('2027-02', 'Liga 1 league payment, Feb 25', 250.19),
               ('2027-04', 'Liga 1 league payment, Apr 26', 250.19)) AS v(ym, label, amount)
 WHERE NOT EXISTS (SELECT 1 FROM cash_flow_planned p WHERE p.ym = v.ym AND p.label = v.label);
