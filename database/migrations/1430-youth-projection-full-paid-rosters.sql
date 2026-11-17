-- 1430 (2026-11-16): 🧩 youth projections = every team full and paid.
-- Owner: "for youth projections project full paid roster for each team. its a
-- projection."
--   ProgramBudget.cpp: a youth plan season's default players = teams (typed,
--   else today's, at least one) × the program's roster, no collection-rate
--   discount. Real seasons and adults unchanged; a typed players box still wins.
--   Roster per program = finance_programs.roster_size (owner 11/15, mig 1387:
--   "all 12 total except u12 16 and u13 to u16 18"). Its own column because mig
--   1416 cleared the winter groups' teams.max_roster (no board cap), which had
--   also been the projection's roster.
BEGIN;
ALTER TABLE finance_programs ADD COLUMN IF NOT EXISTS roster_size integer CHECK (roster_size > 0);
COMMENT ON COLUMN finance_programs.roster_size IS 'Full roster per team for projections / Full capacity (mig 1430); NULL = the teams'' max_roster';
UPDATE finance_programs SET roster_size = CASE
         WHEN age_from BETWEEN 13 AND 16 THEN 18
         WHEN age_from = 12 THEN 16
         ELSE 12 END
 WHERE kind = 'youth' AND roster_size IS NULL;
INSERT INTO schema_migrations (filename) VALUES ('1430-youth-projection-full-paid-rosters.sql') ON CONFLICT DO NOTHING;
COMMIT;
