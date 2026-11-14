-- 1361 (2026-11-14) — 🧪 Budget playground on #finances.
--
-- Owner: "for men i needed adjustable projections in current and years after
-- or number of teams and players paying. for youth i need to be able to add x
-- amount to u8 to u16 teams and add B teams etc. i need ability to add coaches
-- to these for the hours. so i can see if we can scale" + "i need a button to
-- put all back to default" + "or better yet there should be a playground where
-- i can do this and not touch current live ones and real projected".
--
-- A what-if copy of each budget year, in its own tables.  Nothing here is read
-- by the Year plan, the grid, #cash-flow or At capacity.  fh_budget_playground_reset
-- (the page's ↺ button, and the first open of a year) wipes a year's copy and
-- rebuilds it from the real plan:
--   teams    one row per Who pill (APSL incl. Reserves, Liga 1, Cups, U23, …;
--            youth U8 / U10 / U12) = the plan's lines for the year, per team,
--            without kits and game coaching (those are their own rows here);
--            options (Liga 2, Temple 7s) at 0 teams; youth U14 + U16 at 0 teams
--            costed like U12 (assumed).  players = paying members today:
--            men fill the dues-carrying teams top down (APSL first), youth go to
--            their age band (older than the oldest team → the oldest team).
--   coaches  section practice lines (budget_lines, labor) as $/h × hours × weeks;
--            game coaching per team (coaching policies this year, game_coaching
--            plan lines next year) — a team's coaches grow with its team count.
--   club     club-wide budget lines (balls, seed, paint, gas …) one row each.
--   settings per group: dues a month (Women 0, the club covers them) + kit per player.
-- A year with no plan of its own (2028-29) copies the latest year that has one.
BEGIN;

CREATE TABLE IF NOT EXISTS budget_playground_groups (
    code       text PRIMARY KEY,
    label      text NOT NULL,
    emoji      text,
    sort_order integer NOT NULL
);
INSERT INTO budget_playground_groups (code, label, emoji, sort_order) VALUES
    ('M', 'Men''s', '👨', 1), ('Y', 'Youth', '👦👧', 2), ('W', 'Women''s', '👩', 3), ('C', 'Club-wide', '🏟', 4)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS budget_playground_settings (
    club_id        integer NOT NULL REFERENCES clubs(id),
    budget_year_id integer NOT NULL REFERENCES budget_years(id) ON DELETE CASCADE,
    group_code     text    NOT NULL REFERENCES budget_playground_groups(code),
    dues_monthly   numeric(8,2) NOT NULL DEFAULT 0 CHECK (dues_monthly >= 0),
    kit_per_player numeric(8,2) NOT NULL DEFAULT 0 CHECK (kit_per_player >= 0),
    note           text,
    PRIMARY KEY (club_id, budget_year_id, group_code)
);

CREATE TABLE IF NOT EXISTS budget_playground_teams (
    id             serial PRIMARY KEY,
    club_id        integer NOT NULL REFERENCES clubs(id),
    budget_year_id integer NOT NULL REFERENCES budget_years(id) ON DELETE CASCADE,
    group_code     text    NOT NULL REFERENCES budget_playground_groups(code),
    label          text    NOT NULL,
    us_age         smallint CHECK (us_age BETWEEN 3 AND 19),
    cost_per_team  numeric(10,2) NOT NULL DEFAULT 0,
    team_count     integer NOT NULL DEFAULT 1 CHECK (team_count BETWEEN 0 AND 20),
    players        integer NOT NULL DEFAULT 0 CHECK (players BETWEEN 0 AND 500),
    roster         integer CHECK (roster >= 0),
    is_assumed     boolean NOT NULL DEFAULT false,
    note           text,
    source_scope   text REFERENCES cash_flow_scopes(code) ON DELETE SET NULL,
    sort_order     integer NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS budget_playground_teams_year ON budget_playground_teams (club_id, budget_year_id);
COMMENT ON TABLE budget_playground_teams IS
  '🧪 Budget playground (mig 1361): what-if teams per budget year — cost per team × team_count, players (paying, per team) × dues. Club-wide lines are group C rows. Never read by the real plan.';

CREATE TABLE IF NOT EXISTS budget_playground_coaches (
    id             serial PRIMARY KEY,
    club_id        integer NOT NULL REFERENCES clubs(id),
    budget_year_id integer NOT NULL REFERENCES budget_years(id) ON DELETE CASCADE,
    group_code     text    NOT NULL REFERENCES budget_playground_groups(code),
    team_id        integer REFERENCES budget_playground_teams(id) ON DELETE CASCADE,
    label          text    NOT NULL,
    rate_per_hour  numeric(8,2) NOT NULL DEFAULT 0 CHECK (rate_per_hour >= 0),
    hours          numeric(6,2) NOT NULL DEFAULT 0 CHECK (hours >= 0),
    times          numeric(7,1) NOT NULL DEFAULT 0 CHECK (times >= 0),
    per            text NOT NULL DEFAULT 'week' CHECK (per IN ('week', 'game')),
    note           text,
    sort_order     integer NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS budget_playground_coaches_year ON budget_playground_coaches (club_id, budget_year_id);
COMMENT ON TABLE budget_playground_coaches IS
  '🧪 Budget playground (mig 1361): rate_per_hour × hours × times (weeks or games) a year; on a team it is per team × team_count, else section-wide.';

CREATE OR REPLACE FUNCTION fh_budget_playground_reset(p_club int, p_year int) RETURNS boolean LANGUAGE plpgsql AS $$
DECLARE
    src int; y0 date; y1 date; v_copied boolean; left_ int; r record; tgt int; u12 record;
BEGIN
    DELETE FROM budget_playground_coaches  WHERE club_id = p_club AND budget_year_id = p_year;
    DELETE FROM budget_playground_teams    WHERE club_id = p_club AND budget_year_id = p_year;
    DELETE FROM budget_playground_settings WHERE club_id = p_club AND budget_year_id = p_year;

    -- the year's own plan, else the latest earlier year that has one
    SELECT y.id, y.starts_on, y.ends_on INTO src, y0, y1
      FROM budget_years y
     WHERE y.club_id = p_club AND y.starts_on <= (SELECT starts_on FROM budget_years WHERE id = p_year AND club_id = p_club)
       AND EXISTS (SELECT 1 FROM team_season_entries e JOIN seasons s ON s.id = e.season_id
                    WHERE e.budget_from_plan AND s.start_date BETWEEN y.starts_on AND y.ends_on)
     ORDER BY y.starts_on DESC LIMIT 1;
    IF src IS NULL THEN RETURN false; END IF;
    v_copied := src <> p_year;

    -- settings: dues per section (latest policy, section first) + kits per member line
    INSERT INTO budget_playground_settings (club_id, budget_year_id, group_code, dues_monthly, kit_per_player, note)
    SELECT p_club, p_year, g.code,
           CASE WHEN g.code IN ('W', 'C') THEN 0 ELSE COALESCE((
               SELECT d.monthly_dues_usd FROM dues_policies d JOIN club_sections s ON s.code = CASE g.code WHEN 'Y' THEN 'B' ELSE g.code END
                WHERE d.club_id = p_club AND (d.club_section_id = s.id OR d.club_section_id IS NULL)
                  AND d.effective_from <= (now() AT TIME ZONE 'America/New_York')::date
                ORDER BY (d.club_section_id IS NULL), d.effective_from DESC, d.id DESC LIMIT 1), 0) END,
           CASE WHEN g.code = 'C' THEN 0 ELSE COALESCE((
               SELECT MAX(b.amount_usd) FROM budget_lines b JOIN club_sections s ON s.id = b.club_section_id
                WHERE b.club_id = p_club AND b.is_active AND b.budget_year_id = src AND b.amount_per = 'member'
                  AND s.code = ANY (CASE g.code WHEN 'Y' THEN ARRAY['B', 'G'] ELSE ARRAY[g.code] END)), 0) END,
           CASE WHEN g.code = 'W' THEN 'club covers women''s dues' END
      FROM budget_playground_groups g;

    -- teams: the plan's lines per Who pill, per team (kits + game coaching are their own rows)
    INSERT INTO budget_playground_teams (club_id, budget_year_id, group_code, label, us_age, cost_per_team, team_count, players, roster, is_assumed, note, source_scope, sort_order)
    SELECT p_club, p_year, x.grp, x.label, x.age, x.cost, x.cnt, 0, x.roster, x.assumed OR v_copied,
           CASE WHEN x.opt THEN 'option in the real plan' END, x.scope, x.ord
      FROM (
        SELECT CASE s.code WHEN 'M' THEN 'M' WHEN 'W' THEN 'W' ELSE 'Y' END AS grp,
               COALESCE(e.budget_scope, cash_flow_team_scope(pl.team_id)) AS scope,
               MAX(sc.label) AS label,
               MAX(substring(sc.label FROM 'U(\d+)')::int) FILTER (WHERE s.code IN ('B', 'G')) AS age,
               ROUND(SUM(pl.proposed / COALESCE(NULLIF(pl.team_count, 0), 1)), 2) AS cost,
               CASE WHEN bool_or(e.is_option) THEN 0 ELSE MAX(COALESCE(pl.team_count, 1)) END AS cnt,
               bool_or(e.is_option) AS opt,
               MAX(t.max_roster) FILTER (WHERE t.dues_rank IS NOT NULL) AS roster,
               bool_or(pl.is_assumed) AS assumed,
               -COALESCE(MAX(t.dues_rank), 0) * 10 + MIN(pl.entry_id) AS ord
          FROM team_fee_plan_lines pl
          JOIN team_season_entries e ON e.id = pl.entry_id AND e.budget_from_plan
          JOIN seasons ss ON ss.id = e.season_id AND ss.start_date BETWEEN y0 AND y1
          JOIN teams t ON t.id = pl.team_id
          JOIN club_sections s ON s.id = t.club_section_id
          LEFT JOIN cash_flow_scopes sc ON sc.code = COALESCE(e.budget_scope, cash_flow_team_scope(pl.team_id))
         WHERE pl.fee_kind NOT IN ('kit', 'game_coaching')
           AND e.status <> 'withdrawn'
         GROUP BY 1, 2
      ) x;

    -- youth U14 / U16 (none in the plan yet): 0 teams, costed like U12 (assumed)
    SELECT * INTO u12 FROM budget_playground_teams
     WHERE club_id = p_club AND budget_year_id = p_year AND group_code = 'Y' ORDER BY us_age DESC NULLS LAST LIMIT 1;
    IF u12.id IS NOT NULL THEN
        INSERT INTO budget_playground_teams (club_id, budget_year_id, group_code, label, us_age, cost_per_team, team_count, players, roster, is_assumed, note, sort_order)
        SELECT p_club, p_year, 'Y', 'U' || a, a, u12.cost_per_team, 0, 0,
               COALESCE((SELECT capacity FROM youth_age_capacities c WHERE c.club_id = p_club AND c.us_age = a), u12.roster),
               true, 'costed like ' || u12.label, 1000 + a
          FROM unnest(ARRAY[14, 16]) a
         WHERE a > u12.us_age;
    END IF;
    UPDATE budget_playground_teams SET sort_order = 1000 + us_age
     WHERE club_id = p_club AND budget_year_id = p_year AND group_code = 'Y' AND us_age IS NOT NULL;

    -- men: paying members today fill the dues-carrying teams top down (APSL first)
    SELECT COUNT(*) INTO left_ FROM (
        SELECT DISTINCT m.person_id FROM person_la_memberships m JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
         WHERE m.ended_at IS NULL AND lp.variant = 'active' AND lp.category = 'men'
           AND m.la_payment_status <> 'NA_FREE' AND fh_dues_free_reason(m.person_id) IS NULL) p;
    FOR r IN SELECT id, roster, team_count FROM budget_playground_teams
              WHERE club_id = p_club AND budget_year_id = p_year AND group_code = 'M' AND roster IS NOT NULL AND team_count > 0
              ORDER BY sort_order LOOP
        UPDATE budget_playground_teams SET players = LEAST(left_, r.roster) WHERE id = r.id;
        left_ := GREATEST(0, left_ - r.roster);
    END LOOP;
    -- women: active members (no dues — head count for kits)
    UPDATE budget_playground_teams t SET players = (
        SELECT COUNT(DISTINCT m.person_id) FROM person_la_memberships m JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
         WHERE m.ended_at IS NULL AND lp.variant = 'active' AND lp.category = 'women')
     WHERE t.club_id = p_club AND t.budget_year_id = p_year AND t.group_code = 'W' AND t.roster IS NOT NULL;
    -- youth: paying members by US Club Soccer age → the smallest team band that fits, else the oldest team
    FOR r IN SELECT fh_youth_us_age(pe.birth_date) AS age, COUNT(*) AS n
               FROM (SELECT DISTINCT m.person_id FROM person_la_memberships m JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
                      WHERE m.ended_at IS NULL AND lp.variant = 'active' AND lp.category IN ('boys', 'girls')
                        AND m.la_payment_status <> 'NA_FREE' AND fh_dues_free_reason(m.person_id) IS NULL) p
               JOIN persons pe ON pe.id = p.person_id
              GROUP BY 1 LOOP
        SELECT id INTO tgt FROM budget_playground_teams
         WHERE club_id = p_club AND budget_year_id = p_year AND group_code = 'Y' AND team_count > 0 AND us_age IS NOT NULL
         ORDER BY (us_age >= COALESCE(r.age, 0)) DESC, CASE WHEN us_age >= COALESCE(r.age, 0) THEN us_age ELSE -us_age END
         LIMIT 1;
        IF tgt IS NOT NULL THEN UPDATE budget_playground_teams SET players = players + r.n WHERE id = tgt; END IF;
    END LOOP;

    -- club-wide lines, one row each (rate × the whole period)
    INSERT INTO budget_playground_teams (club_id, budget_year_id, group_code, label, cost_per_team, team_count, players, is_assumed, note, source_scope, sort_order)
    SELECT p_club, p_year, 'C', b.label,
           ROUND(b.amount_usd * CASE WHEN b.amount_per = 'week' THEN GREATEST(0, ROUND((b.period_end - b.period_start + 1) / 7.0)::int - b.weeks_off) ELSE 1 END, 2),
           1, 0, b.is_assumed OR v_copied, b.note, 'club', b.sort_order * 1000 + b.id
      FROM budget_lines b
     WHERE b.club_id = p_club AND b.is_active AND b.budget_year_id = src AND b.club_section_id IS NULL
       AND b.category <> 'labor' AND cash_flow_budget_line_scope(b.id) = 'club';

    -- coaches: section practice lines ($ a week ÷ the section's coaching rate = hours)
    INSERT INTO budget_playground_coaches (club_id, budget_year_id, group_code, label, rate_per_hour, hours, times, per, note, sort_order)
    SELECT p_club, p_year, CASE s.code WHEN 'M' THEN 'M' WHEN 'W' THEN 'W' ELSE 'Y' END, b.label, rt.rate,
           ROUND(b.amount_usd / NULLIF(rt.rate, 0), 2),
           GREATEST(0, ROUND((b.period_end - b.period_start + 1) / 7.0)::int - b.weeks_off), 'week', b.note, b.id
      FROM budget_lines b JOIN club_sections s ON s.id = b.club_section_id
      CROSS JOIN LATERAL (SELECT COALESCE((SELECT MAX(p.rate_per_hour) FROM ref_fee_policies p
                                            WHERE p.kind = 'coaching' AND p.is_active AND p.club_section_id = s.id),
                                           CASE s.code WHEN 'M' THEN 20 ELSE 15 END) AS rate) rt
     WHERE b.club_id = p_club AND b.is_active AND b.budget_year_id = src AND b.category = 'labor' AND b.amount_per = 'week';

    -- game coaching per team: this year's coaching policies × their games in the year…
    INSERT INTO budget_playground_coaches (club_id, budget_year_id, group_code, team_id, label, rate_per_hour, hours, times, per, note, sort_order)
    SELECT p_club, p_year, t.group_code, t.id, 'Game coaching — ' || p.label, p.rate_per_hour, p.hours_per_game, g.games, 'game', p.note, p.id
      FROM ref_fee_policies p
      JOIN budget_playground_teams t ON t.club_id = p_club AND t.budget_year_id = p_year AND t.source_scope = cash_flow_team_scope(p.team_id)
      CROSS JOIN LATERAL (SELECT SUM(fs.home_games_expected) AS games FROM ref_fee_seasons fs
                           WHERE fs.policy_id = p.id AND fs.starts_on <= y1 AND fs.ends_on >= y0) g
     WHERE p.club_id = p_club AND p.kind = 'coaching' AND p.is_active AND g.games > 0;
    -- …and game_coaching plan lines (next year's plans carry them) where no policy row landed
    INSERT INTO budget_playground_coaches (club_id, budget_year_id, group_code, team_id, label, rate_per_hour, hours, times, per, note, sort_order)
    -- one row per team: its seasons / cups added up
    SELECT p_club, p_year, t.group_code, t.id, 'Game coaching — ' || t.label,
           ROUND(pl.rate / h.hours, 2), h.hours, SUM(pl.quantity), 'game', NULL, MIN(pl.plan_id)
      FROM team_fee_plan_lines pl
      JOIN team_season_entries e ON e.id = pl.entry_id AND e.budget_from_plan
      JOIN seasons ss ON ss.id = e.season_id AND ss.start_date BETWEEN y0 AND y1
      JOIN budget_playground_teams t ON t.club_id = p_club AND t.budget_year_id = p_year
                                    AND t.source_scope = COALESCE(e.budget_scope, cash_flow_team_scope(pl.team_id))
      CROSS JOIN LATERAL (SELECT COALESCE((SELECT p.hours_per_game FROM ref_fee_policies p WHERE p.team_id = pl.team_id AND p.kind = 'coaching' AND p.is_active LIMIT 1),
                                          ROUND(pl.rate / 20.0, 2)) AS hours) h
     WHERE pl.fee_kind = 'game_coaching' AND h.hours > 0
       AND NOT EXISTS (SELECT 1 FROM budget_playground_coaches c WHERE c.team_id = t.id AND c.per = 'game')
     GROUP BY t.group_code, t.id, t.label, ROUND(pl.rate / h.hours, 2), h.hours;
    RETURN true;
END $$;

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — pill: Playground', 'pill_playground', '🧪 Playground', 130),
    ('Finances — Playground title', 'pg_title', '🧪 Playground — can we scale?', 131),
    ('Finances — Playground note', 'pg_note', 'A copy of the real plan to try things on. Nothing here changes the Year plan, the grid or Money in & out. Players = paying players per team; every player pays the dues shown. A coach on a team counts once per team.', 132),
    ('Finances — Playground reset button', 'pg_reset', '↺ Back to the real plan', 133),
    ('Finances — Playground reset confirm', 'pg_reset_confirm', 'Tap again — this wipes your changes for {year}', 134),
    ('Finances — Playground copied-year note ({from})', 'pg_copied', 'This year has no plan of its own yet — copied from {from} at the same prices (assumed).', 135),
    ('Finances — Playground summary columns', 'pg_summary_columns', 'Section|Teams|Players|Income / yr|Cost / yr|Net / yr|Net / mo', 136),
    ('Finances — Playground team columns', 'pg_team_columns', 'Team|Teams|Players per team|Roster|Cost per team|Coaching|Kits|Cost / yr|Income / yr', 137),
    ('Finances — Playground coach columns', 'pg_coach_columns', 'Coach|$ / hour|Hours|Times a year|Cost / yr', 138),
    ('Finances — Playground club columns', 'pg_club_columns', 'Line|Cost / yr', 139),
    ('Finances — Playground dues box', 'pg_dues', 'Dues / month', 140),
    ('Finances — Playground kit box', 'pg_kit', 'Kit per player', 141),
    ('Finances — Playground add team', 'pg_add_team', '＋ Team', 142),
    ('Finances — Playground copy team (B team)', 'pg_copy_team', '⧉ B team', 143),
    ('Finances — Playground add coach', 'pg_add_coach', '＋ Coach', 144),
    ('Finances — Playground add line', 'pg_add_line', '＋ Line', 145),
    ('Finances — Playground section coaches', 'pg_section_coaches', 'Coaches for the whole section', 146),
    ('Finances — Playground per week', 'pg_per_week', 'weeks', 147),
    ('Finances — Playground per game', 'pg_per_game', 'games', 148),
    ('Finances — Playground whole club', 'pg_total', 'Whole club', 149),
    ('Finances — Playground break-even ({dues}, {players})', 'pg_break_even', 'Break-even dues: {dues} a month for each of {players} paying players', 150),
    ('Finances — Playground over roster', 'pg_over_roster', 'more players than the roster — add a team', 151),
    ('Finances — Playground new team label', 'pg_new_team', 'New team', 152),
    ('Finances — Playground new coach label', 'pg_new_coach', 'New coach', 153),
    ('Finances — Playground new line label', 'pg_new_line', 'New line', 154),
    ('Finances — Playground B team suffix', 'pg_b_suffix', ' B', 155)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);

COMMIT;
