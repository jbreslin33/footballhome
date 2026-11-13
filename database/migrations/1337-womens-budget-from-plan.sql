-- 1337 (2026-11-13): Women's on the Budget plan; the club pays their refs now.
--
-- Owner: "yes lets do womens … we will pay refs for women. its 55 per game …
-- we will pay league player reg fee for women. its 35 per player … women
-- have no dues lol. we are eating the cost while we build it."
--   season   Tri County "Fall 2026" (13) runs the whole year — fall + spring
--            (11 + 11 Sunday games, the coaching policy's seasons); end date set
--   plan     $200 league dues (was budget_lines 3; the 11/20 invoice's $94.42
--            toward it stays an actual on Money In & Out) + player
--            registrations $35 × 25 (18 active + room, assumed) + refs $55 × 22,
--            every game (assumed: home and away).  No dues — the club covers it.
--   refs     policy 6 was $0 ("the women pay their own referees") → $55,
--            every game, Sundays 11 fall + 11 spring; it draws the refs line
--            and ticks invoices like Men's
--   coaching Jamie $30 a game (2 h × $15) × 22 — unchanged, under Women's
--   kits     Kits — Womens ($35 × active members) stays Women's general
--   deleted  budget_lines 3

BEGIN;

UPDATE seasons SET end_date = '2027-06-30' WHERE id = 13 AND end_date IS NULL;

WITH f AS (
  INSERT INTO league_fees (season_id, fee_kind, unit, amount_usd, is_assumed, checked_on, note) VALUES
    (13, 'team_entry', 'per_team_season', 200.00, false, '2026-11-13', 'Tri County league dues for the year'),
    (13, 'player_fee', 'per_player',       35.00, false, '2026-11-13', 'The club pays the women''s league registrations, $35 a player (owner 2026-11-13)'),
    (13, 'referee',    'per_game',         55.00, false, '2026-11-13', 'The club pays the women''s refs now, $55 a game (owner 2026-11-13)')
  RETURNING id, fee_kind
)
INSERT INTO team_fee_plans (entry_id, league_fee_id, season_id, quantity, is_assumed, note)
SELECT 3, f.id, 13, CASE f.fee_kind WHEN 'referee' THEN 22 WHEN 'player_fee' THEN 25 ELSE 1 END, f.fee_kind <> 'team_entry',
       CASE f.fee_kind WHEN 'referee' THEN '11 fall + 11 spring Sunday games, every game (assumed home and away)'
                       WHEN 'player_fee' THEN '18 active + room to add (assumed)' ELSE 'Fall + spring' END
  FROM f;

UPDATE ref_fee_policies
   SET per_game_usd = 55.00, home_only = false, bill_home_only = false,
       league_fee_id = (SELECT id FROM league_fees WHERE season_id = 13 AND fee_kind = 'referee'),
       note = 'The club pays the women''s refs, $55 a game, every game (owner 2026-11-13)'
 WHERE id = 6;
INSERT INTO ref_fee_seasons (policy_id, label, starts_on, ends_on, home_games_expected, is_assumed, game_weekday)
SELECT 6, label, starts_on, ends_on, home_games_expected, true, game_weekday FROM ref_fee_seasons WHERE policy_id = 9
ON CONFLICT DO NOTHING;
UPDATE ref_fee_policies SET budget_scope = 'womens' WHERE id = 9 AND kind = 'coaching';

UPDATE team_season_entries SET budget_from_plan = true WHERE id = 3;
UPDATE invoice_lines SET budget_line_id = NULL WHERE budget_line_id = 3;
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM invoice_lines WHERE budget_line_id = 3) OR EXISTS (SELECT 1 FROM invoice_installment_plans WHERE budget_line_id = 3) THEN
    RAISE EXCEPTION 'invoices still count toward budget line 3';
  END IF;
END $$;
DELETE FROM budget_line_fees WHERE budget_line_id = 3;
DELETE FROM budget_lines WHERE id = 3;

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
VALUES ('Finances', 'Finances — Year plan no-dues section', 'finances', 'plan_split_club_covers', 'No dues — the club covers it', true, 94, true, false);

INSERT INTO schema_migrations (filename) VALUES ('1337-womens-budget-from-plan.sql') ON CONFLICT DO NOTHING;
COMMIT;
