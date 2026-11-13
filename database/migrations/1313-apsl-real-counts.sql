-- 1313 (2026-11-13): APSL 2026-27 from the owner's real numbers.
--
-- Owner: "we only registered 21 players so far to main and 26 players to
-- reserves … assume like 5 more which is $25 … the current balance does not
-- include 36 players. it does include 1750 … we also would have paid some of
-- it previously … credit is applied at end of year … lets not over complicate."
--
--   club fee $1,750 + 21 × $40 + 26 × $5      = $2,720 billed so far
--   balance on 10/30 (mig 894)                = $2,230  → $490 paid before
--   $250 Mondays Nov 2 – Dec 21, $230 Dec 28  = $2,230  (balance paid off)
--   5 more reserves × $5                      = $25     (December)
--   reserve-team credit                       = −$250   (end of year, July)
--
-- Replaces mig 1312 (36 players, $2,940, payments to Jan 18).

BEGIN;

-- plan quantities
UPDATE team_fee_plans SET quantity = 21, is_assumed = false,
       note = '21 registered to the main roster so far (owner 2026-11-13)'
 WHERE entry_id = 1 AND league_fee_id = 3;
UPDATE team_fee_plans SET quantity = 31, is_assumed = true,
       note = '26 registered + ~5 more after drops (owner 2026-11-13)'
 WHERE entry_id = 16 AND league_fee_id = 51;
UPDATE team_fee_plans SET note = 'Credited at the end of the year (owner 2026-11-13)'
 WHERE entry_id = 1 AND league_fee_id = 2;

-- what gets paid when (both APSL entries' money is one APSL bill; it is
-- recorded on entry 1, the overage on entry 16)
DELETE FROM team_season_installments WHERE entry_id IN (1, 16);
INSERT INTO team_season_installments (entry_id, due_on, amount, note)
VALUES (1, '2026-10-30', 490.00, 'Paid before 10/30: $2,720 billed − $2,230 balance (incl. 26 reserves × $5)');
INSERT INTO team_season_installments (entry_id, due_on, amount, note)
SELECT 1, d::date, CASE WHEN d::date = '2026-12-28' THEN 230.00 ELSE 250.00 END,
       'APSL balance, $250 Mondays (' || row_number() OVER (ORDER BY d) || ' of 9)'
  FROM generate_series('2026-11-02'::date, '2026-12-28'::date, interval '7 days') d;
INSERT INTO team_season_installments (entry_id, due_on, amount, note) VALUES
  (1,  '2027-07-31', -250.00, 'Reserve-team credit, applied at the end of the year'),
  (16, '2026-12-31',   25.00, '~5 more reserves × $5');

-- cash flow (#finances / #cash-flow still read these rows)
UPDATE cash_flow_planned SET is_active = false
 WHERE scope = 'apsl' AND (label LIKE 'APSL dues, payments%' OR label LIKE 'Reserves player adds%');
UPDATE cash_flow_planned SET is_active = true
 WHERE scope = 'apsl' AND label LIKE 'APSL league balance%';
INSERT INTO cash_flow_planned (ym, label, amount, scope, category, is_active) VALUES
  ('2026-12', 'Reserves player adds, ~5 more at $5', 25.00, 'apsl', 'registrations', true),
  ('2027-07', 'APSL reserve-team credit',          -250.00, 'apsl', 'league_dues',   true);

-- the old dues line: the year is fully carried by the paid $490 + the rows above
UPDATE budget_lines
   SET amount_usd = 2470.00, paid_before_usd = 2470.00,
       label = 'APSL league dues + player fees',
       note = '$1,750 club fee + 21 × $40 + 26 reserves × $5 = $2,720, less the $250 reserve credit at year end. $490 paid before 10/30; $2,230 in $250 Mondays to Dec 28 and the credit are cash-flow rows (mig 1313) — counted here so nothing shows twice'
 WHERE id = 1;

DO $$ BEGIN
  IF (SELECT sum(amount) FROM team_season_installments WHERE entry_id IN (1, 16))
     <> (SELECT sum(proposed) FROM team_fee_plan_lines WHERE entry_id IN (1, 16) AND category <> 'referees') THEN
    RAISE EXCEPTION 'APSL payments do not match the plan';
  END IF;
END $$;

INSERT INTO schema_migrations (filename) VALUES ('1313-apsl-real-counts.sql') ON CONFLICT DO NOTHING;
COMMIT;
