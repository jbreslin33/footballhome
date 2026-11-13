-- 1310 (2026-11-13): APSL fresh start for 2026-27.
--
-- Owner: "the previous stuff was prob paying off last year … so for apsl we
-- need a sort of fresh start … or the budget will be skewed."
--
-- What came before Aug 1 and the payments tied to it are last season's:
--   * the 16-payment "APSL League Dues" plan on #invoices (plan 12, $2,940,
--     13 paid before Aug 1) — stays on #invoices as history, no longer counts
--     toward this year's APSL dues budget line
--   * budget_lines 1 paid_before_usd $2,388.75 → 0
--   * the $2,230 "APSL league balance, $250 Mondays" cash-flow rows (mig 894)
--   * team_season_installments for entry 1 (APSL 2026/27)
-- This year = rate card × quantity (team_fee_plans entry 1): $1,750 − $250
-- reserve credit + 36 × $40 = $2,940, not yet scheduled.  Refs already
-- ticked on invoices are this year's games and stay.

BEGIN;

UPDATE invoice_installment_plans SET budget_line_id = NULL
 WHERE id = 12 AND budget_line_id = 1;
UPDATE invoice_lines SET budget_line_id = NULL WHERE budget_line_id = 1;

UPDATE budget_lines
   SET paid_before_usd = 0,
       note = '$1,750 club fee − $250 reserve credit + 36 players × $40 (APSL Delaware River fees, mig 965). Fresh start 2026-27: last season''s payments no longer count here (mig 1310)'
 WHERE id = 1;

UPDATE cash_flow_planned SET is_active = false
 WHERE scope = 'apsl' AND category = 'league_dues' AND label LIKE 'APSL league balance%';

DELETE FROM team_season_installments WHERE entry_id = 1;

INSERT INTO schema_migrations (filename) VALUES ('1310-apsl-fresh-start.sql') ON CONFLICT DO NOTHING;
COMMIT;
