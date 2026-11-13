-- 1341 (2026-11-13): Youth on the Budget plan; Youth pill over Boys + Girls.
--
-- Owner: "girls and boys just combine for now … yes [a Youth pill with Boys
-- and Girls under it]" · league dues "just use those costs" · refs "25 for
-- u8, u10 in fall and 30 for u12" · practices "3 per week but in winter 4 per
-- week until games start again in jan for indoor … all year with holiday
-- breaks" · rosters U8/U10 12, U12 16 (mig 1340).
--
--   pills     Youth (top) › Boys, Girls, U8, U10, U12, Youth all ages
--   plans     PPR Fall U8 $475 / U10 $475 / U12 $500 + $30 assignor each, refs
--             $25 / $25 / $30 × 10; PPR Indoor U10 + U12 $100 + $30, refs $25 ×
--             9 / 10; ICSL Spring U10 + U12 $195 + $10 GotSport, refs $25 / $30 ×
--             6.  Fall counted paid Sep 1 (the PPR invoice plan paid $1,200 of
--             the $1,540 rate card — owner: use the rate card).
--   coaching  game coaching = real games: U8 10 (fall only), U10 25, U12 26
--             (fall 10 + indoor 9/10 + spring 6); Youth pill.  Practices
--             (Boys general): Luke U8 + U10 and Anthony U8 + U12, 3 × 1½ h a
--             team a week = 9 h × $15 = $135 a week each, 50 weeks; December's
--             4th practice +$90 a week (both coaches) for 4 weeks.
--   deleted   budget_lines 4, 8, 9, 11, 12 (+ fees; the PPR invoice plan stays
--             on #invoices) and the youth cash_flow_planned rows

BEGIN;

-- pills
INSERT INTO cash_flow_scopes (code, label, parent, category, leagues, section_code, sort_order, team_id)
VALUES ('youth', 'Youth', NULL, NULL, '{}', NULL, 30, NULL) ON CONFLICT (code) DO NOTHING;
UPDATE cash_flow_scopes SET parent = 'youth', sort_order = 37 WHERE code = 'boys';
UPDATE cash_flow_scopes SET parent = 'youth', sort_order = 38 WHERE code = 'girls';
UPDATE cash_flow_scopes SET parent = 'youth' WHERE parent = 'boys';

-- plans
INSERT INTO team_fee_plans (entry_id, league_fee_id, season_id, quantity, is_assumed, note) VALUES
  (4, 11, 12, 1, false, NULL), (4, 14, 12, 1, false, NULL), (4, 15, 12, 10, false, '10 fall games'),
  (5, 12, 12, 1, false, NULL), (5, 14, 12, 1, false, NULL), (5, 16, 12, 10, false, '10 fall games'),
  (6, 13, 12, 1, false, NULL), (6, 14, 12, 1, false, NULL), (6, 17, 12, 10, false, '10 fall games — $30 (owner 2026-11-13)'),
  (7, 19, 14, 1, false, NULL), (7, 20, 14, 9, true, '9 indoor games'),
  (8, 19, 14, 1, false, NULL), (8, 20, 14, 10, true, '10 indoor games'),
  (9, 24, 42, 1, false, NULL), (9, 25, 42, 1, false, NULL), (9, 26, 42, 6, true, '6 spring games'),
  (10, 24, 42, 1, false, NULL), (10, 25, 42, 1, false, NULL), (10, 27, 42, 6, true, '6 spring games')
ON CONFLICT (entry_id, league_fee_id) DO NOTHING;
INSERT INTO team_fee_plans (entry_id, league_fee_id, season_id, quantity, is_assumed, note)
SELECT e, (SELECT id FROM league_fees WHERE season_id = 14 AND fee_kind = 'team_entry' AND amount_usd = 100.00), 14, 1, false, 'PPR teams'' price (played PPR fall)'
  FROM unnest(ARRAY[7, 8]) e
ON CONFLICT (entry_id, league_fee_id) DO NOTHING;

-- fall counted paid; indoor + spring owed when their seasons start
INSERT INTO team_season_installments (entry_id, due_on, amount, note)
SELECT p.entry_id, '2026-09-01', sum(round(f.amount_usd * p.quantity, 2)), 'PPR fall — the invoice plan paid $1,200 of the $1,540 rate card; rate card used (owner 2026-11-13)'
  FROM team_fee_plans p JOIN league_fees f ON f.id = p.league_fee_id JOIN fee_kinds k ON k.code = f.fee_kind
 WHERE p.entry_id IN (4, 5, 6) AND k.category IN ('league_dues', 'registrations')
 GROUP BY p.entry_id;
UPDATE team_season_entries SET budget_from_plan = true WHERE id BETWEEN 4 AND 10;

-- game coaching = real games
UPDATE ref_fee_policies SET budget_scope = 'youth' WHERE id IN (10, 11, 12) AND kind = 'coaching';
DELETE FROM ref_fee_seasons WHERE policy_id IN (10, 11, 12);
INSERT INTO ref_fee_seasons (policy_id, label, starts_on, ends_on, home_games_expected, is_assumed) VALUES
  (10, 'PPR Fall 2026',   '2026-09-01', '2026-11-30', 10, false),
  (11, 'PPR Fall 2026',   '2026-09-01', '2026-11-30', 10, false),
  (11, 'PPR Indoor',      '2027-01-03', '2027-03-28',  9, true),
  (11, 'ICSL Spring',     '2027-04-04', '2027-05-23',  6, true),
  (12, 'PPR Fall 2026',   '2026-09-01', '2026-11-30', 10, false),
  (12, 'PPR Indoor',      '2027-01-03', '2027-03-28', 10, true),
  (12, 'ICSL Spring',     '2027-04-04', '2027-05-23',  6, true);
UPDATE ref_fee_policies SET note = 'Hours per game × $15; games = U8 fall only (owner 2026-11-13)' WHERE id = 10;
UPDATE ref_fee_policies SET note = 'Hours per game × $15; games = fall + indoor + spring (owner 2026-11-13)' WHERE id IN (11, 12);

-- practices (Boys general)
INSERT INTO budget_lines (club_id, club_section_id, category, label, amount_usd, amount_per, period_start, period_end,
                          spread, is_assumed, is_active, sort_order, note, budget_year_id, weeks_off) VALUES
  (134, 3, 'labor', 'Coaching — practices, Luke (U8 + U10)',    135.00, 'week', '2026-08-01', '2027-07-31', 'even', false, true, 5,
   '3 practices a week per team × 1½ h × 2 teams = 9 h × $15 — all year, 2 weeks of holiday breaks (owner 2026-11-13)', 1, 2),
  (134, 3, 'labor', 'Coaching — practices, Anthony (U8 + U12)', 135.00, 'week', '2026-08-01', '2027-07-31', 'even', false, true, 6,
   '3 practices a week per team × 1½ h × 2 teams = 9 h × $15 — all year, 2 weeks of holiday breaks (owner 2026-11-13)', 1, 2),
  (134, 3, 'labor', 'Coaching — December 4th practice',          90.00, 'week', '2026-12-01', '2026-12-31', 'even', false, true, 7,
   'Winter: 4 practices a week until indoor games start in January — +1½ h × 2 teams × $15 for each coach (owner 2026-11-13)', 1, 0);
UPDATE budget_lines SET is_assumed = false, note = '$35 per active member (owner 2026-11-13)' WHERE id IN (15, 16);

-- old youth data
UPDATE invoice_installment_plans SET budget_line_id = NULL WHERE budget_line_id IN (4, 8, 9, 11, 12);
UPDATE invoice_lines SET budget_line_id = NULL WHERE budget_line_id IN (4, 8, 9, 11, 12);
DELETE FROM budget_line_fees WHERE budget_line_id IN (4, 8, 9, 11, 12);
DELETE FROM budget_lines WHERE id IN (4, 8, 9, 11, 12);
DELETE FROM cash_flow_planned WHERE scope IN ('ppr', 'u8', 'u10', 'u12', 'boys', 'girls');

INSERT INTO schema_migrations (filename) VALUES ('1341-youth-budget-from-plan.sql') ON CONFLICT DO NOTHING;
COMMIT;
