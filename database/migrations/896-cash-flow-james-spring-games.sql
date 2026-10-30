-- 896 (2026-10-30) — #cash-flow: James's pay for the assumed spring games.
--
-- Owner: "assume coach pay for me as coach of both for all apsl/liga1 (its
-- combined) till may".  Games on the calendar through December already pay
-- through it.  April and May's games are assumed, so they are planned here at
-- the coaching policy rates, APSL $60 and Liga 1 $49 at James's $20 an hour.
-- Each assumed home game is matched by an away game, as the spring seasons
-- expect (ref_fee_seasons: all games = home games × 2 for APSL).

INSERT INTO cash_flow_planned (ym, label, amount)
SELECT v.ym, v.label, v.amount
  FROM (VALUES ('2027-04', 'James coach pay, 4 APSL and 4 Liga 1 games', 436.00),
               ('2027-05', 'James coach pay, 2 APSL and 2 Liga 1 games', 218.00)) AS v(ym, label, amount)
 WHERE NOT EXISTS (SELECT 1 FROM cash_flow_planned p WHERE p.ym = v.ym AND p.label = v.label);
