-- 1426 (2026-11-16): Men's 2027-28 plans on 70 paying men every season (full
-- house). Owner: "next year should show 70 players". Same as typing 70 in
-- 💵 Men's money → Paying men per season → all; clear the box to go back.
BEGIN;
UPDATE program_season_plans p
   SET players = 70, updated_at = now(),
       note = 'Owner 11/16: 70 paying men next year (full house) — mig 1426'
  FROM finance_programs f, budget_years y
 WHERE f.id = p.program_id AND f.code = 'mens' AND y.id = p.budget_year_id AND y.label = '2027-28';
INSERT INTO schema_migrations (filename) VALUES ('1426-mens-2027-28-seventy-players.sql') ON CONFLICT DO NOTHING;
COMMIT;
