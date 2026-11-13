-- 1327 (2026-11-13): Liga 1 reviewed; Budget reads it from its plan, old rows deleted.
--
-- Owner: "liga 1 league dues 1899. 22 games. refs every game 130 a game …
-- player registrations same 25 free then charged."
--   dues      $1,899 (CASA's late price, fee 8) — was planned at $1,799 general
--   players   35 planned like APSL / U23: 25 included + 10 × $23 (assumed)
--   refs      $130 every game, both teams pay, 22 games (12 fall + 10 spring);
--             the Liga 1 ref policy (2) still draws them and ticks invoices
--   payments  the CASA payment plan on file: $519.49 (Jul), $250.20 Aug 29,
--             $250.19 Oct 28 / Dec 27 / Feb 25 / Apr 26 = $1,770.45; the other
--             $128.55 of the $1,899 has no date yet → owed at the end (May);
--             10 player adds × $23 as they come, Dec–Apr
--   coaching  Liga 1 game coaching books under Men's like APSL's ("generic
--             mens coaching"); its spring count 12 → 10 to match the 22 games
--   deleted   budget_lines 2 (+ fees; invoice plans 10/17 unlinked, they stay
--             on #invoices) and every Liga 1 cash_flow_planned row

BEGIN;

-- plan
UPDATE team_fee_plans SET league_fee_id = 8, is_assumed = false,
       note = '$1,899 (owner 2026-11-13) — CASA''s late price'
 WHERE entry_id = 2 AND league_fee_id = 7;
UPDATE team_fee_plans SET quantity = 10, is_assumed = true,
       note = '35 planned like APSL: 25 included + 10 × $23 (owner 2026-11-13)'
 WHERE entry_id = 2 AND league_fee_id = 9;
UPDATE team_fee_plans SET quantity = 22, is_assumed = false,
       note = '22 games, $130 every game (owner 2026-11-13)'
 WHERE entry_id = 2 AND league_fee_id = 10;
UPDATE ref_fee_seasons SET is_assumed = false WHERE policy_id = 2;
UPDATE ref_fee_seasons SET home_games_expected = 10, is_assumed = false WHERE policy_id = 8 AND label = 'Spring 2027';
UPDATE ref_fee_policies SET budget_scope = 'mens' WHERE id = 8 AND kind = 'coaching';

-- payments
DELETE FROM team_season_installments WHERE entry_id = 2;
INSERT INTO team_season_installments (entry_id, due_on, amount, note) VALUES
  (2, '2026-07-31', 519.49, 'CASA payment plan — paid before Aug 1'),
  (2, '2026-08-29', 250.20, 'CASA payment plan'),
  (2, '2026-10-28', 250.19, 'CASA payment plan'),
  (2, '2026-12-27', 250.19, 'CASA payment plan'),
  (2, '2027-02-25', 250.19, 'CASA payment plan'),
  (2, '2027-04-26', 250.19, 'CASA payment plan'),
  (2, '2027-05-31', 128.55, 'Rest of the $1,899 — not on the payment plan on file, date unknown'),
  (2, '2026-12-31',  46.00, 'Player adds 1–2 of 10 × $23'),
  (2, '2027-01-31',  46.00, 'Player adds 3–4 of 10 × $23'),
  (2, '2027-02-28',  46.00, 'Player adds 5–6 of 10 × $23'),
  (2, '2027-03-31',  46.00, 'Player adds 7–8 of 10 × $23'),
  (2, '2027-04-30',  46.00, 'Player adds 9–10 of 10 × $23');

DO $$ BEGIN
  IF (SELECT sum(amount) FROM team_season_installments WHERE entry_id = 2)
     <> (SELECT sum(proposed) FROM team_fee_plan_lines WHERE entry_id = 2 AND category IN ('league_dues', 'registrations')) THEN
    RAISE EXCEPTION 'Liga 1 payments do not match the plan';
  END IF;
  IF (SELECT sum(home_games_expected) FROM ref_fee_seasons WHERE policy_id = 2) <> 22 THEN
    RAISE EXCEPTION 'Liga 1 ref seasons are not 22 games';
  END IF;
END $$;

-- cut over; old data gone
UPDATE team_season_entries SET budget_from_plan = true WHERE id = 2;
UPDATE invoice_installment_plans SET budget_line_id = NULL WHERE budget_line_id = 2;
UPDATE invoice_lines SET budget_line_id = NULL WHERE budget_line_id = 2;
DELETE FROM budget_line_fees WHERE budget_line_id = 2;
DELETE FROM budget_lines WHERE id = 2;
DELETE FROM cash_flow_planned WHERE scope = 'liga1';

INSERT INTO schema_migrations (filename) VALUES ('1327-liga1-budget-from-plan.sql') ON CONFLICT DO NOTHING;
COMMIT;
