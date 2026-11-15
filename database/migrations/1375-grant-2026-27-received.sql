-- 1375 (2026-11-14) — the 2026-27 soccer grant is in.
--
-- Owner 2026-11-14: "lh has recieved it" — Lighthouse holds the $50k for
-- 2026-27 (restricted to coaches, referees and equipment, mig 1372). One dated
-- receipt for the full amount (date = the day the owner said so; correct it
-- here if the real deposit date differs) and the award marked received.
BEGIN;

INSERT INTO income_receipts (award_id, received_on, amount_usd, note)
SELECT a.id, DATE '2026-11-14', a.amount_usd, 'Owner 2026-11-14: "lh has recieved it"'
  FROM income_awards a JOIN budget_years y ON y.id = a.budget_year_id
 WHERE y.label = '2026-27' AND a.kind = 'grant' AND a.label = 'Coaches, referees and equipment'
   AND NOT EXISTS (SELECT 1 FROM income_receipts r WHERE r.award_id = a.id);

UPDATE income_awards a SET status = 'received'
  FROM budget_years y
 WHERE y.id = a.budget_year_id AND y.label = '2026-27' AND a.kind = 'grant' AND a.label = 'Coaches, referees and equipment';

COMMIT;
