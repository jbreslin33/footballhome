-- 1315 (2026-11-13): APSL Reserves planned at 35 players too.
-- Owner: "assume 35 reserves too" — 26 registered + 9 future adds × $5 = $45.

BEGIN;

UPDATE team_fee_plans SET quantity = 35, is_assumed = true,
       note = '35 planned to cover future adds: 26 registered + 9 adds (owner 2026-11-13)'
 WHERE entry_id = 16 AND league_fee_id = 51;

UPDATE team_season_installments SET amount = 45.00, note = 'Future reserves adds, 9 × $5'
 WHERE entry_id = 16 AND due_on = '2026-12-31';

UPDATE cash_flow_planned SET amount = 45.00, label = 'Reserves player adds, 9 more at $5'
 WHERE scope = 'apsl' AND is_active AND label = 'Reserves player adds, ~5 more at $5';

DO $$ BEGIN
  IF (SELECT sum(amount) FROM team_season_installments WHERE entry_id IN (1, 16))
     <> (SELECT sum(proposed) FROM team_fee_plan_lines WHERE entry_id IN (1, 16) AND category <> 'referees') THEN
    RAISE EXCEPTION 'APSL payments do not match the plan';
  END IF;
END $$;

INSERT INTO schema_migrations (filename) VALUES ('1315-apsl-reserves-35.sql') ON CONFLICT DO NOTHING;
COMMIT;
