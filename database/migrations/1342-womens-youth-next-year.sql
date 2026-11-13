-- 1342 (2026-11-13): Women's + Youth 2027-28 — the next-year pill for every section.
--
-- Owner: "yes" (roll Women's and Youth forward like Men's, mig 1334).
-- This year's plans at this year's prices, every fee assumed:
--   Tri County 2027/2028, PPR Fall 2027, PPR Indoor 2027–28, ICSL Spring 2028.
-- Game coaching moves onto each team's plan (fee kind game_coaching): the
-- coaching policy's games in the matching season window × its pay per game.
-- Practices (Luke, Anthony, December 4th) + kits (Women, Boys, Girls) copied.

BEGIN;

DO $$
DECLARE rec record; v_id int;
BEGIN
  CREATE TEMP TABLE season_map (old_id int, new_id int) ON COMMIT DROP;
  FOR rec IN SELECT * FROM (VALUES (13, 7, '2027/2028', DATE '2027-09-01', DATE '2028-06-30'),
                                   (12, 8, 'Fall 2027', DATE '2027-09-01', DATE '2027-11-30'),
                                   (14, 8, 'Indoor 2027–28', DATE '2028-01-02', DATE '2028-03-26'),
                                   (42, 20, 'Spring 2028', DATE '2028-04-02', DATE '2028-05-21')) AS v(old_id, league_id, name, s, e) LOOP
    INSERT INTO seasons (league_id, name, start_date, end_date, is_active) VALUES (rec.league_id, rec.name, rec.s, rec.e, true) RETURNING id INTO v_id;
    INSERT INTO season_map VALUES (rec.old_id, v_id);
  END LOOP;

  CREATE TEMP TABLE div_map (old_id int, new_id int) ON COMMIT DROP;
  FOR rec IN SELECT d.* FROM league_divisions d WHERE d.season_id IN (SELECT old_id FROM season_map) ORDER BY d.parent_id NULLS FIRST, d.id LOOP
    INSERT INTO league_divisions (season_id, parent_id, name, sort_order)
    VALUES ((SELECT new_id FROM season_map WHERE old_id = rec.season_id), (SELECT dm.new_id FROM div_map dm WHERE dm.old_id = rec.parent_id), rec.name, rec.sort_order)
    RETURNING id INTO v_id;
    INSERT INTO div_map VALUES (rec.id, v_id);
  END LOOP;

  CREATE TEMP TABLE fee_map (old_id int, new_id int) ON COMMIT DROP;
  FOR rec IN SELECT f.* FROM league_fees f WHERE f.season_id IN (SELECT old_id FROM season_map) LOOP
    INSERT INTO league_fees (season_id, fee_kind, unit, amount_usd, age_band, tier, is_assumed, source_url, source_quote, checked_on, note, division_id, players_included)
    VALUES ((SELECT new_id FROM season_map WHERE old_id = rec.season_id), rec.fee_kind, rec.unit, rec.amount_usd, rec.age_band, rec.tier, true,
            rec.source_url, rec.source_quote, '2026-11-13', 'Assumed at the 2026/27 price', (SELECT dm.new_id FROM div_map dm WHERE dm.old_id = rec.division_id), rec.players_included)
    RETURNING id INTO v_id;
    INSERT INTO fee_map VALUES (rec.id, v_id);
  END LOOP;

  FOR rec IN SELECT e.*, s.start_date, s.end_date FROM team_season_entries e JOIN seasons s ON s.id = e.season_id
              WHERE e.season_id IN (SELECT old_id FROM season_map) AND e.budget_from_plan LOOP
    INSERT INTO team_season_entries (team_id, season_id, status, note, division_id, budget_from_plan, budget_scope, is_option)
    VALUES (rec.team_id, (SELECT new_id FROM season_map WHERE old_id = rec.season_id), 'planned', 'Rolled forward from 2026/27 (owner 2026-11-13)',
            (SELECT dm.new_id FROM div_map dm WHERE dm.old_id = rec.division_id), true, rec.budget_scope, false)
    RETURNING id INTO v_id;
    INSERT INTO team_fee_plans (entry_id, league_fee_id, season_id, quantity, is_assumed, note)
    SELECT v_id, fm.new_id, (SELECT new_id FROM season_map WHERE old_id = rec.season_id), p.quantity, true, p.note
      FROM team_fee_plans p JOIN fee_map fm ON fm.old_id = p.league_fee_id WHERE p.entry_id = rec.id;
    -- game coaching: the team's coaching policy, games in this season's window
    WITH pol AS (SELECT * FROM ref_fee_policies WHERE kind = 'coaching' AND is_active AND team_id = rec.team_id ORDER BY id LIMIT 1),
         g AS (SELECT sum(rs.home_games_expected) AS n FROM ref_fee_seasons rs, pol
                WHERE rs.policy_id = pol.id AND rs.starts_on BETWEEN rec.start_date AND COALESCE(rec.end_date, rec.start_date + 365)),
         nf AS (
      INSERT INTO league_fees (season_id, fee_kind, unit, amount_usd, is_assumed, checked_on, note, division_id)
      SELECT (SELECT new_id FROM season_map WHERE old_id = rec.season_id), 'game_coaching', 'per_game', pol.per_game_usd, true, '2026-11-13',
             'Coach paid ' || pol.hours_per_game || ' h × $' || pol.rate_per_hour::int || ' a game', (SELECT dm.new_id FROM div_map dm WHERE dm.old_id = rec.division_id)
        FROM pol, g WHERE g.n > 0 RETURNING id, season_id)
    INSERT INTO team_fee_plans (entry_id, league_fee_id, season_id, quantity, is_assumed, note)
    SELECT v_id, nf.id, nf.season_id, g.n, true, 'Games like 2026/27' FROM nf, g;
  END LOOP;
END $$;

INSERT INTO budget_lines (club_id, club_section_id, category, label, amount_usd, amount_per, period_start, period_end,
                          spread, is_assumed, is_active, sort_order, note, group_label, budget_year_id, weeks_off)
SELECT club_id, club_section_id, category, label, amount_usd, amount_per, (period_start + interval '1 year')::date, (period_end + interval '1 year')::date,
       spread, true, true, sort_order, note, group_label, 2, weeks_off
  FROM budget_lines WHERE budget_year_id = 1 AND is_active AND club_section_id IN (2, 3, 4);

INSERT INTO schema_migrations (filename) VALUES ('1342-womens-youth-next-year.sql') ON CONFLICT DO NOTHING;
COMMIT;
