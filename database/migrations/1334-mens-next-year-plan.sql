-- 1334 (2026-11-13): Men's 2027-28 plan — the next-year pill.
--
-- Owner: "and for next year budget (us open cup and liga 2). have a pill for
-- next year budget too."
--
-- This year's cut-over Men's entries roll forward at this year's prices
-- (every fee assumed): APSL 2027/2028 (main + Reserves), CASA Select
-- 2027/2028 (Liga 1, U23, Liga 2 — a full year now, not an option).
-- Game coaching moves onto each team's plan (fee kind game_coaching):
-- APSL $60 × 22, Liga 1 $49 × 22, U23 $49 × 6, Liga 2 $49 × 22.
-- Cups 2027-28 already on file (Amateur Cup 12, state open cup 13, U.S. Open
-- Cup 2028 qualifying 14) get refs ($120 × 1 at the two EPSA cups) and game
-- coaching ($60 × 1 each).  Grassroots 2028 not budgeted (owner named it not).
-- Men's general: practices + kits copied into 2027-28.

BEGIN;

DO $$
DECLARE
  s_apsl int; s_casa int;
  rec record; v_id int;
BEGIN
  INSERT INTO seasons (league_id, name, start_date, end_date, is_active) VALUES (1, '2027/2028', '2027-08-01', '2028-05-31', true) RETURNING id INTO s_apsl;
  INSERT INTO seasons (league_id, name, start_date, end_date, is_active) VALUES (2, '2027/2028', '2027-09-12', '2028-06-30', true) RETURNING id INTO s_casa;

  CREATE TEMP TABLE season_map (old_id int, new_id int) ON COMMIT DROP;
  INSERT INTO season_map VALUES (39, s_apsl), (40, s_casa);

  -- divisions (parents first)
  CREATE TEMP TABLE div_map (old_id int, new_id int) ON COMMIT DROP;
  FOR rec IN SELECT d.* FROM league_divisions d WHERE d.season_id IN (39, 40) ORDER BY d.parent_id NULLS FIRST, d.id LOOP
    INSERT INTO league_divisions (season_id, parent_id, name, sort_order)
    VALUES ((SELECT sm.new_id FROM season_map sm WHERE sm.old_id = rec.season_id),
            (SELECT dm.new_id FROM div_map dm WHERE dm.old_id = rec.parent_id), rec.name, rec.sort_order)
    RETURNING id INTO v_id;
    INSERT INTO div_map VALUES (rec.id, v_id);
  END LOOP;

  -- price list
  CREATE TEMP TABLE fee_map (old_id int, new_id int) ON COMMIT DROP;
  FOR rec IN SELECT f.* FROM league_fees f WHERE f.season_id IN (39, 40) LOOP
    INSERT INTO league_fees (season_id, fee_kind, unit, amount_usd, age_band, tier, is_assumed, source_url, source_quote, checked_on, note, valid_until, division_id, players_included)
    VALUES ((SELECT sm.new_id FROM season_map sm WHERE sm.old_id = rec.season_id), rec.fee_kind, rec.unit, rec.amount_usd, rec.age_band, rec.tier, true,
            rec.source_url, rec.source_quote, '2026-11-13', 'Assumed at the 2026/27 price', NULL,
            (SELECT dm.new_id FROM div_map dm WHERE dm.old_id = rec.division_id), rec.players_included)
    RETURNING id INTO v_id;
    INSERT INTO fee_map VALUES (rec.id, v_id);
  END LOOP;

  -- entries + their plans (Men's teams on the plan this year; the Liga 2 option becomes a real entry)
  FOR rec IN SELECT e.* FROM team_season_entries e JOIN teams t ON t.id = e.team_id
              WHERE e.season_id IN (39, 40) AND e.budget_from_plan AND t.club_section_id = 1 LOOP
    INSERT INTO team_season_entries (team_id, season_id, status, note, division_id, budget_from_plan, budget_scope, is_option)
    VALUES (rec.team_id, (SELECT sm.new_id FROM season_map sm WHERE sm.old_id = rec.season_id), 'planned',
            CASE WHEN rec.is_option THEN 'Full year (owner 2026-11-13)' ELSE 'Rolled forward from 2026/27 (owner 2026-11-13)' END,
            (SELECT dm.new_id FROM div_map dm WHERE dm.old_id = rec.division_id), true, rec.budget_scope, false)
    RETURNING id INTO v_id;
    INSERT INTO team_fee_plans (entry_id, league_fee_id, season_id, quantity, is_assumed, note)
    SELECT v_id, fm.new_id, (SELECT sm.new_id FROM season_map sm WHERE sm.old_id = rec.season_id),
           CASE WHEN rec.is_option AND f.fee_kind IN ('referee', 'game_coaching') THEN 22 ELSE p.quantity END,
           true, CASE WHEN rec.is_option AND f.fee_kind IN ('referee', 'game_coaching') THEN '22 games, a full year like Liga 1' ELSE p.note END
      FROM team_fee_plans p JOIN fee_map fm ON fm.old_id = p.league_fee_id JOIN league_fees f ON f.id = p.league_fee_id
     WHERE p.entry_id = rec.id;
    -- game coaching onto the plan for teams whose coaching was a policy this year
    IF NOT EXISTS (SELECT 1 FROM team_fee_plans p JOIN league_fees f ON f.id = p.league_fee_id WHERE p.entry_id = rec.id AND f.fee_kind = 'game_coaching')
       AND rec.team_id IN (SELECT team_id FROM ref_fee_policies WHERE kind = 'coaching' AND is_active) THEN
      WITH pol AS (SELECT * FROM ref_fee_policies WHERE kind = 'coaching' AND is_active AND team_id = rec.team_id LIMIT 1),
           nf AS (
        INSERT INTO league_fees (season_id, fee_kind, unit, amount_usd, is_assumed, checked_on, note, division_id)
        SELECT (SELECT sm.new_id FROM season_map sm WHERE sm.old_id = rec.season_id), 'game_coaching', 'per_game', pol.per_game_usd, true, '2026-11-13',
               'James: ' || pol.hours_per_game || ' h × $20 a game', (SELECT dm.new_id FROM div_map dm WHERE dm.old_id = rec.division_id)
          FROM pol RETURNING id, season_id)
      INSERT INTO team_fee_plans (entry_id, league_fee_id, season_id, quantity, is_assumed, note)
      SELECT v_id, nf.id, nf.season_id, (SELECT sum(home_games_expected) FROM ref_fee_seasons WHERE policy_id = (SELECT id FROM pol)), true,
             'Games like 2026/27 (APSL = home games × 2)'
        FROM nf;
    END IF;
  END LOOP;

  -- cups 2027-28: refs + game coaching
  INSERT INTO league_fees (season_id, fee_kind, unit, amount_usd, is_assumed, checked_on, note) VALUES
    (44, 'referee',       'per_game', 120.00, true, '2026-11-13', 'At the 2026/27 Region I rate, $120 per team per game'),
    (46, 'referee',       'per_game', 120.00, true, '2026-11-13', 'At the assumed 2026/27 rate, $120 per team per game'),
    (44, 'game_coaching', 'per_game',  60.00, true, '2026-11-13', 'James: 3 h × $20 a game'),
    (46, 'game_coaching', 'per_game',  60.00, true, '2026-11-13', 'James: 3 h × $20 a game'),
    (48, 'game_coaching', 'per_game',  60.00, true, '2026-11-13', 'James: 3 h × $20 a game');
  INSERT INTO team_fee_plans (entry_id, league_fee_id, season_id, quantity, is_assumed, note)
  SELECT e.id, f.id, f.season_id, 1, true, '1 game (owner 2026-11-13: next year U.S. Open Cup)'
    FROM league_fees f JOIN team_season_entries e ON e.season_id = f.season_id AND e.team_id = 939
   WHERE f.season_id IN (44, 46, 48) AND f.checked_on = '2026-11-13' AND f.fee_kind IN ('referee', 'game_coaching')
  ON CONFLICT (entry_id, league_fee_id) DO NOTHING;
END $$;

-- Men's general 2027-28
INSERT INTO budget_lines (club_id, club_section_id, category, label, amount_usd, amount_per, period_start, period_end,
                          spread, is_assumed, is_active, sort_order, note, group_label, budget_year_id, weeks_off)
SELECT club_id, club_section_id, category, label, amount_usd, amount_per, (period_start + interval '1 year')::date, (period_end + interval '1 year')::date,
       spread, true, true, sort_order, note, group_label, 2, weeks_off
  FROM budget_lines WHERE id = 13 OR (club_section_id = 1 AND category = 'labor' AND budget_year_id = 1);

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
VALUES ('Finances', 'Finances — Year plan year pill', 'finances', 'plan_year_pill', '{year}', true, 89, true, false);

INSERT INTO schema_migrations (filename) VALUES ('1334-mens-next-year-plan.sql') ON CONFLICT DO NOTHING;
COMMIT;
