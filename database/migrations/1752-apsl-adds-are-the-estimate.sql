-- 1752 (2026-11-23): APSL player fees — say which part is fact and which is the estimate.
--
-- Owner 2026-11-23: "35 main 35 reserve is a fact. 40 to add a main and $5 to
-- add a reserve. what is variable is the amount of adds as it could go over 35
-- in both cases and the 1st 25 of liga are in dues for liga is a fact".
--
-- Already stored as facts: teams.max_roster = 35 (main 35, reserves 938,
-- Liga 1 120), league_fees $40 / $5 per add, Liga 1 team_entry
-- players_included = 25 then $23.  The plan quantity is the estimate (how
-- many adds in the season; an add and a drop both use one, so it can pass 35)
-- and stays is_assumed.  Wording only — no number changes.

BEGIN;

UPDATE league_fees SET note = 'Each player added to the main roster (roster of 35)' WHERE id = 3;
UPDATE league_fees SET note = 'Each player added to the reserves list (list of 35)' WHERE id = 51;

UPDATE team_fee_plans SET is_assumed = true,
       note = 'Estimate: 35 adds in the season. Roster is 35; every add costs $40, so adds and drops can take it past 35 (owner 2026-11-23)'
 WHERE id IN (3, 40);
UPDATE team_fee_plans SET is_assumed = true,
       note = 'Estimate: 50 adds in the season. List is 35; every add costs $5 and Liga 1 men are added and dropped all year (owner 2026-11-23)'
 WHERE id IN (5, 42);
UPDATE team_fee_plans SET is_assumed = true,
       note = 'Estimate: 10 players past the 25 the league dues include, $23 each; roster is 35 (owner 2026-11-23)'
 WHERE id IN (7, 47);

INSERT INTO schema_migrations (filename) VALUES ('1752-apsl-adds-are-the-estimate.sql') ON CONFLICT DO NOTHING;
COMMIT;
