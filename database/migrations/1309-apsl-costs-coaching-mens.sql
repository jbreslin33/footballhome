-- 1309 (2026-11-13): APSL Men costs, proof of concept (owner reviewing APSL only).
--
-- Owner: "player adds are redundant. except reserves are $5 each" — the 36
-- players × $40 on the rate card plan already cover APSL registrations, so the
-- 15 × $40 "APSL player adds" cash-flow rows double-count.  Reserves adds
-- ($5, team_fee_plans entry 16) stay.
--
-- Owner: "don't put coaching under apsl … because its generic mens coaching".
-- The APSL coaching policy keeps its team + league labels (they find the
-- games) but books under Men's.  New column ref_fee_policies.budget_scope
-- overrides the scope the team/labels would give.
--
-- Refs unchanged: $310 × 11 home games, 6 fall + 5 spring, spread evenly
-- (ref_fee_seasons 1/2, game_weekday NULL) — already what the owner said.

BEGIN;

ALTER TABLE ref_fee_policies
  ADD COLUMN IF NOT EXISTS budget_scope text REFERENCES cash_flow_scopes(code);
COMMENT ON COLUMN ref_fee_policies.budget_scope IS
  'Who pill this policy books under when not the one its team/league labels give (mig 1309)';

CREATE OR REPLACE FUNCTION public.cash_flow_policy_scope(p_policy integer)
 RETURNS text LANGUAGE sql STABLE AS $function$
  SELECT COALESCE(p.budget_scope, cash_flow_team_scope(p.team_id), cash_flow_scope(p.event_category, p.event_league_labels[1]))
    FROM ref_fee_policies p WHERE p.id = p_policy $function$;

-- APSL game coaching = generic men's coaching
UPDATE ref_fee_policies SET budget_scope = 'mens'
 WHERE id = 7 AND kind = 'coaching' AND team_id = 35;

-- APSL $40 player adds: redundant with the 36 on the plan
UPDATE cash_flow_planned SET is_active = false
 WHERE scope = 'apsl' AND category = 'registrations' AND label LIKE 'APSL player adds %';

INSERT INTO schema_migrations (filename) VALUES ('1309-apsl-costs-coaching-mens.sql') ON CONFLICT DO NOTHING;
COMMIT;
