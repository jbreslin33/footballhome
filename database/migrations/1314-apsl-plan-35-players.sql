-- 1314 (2026-11-13): APSL main roster planned at 35 players.
--
-- Owner: "that is where the assumption of 35 players comes in. it protects us
-- for future adds."  21 registered so far + 14 future adds × $40 = $560,
-- paid as players are added (assumed Dec–May, a few a month).

BEGIN;

UPDATE team_fee_plans SET quantity = 35, is_assumed = true,
       note = '35 planned to cover future adds: 21 registered so far + 14 adds (owner 2026-11-13)'
 WHERE entry_id = 1 AND league_fee_id = 3;

INSERT INTO team_season_installments (entry_id, due_on, amount, note) VALUES
  (1, '2026-12-31', 120.00, 'Future main-roster adds 1–3 of 14 × $40'),
  (1, '2027-01-31', 120.00, 'Future main-roster adds 4–6 of 14 × $40'),
  (1, '2027-02-28',  80.00, 'Future main-roster adds 7–8 of 14 × $40'),
  (1, '2027-03-31',  80.00, 'Future main-roster adds 9–10 of 14 × $40'),
  (1, '2027-04-30',  80.00, 'Future main-roster adds 11–12 of 14 × $40'),
  (1, '2027-05-31',  80.00, 'Future main-roster adds 13–14 of 14 × $40');

INSERT INTO cash_flow_planned (ym, label, amount, scope, category, is_active) VALUES
  ('2026-12', 'APSL player adds 1, 2, 3 of 14 at $40',   120.00, 'apsl', 'registrations', true),
  ('2027-01', 'APSL player adds 4, 5, 6 of 14 at $40',   120.00, 'apsl', 'registrations', true),
  ('2027-02', 'APSL player adds 7, 8 of 14 at $40',       80.00, 'apsl', 'registrations', true),
  ('2027-03', 'APSL player adds 9, 10 of 14 at $40',      80.00, 'apsl', 'registrations', true),
  ('2027-04', 'APSL player adds 11, 12 of 14 at $40',     80.00, 'apsl', 'registrations', true),
  ('2027-05', 'APSL player adds 13, 14 of 14 at $40',     80.00, 'apsl', 'registrations', true);

UPDATE budget_lines
   SET amount_usd = 3030.00, paid_before_usd = 3030.00,
       note = '$1,750 club fee + 35 main × $40 (21 registered + 14 future adds) + 26 reserves × $5, less the $250 reserve credit at year end. $490 paid before 10/30; the rest are cash-flow rows (migs 1313/1314) — counted here so nothing shows twice'
 WHERE id = 1;

DO $$ BEGIN
  IF (SELECT sum(amount) FROM team_season_installments WHERE entry_id IN (1, 16))
     <> (SELECT sum(proposed) FROM team_fee_plan_lines WHERE entry_id IN (1, 16) AND category <> 'referees') THEN
    RAISE EXCEPTION 'APSL payments do not match the plan';
  END IF;
END $$;

INSERT INTO schema_migrations (filename) VALUES ('1314-apsl-plan-35-players.sql') ON CONFLICT DO NOTHING;
COMMIT;
