-- 1322 (2026-11-13): Cups 2026-27 from the owner; Budget reads Cups from its plan.
--
-- Owner: "this year no us open cup. we will enter next year … we lost [the
-- amateur cup]. we still owe money for all of them … state cup didn't happen
-- yet."
--   * USASA Amateur Cup 2026/27 (entry 11): lost 10/18 → status eliminated;
--     owed: $200 entry + $50 qualifying round + $120 our half of the refs
--   * Werner Fricker Open Cup 2026/27 (the state open cup): entered, not
--     played yet — EPSA Open Mens $250 (remittance form 8/28/2026, fee 33)
--   * Grassroots 2027 stays $1,400 general, assumed (tier/refs still to ask)
--   * U.S. Open Cup: next year only (entry 14, 2027-28) — unchanged
-- Every Cups entry goes on the plan (budget_from_plan); old Cups budget_lines
-- 30–33 deleted.  An eliminated entry's remaining costs are owed now.

BEGIN;

ALTER TABLE team_season_entries DROP CONSTRAINT IF EXISTS team_season_entries_status_check;
ALTER TABLE team_season_entries ADD CONSTRAINT team_season_entries_status_check
  CHECK (status = ANY (ARRAY['planned', 'entered', 'eliminated', 'withdrawn']));

-- Amateur Cup 2026/27: lost 10/18
UPDATE team_season_entries SET status = 'eliminated',
       note = 'Played 10/18 at Phoenix SCM, lost (owner 2026-11-13); entry, qualifying round and our refs half still owed'
 WHERE id = 11;
UPDATE team_fee_plans SET note = 'Still owed (owner 2026-11-13)' WHERE entry_id = 11 AND league_fee_id = 28;
INSERT INTO team_fee_plans (entry_id, league_fee_id, season_id, quantity, is_assumed, note) VALUES
  (11, 29, 43, 1, false, 'Qualifying round entry — still owed (owner 2026-11-13)'),
  (11, 32, 43, 1, false, 'Our half of the refs for the 10/18 game — still owed (owner 2026-11-13)')
ON CONFLICT (entry_id, league_fee_id) DO NOTHING;

-- Werner Fricker Open Cup 2026/27 = the state open cup: entered, not played
-- yet.  Season 45 and its EPSA Open Mens $250 fee (33) already exist.
WITH e AS (
  INSERT INTO team_season_entries (team_id, season_id, status, note, division_id, budget_from_plan)
  VALUES (939, 45, 'entered', 'State open cup 2026/27, not played yet (owner 2026-11-13)', 17, true)
  ON CONFLICT (team_id, season_id) DO UPDATE SET status = 'entered', budget_from_plan = true
  RETURNING id
)
INSERT INTO team_fee_plans (entry_id, league_fee_id, season_id, quantity, is_assumed, note)
SELECT e.id, 33, 45, 1, false, 'Still owed (owner 2026-11-13)' FROM e
ON CONFLICT (entry_id, league_fee_id) DO NOTHING;

-- Cups on the plan; old rows gone
UPDATE team_season_entries SET budget_from_plan = true WHERE team_id = 939;
DELETE FROM budget_line_fees WHERE budget_line_id IN (30, 31, 32, 33);
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM invoice_lines WHERE budget_line_id IN (30, 31, 32, 33))
  OR EXISTS (SELECT 1 FROM invoice_installment_plans WHERE budget_line_id IN (30, 31, 32, 33)) THEN
    RAISE EXCEPTION 'invoices still count toward a Cups budget line';
  END IF;
END $$;
DELETE FROM budget_lines WHERE id IN (30, 31, 32, 33);

INSERT INTO schema_migrations (filename) VALUES ('1322-cups-this-year.sql') ON CONFLICT DO NOTHING;
COMMIT;
