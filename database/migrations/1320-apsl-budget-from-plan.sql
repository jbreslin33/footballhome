-- 1320 (2026-11-13): Budget reads APSL from its plan; old APSL rows deleted.
--
-- Owner: "switch the budget page to the plan for apsl … get rid of old data!"
--
--   team_season_entries.budget_from_plan  an entry cut over: Budget reads it
--        ONLY from team_fee_plans (the year = rate × quantity) and
--        team_season_installments (when league money is paid).  Others stay on
--        budget_lines / cash_flow_planned until their own review.
--   team_season_entries.budget_scope      Who pill for an entry whose team has
--        no pill of its own (Reserves 938 → APSL).
--   Deleted: APSL's budget_lines row 1 (+ its budget_line_fees) and every
--        APSL cash_flow_planned row.  The APSL referee policy (1) stays: it
--        lists the home games for invoice ticks and draws the refs line — its
--        seasons (6 fall + 5 spring) must equal the plan's 11.
--   Year plan pill on #finances; categories Filming & media / Medical join
--        the grid's order.

BEGIN;

ALTER TABLE team_season_entries
  ADD COLUMN IF NOT EXISTS budget_from_plan boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS budget_scope text REFERENCES cash_flow_scopes(code);
COMMENT ON COLUMN team_season_entries.budget_from_plan IS 'Budget reads this entry only from team_fee_plans + team_season_installments (mig 1320)';
COMMENT ON COLUMN team_season_entries.budget_scope IS 'Who pill when the team has none of its own (mig 1320)';

UPDATE team_season_entries SET budget_from_plan = true WHERE id IN (1, 16);
UPDATE team_season_entries SET budget_scope = 'apsl' WHERE id = 16;

-- old APSL data
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM invoice_lines WHERE budget_line_id = 1)
  OR EXISTS (SELECT 1 FROM invoice_installment_plans WHERE budget_line_id = 1) THEN
    RAISE EXCEPTION 'invoices still count toward budget line 1';
  END IF;
END $$;
DELETE FROM budget_line_fees WHERE budget_line_id = 1;
DELETE FROM budget_lines WHERE id = 1;
DELETE FROM cash_flow_planned WHERE scope = 'apsl';

-- the refs policy's season counts are the plan's home games
DO $$ BEGIN
  IF (SELECT sum(home_games_expected) FROM ref_fee_seasons WHERE policy_id = 1)
     <> (SELECT quantity FROM team_fee_plans WHERE entry_id = 1 AND league_fee_id = 5) THEN
    RAISE EXCEPTION 'APSL ref seasons disagree with the plan''s home games';
  END IF;
END $$;

-- wording
UPDATE message_templates SET body = body || '|media|medical'
 WHERE kind = 'finances' AND tier = 'category_order' AND body NOT LIKE '%media%';
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public) VALUES
  ('Finances', 'Finances — Year plan pill',            'finances', 'pill_plan',       'Year plan', true, 2, true, false),
  ('Finances', 'Finances — Year plan heading',         'finances', 'plan_title',      '🗓 Year plan — what the year really costs', true, 70, true, false),
  ('Finances', 'Finances — Year plan note',            'finances', 'plan_note',       'Rate × quantity for the budget year (Aug 1 – Jul 31), from each team''s fee plan. * = assumed. When it gets paid is under Expenses and on Money In & Out.', true, 71, true, false),
  ('Finances', 'Finances — Year plan columns',         'finances', 'plan_columns',    'Line|Rate × qty|Year', true, 72, true, false),
  ('Finances', 'Finances — Year plan total',           'finances', 'plan_total',      'Total', true, 73, true, false),
  ('Finances', 'Finances — Year plan per player',      'finances', 'plan_per_player', 'Per player ({players} planned): {cost} — {pct} of {dues} a year in dues', true, 74, true, false),
  ('Finances', 'Finances — Year plan empty',           'finances', 'plan_empty',      'No team under this pill is on the year plan yet — its costs are still the old rows under Expenses.', true, 75, true, false),
  ('Finances', 'Finances — plan league payments row',  'finances', 'plan_payments',   '{scope} league payments', true, 76, true, false);

INSERT INTO schema_migrations (filename) VALUES ('1320-apsl-budget-from-plan.sql') ON CONFLICT DO NOTHING;
COMMIT;
