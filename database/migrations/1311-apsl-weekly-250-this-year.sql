-- 1311 (2026-11-13): the $250 Mondays pay THIS year's APSL dues.
--
-- Owner: "the 250 a week should be applied to this year" (after the fresh
-- start, mig 1310).  The $2,230 balance (mig 894: $250 every Monday from
-- Nov 2, last $230 on Dec 28) is 2026-27 money:
--   * cash-flow rows back on (they carry the weekly outflow on #finances)
--   * team_season_installments for entry 1 = the nine payments
--   * budget_lines 1 counts that $2,230 as covered by those rows, so the
--     grid does not show it twice; the other $710 of the $2,940 rate card
--     stays owed until the owner says when / whether it was paid.

BEGIN;

UPDATE cash_flow_planned SET is_active = true
 WHERE scope = 'apsl' AND category = 'league_dues' AND label LIKE 'APSL league balance%';

INSERT INTO team_season_installments (entry_id, due_on, amount, note)
SELECT 1, d::date, CASE WHEN d::date = '2026-12-28' THEN 230.00 ELSE 250.00 END,
       'APSL balance, $250 Mondays (' || row_number() OVER (ORDER BY d) || ' of 9)'
  FROM generate_series('2026-11-02'::date, '2026-12-28'::date, interval '7 days') d;

UPDATE budget_lines
   SET paid_before_usd = 2230.00,
       note = '$1,750 club fee − $250 reserve credit + 36 players × $40 (mig 965). 2026-27: $2,230 paid $250 Mondays Nov 2–Dec 28 (cash-flow rows, mig 1311) — counted here so it is not shown twice; $710 left owed, timing unknown'
 WHERE id = 1;

DO $$ BEGIN
  IF (SELECT sum(amount) FROM team_season_installments WHERE entry_id = 1) <> 2230 THEN
    RAISE EXCEPTION 'APSL installments do not sum to 2230';
  END IF;
END $$;

INSERT INTO schema_migrations (filename) VALUES ('1311-apsl-weekly-250-this-year.sql') ON CONFLICT DO NOTHING;
COMMIT;
