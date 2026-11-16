-- 1390 (2026-11-16) — #finances 🧩 Programs: a budget per program, per
-- season, rolled up to Youth and the club.
--
-- Owner 2026-11-16: "i want all reports with finer control. with each team a
-- separate item with its own budget then we can roll them up or total them.
-- i need to see if a team itself is sustainable" → "we need to take in the
-- whole year of an age bracket just like the mens program. so all costs for
-- that 'team'. with all money coming in for that team. so youth from u8 up
-- would have ppr league in fall, winter and spring. men you know have us
-- open cup, u23 etc" → "lets do singe age but leave open ability to do 2 or
-- 3 year bands" → "assume 1 potential coach for every practice session and
-- game for eacch team" → shared costs "By players" → "for current budget do
-- what it currently is. i am talking about next year we need flexibilty" →
-- "it would be great to have flexibilty in winter and spring and summer this
-- year since we know fall but are not totally sure on winter spring and
-- summer".
--
-- So: a PROGRAM = a year-round group of players (Men's, Women's, one youth
-- age — or a band: age_from..age_to). A budget year has SEASONS; a season is
-- REAL (budget_season_actuals: this year's fall — LeagueApps money, invoices,
-- the calendar) or PLAN (program_season_plans + program_season_entries,
-- editable). The model is ProgramBudget (C++); docs/finance-programs.md.

-- Seasons of the budget year (Aug 1 – Jul 31). Months wrap (winter 12 → 2).
CREATE TABLE IF NOT EXISTS budget_seasons (
    id          serial PRIMARY KEY,
    club_id     integer NOT NULL,
    code        text    NOT NULL,
    label       text    NOT NULL,
    from_month  integer NOT NULL CHECK (from_month BETWEEN 1 AND 12),
    to_month    integer NOT NULL CHECK (to_month BETWEEN 1 AND 12),
    sort_order  integer NOT NULL,
    UNIQUE (club_id, code)
);
INSERT INTO budget_seasons (club_id, code, label, from_month, to_month, sort_order) VALUES
    (134, 'fall',   'Fall',   8, 11, 10),
    (134, 'winter', 'Winter', 12, 2, 20),
    (134, 'spring', 'Spring', 3,  5, 30),
    (134, 'summer', 'Summer', 6,  7, 40)
ON CONFLICT (club_id, code) DO NOTHING;

-- Seasons whose money is real (read from the books, not the plan).
CREATE TABLE IF NOT EXISTS budget_season_actuals (
    budget_year_id integer NOT NULL REFERENCES budget_years(id),
    season_id      integer NOT NULL REFERENCES budget_seasons(id),
    note           text,
    PRIMARY KEY (budget_year_id, season_id)
);
INSERT INTO budget_season_actuals (budget_year_id, season_id, note)
SELECT y.id, s.id, 'Owner 11/16: "we know fall"'
  FROM budget_years y JOIN budget_seasons s ON s.club_id = y.club_id AND s.code = 'fall'
 WHERE y.club_id = 134 AND y.label = '2026-27'
ON CONFLICT DO NOTHING;

-- Programs. Youth: US Club Soccer age (fh_youth_us_age) within age_from..
-- age_to, boys and girls together. Older than the oldest youth program →
-- boys to Men's, girls to Women's (u17–u19 play on the men's teams).
CREATE TABLE IF NOT EXISTS finance_programs (
    id          serial PRIMARY KEY,
    club_id     integer NOT NULL,
    code        text    NOT NULL,
    label       text    NOT NULL,
    kind        text    NOT NULL CHECK (kind IN ('men', 'women', 'youth')),
    age_from    integer,
    age_to      integer,
    pays_dues   boolean NOT NULL DEFAULT true,
    sort_order  integer NOT NULL,
    is_active   boolean NOT NULL DEFAULT true,
    note        text,
    UNIQUE (club_id, code),
    CHECK (kind <> 'youth' OR (age_from IS NOT NULL AND age_to IS NOT NULL AND age_from <= age_to))
);
INSERT INTO finance_programs (club_id, code, label, kind, age_from, age_to, pays_dues, sort_order, note)
SELECT 134, v.code, v.label, v.kind, v.a, v.a, v.pays, v.ord, v.note
  FROM (VALUES
    ('mens',   'Men''s',   'men',   NULL::int, true,  10, 'APSL, Liga 1/2, U23, cups, 7s, reserves; u17–u19 boys'),
    ('womens', 'Women''s', 'women', NULL,      false, 20, 'No dues — the club covers it (owner 11/15)'),
    ('u5',  'U5',  'youth', 5,  true, 105, NULL), ('u6',  'U6',  'youth', 6,  true, 106, NULL),
    ('u7',  'U7',  'youth', 7,  true, 107, NULL), ('u8',  'U8',  'youth', 8,  true, 108, NULL),
    ('u9',  'U9',  'youth', 9,  true, 109, NULL), ('u10', 'U10', 'youth', 10, true, 110, NULL),
    ('u11', 'U11', 'youth', 11, true, 111, NULL), ('u12', 'U12', 'youth', 12, true, 112, NULL),
    ('u13', 'U13', 'youth', 13, true, 113, NULL), ('u14', 'U14', 'youth', 14, true, 114, NULL),
    ('u15', 'U15', 'youth', 15, true, 115, NULL), ('u16', 'U16', 'youth', 16, true, 116, NULL)
  ) AS v(code, label, kind, a, pays, ord, note)
ON CONFLICT (club_id, code) DO NOTHING;
-- (bands later = one row with age_from < age_to, the single ages switched off)

-- A program's teams: their calendar hours, fee plans and cash-flow money.
-- A team in two programs (fall's U10 = U9 + U10 kids) splits by players.
CREATE TABLE IF NOT EXISTS finance_program_teams (
    program_id integer NOT NULL REFERENCES finance_programs(id) ON DELETE CASCADE,
    team_id    integer NOT NULL REFERENCES teams(id),
    PRIMARY KEY (program_id, team_id)
);
INSERT INTO finance_program_teams (program_id, team_id)
SELECT p.id, v.team_id FROM (VALUES
    ('mens', 35), ('mens', 938), ('mens', 120), ('mens', 958), ('mens', 957), ('mens', 959), ('mens', 939),
    ('womens', 901),
    ('u5', 954), ('u6', 952), ('u7', 949), ('u8', 953), ('u9', 945), ('u10', 942), ('u11', 946), ('u12', 940),
    ('u13', 947), ('u14', 955), ('u15', 941), ('u16', 956),
    -- fall 2026's two-year teams
    ('u7', 912), ('u8', 912), ('u9', 913), ('u10', 913), ('u11', 914), ('u12', 914)
  ) AS v(code, team_id) JOIN finance_programs p ON p.club_id = 134 AND p.code = v.code
ON CONFLICT DO NOTHING;

-- The program a payer belongs to (LA category + birth date).
CREATE OR REPLACE FUNCTION fh_finance_program(p_club integer, p_category text, p_birth date, p_years_ahead integer DEFAULT 0)
RETURNS integer LANGUAGE sql STABLE AS $$
  WITH a AS (SELECT CASE WHEN p_birth IS NULL THEN NULL ELSE fh_youth_us_age(p_birth) + p_years_ahead END AS age),
       y AS (SELECT min(age_from) AS lo, max(age_to) AS hi FROM finance_programs WHERE club_id = p_club AND kind = 'youth' AND is_active)
  SELECT CASE
           WHEN p_category = 'men'   THEN (SELECT id FROM finance_programs WHERE club_id = p_club AND kind = 'men' AND is_active ORDER BY sort_order LIMIT 1)
           WHEN p_category = 'women' THEN (SELECT id FROM finance_programs WHERE club_id = p_club AND kind = 'women' AND is_active ORDER BY sort_order LIMIT 1)
           WHEN p_category IN ('boys', 'girls') THEN
             CASE WHEN (SELECT age FROM a) IS NULL THEN NULL
                  WHEN (SELECT age FROM a) > (SELECT hi FROM y) THEN
                       (SELECT id FROM finance_programs WHERE club_id = p_club AND is_active
                           AND kind = CASE p_category WHEN 'boys' THEN 'men' ELSE 'women' END ORDER BY sort_order LIMIT 1)
                  ELSE (SELECT id FROM finance_programs WHERE club_id = p_club AND kind = 'youth' AND is_active
                           AND GREATEST((SELECT age FROM a), (SELECT lo FROM y)) BETWEEN age_from AND age_to ORDER BY sort_order LIMIT 1)
             END
         END
$$;

-- The plan for one program in one season of one budget year. NULL = the
-- live default (ProgramBudget): players = today's paying players (later
-- years: moved up an age per year), teams = players ÷ capacity rounded up,
-- practice hours a week = the calendar, practice weeks = the season's share
-- of capacity_plan_settings.weeks_per_year, coach rate = the settings rate.
CREATE TABLE IF NOT EXISTS program_season_plans (
    id                  serial PRIMARY KEY,
    program_id          integer NOT NULL REFERENCES finance_programs(id) ON DELETE CASCADE,
    budget_year_id      integer NOT NULL REFERENCES budget_years(id),
    season_id           integer NOT NULL REFERENCES budget_seasons(id),
    players             integer CHECK (players >= 0),
    teams               integer CHECK (teams >= 0),
    practice_hours_week numeric(5,2) CHECK (practice_hours_week >= 0),
    practice_weeks      numeric(5,2) CHECK (practice_weeks >= 0),
    games               integer NOT NULL DEFAULT 0 CHECK (games >= 0),   -- per team
    hours_per_game      numeric(5,2) NOT NULL DEFAULT 0,
    coach_paid          boolean NOT NULL DEFAULT true,
    coach_rate          numeric(8,2) CHECK (coach_rate >= 0),
    note                text,
    updated_at          timestamptz NOT NULL DEFAULT now(),
    updated_by_user_id  integer,
    UNIQUE (program_id, budget_year_id, season_id)
);

-- Competitions a program enters in a plan season, priced from the league
-- rate card (league_fees of that league season; age_band picks the band's
-- rows, NULL rows always apply). Bonds (refundable) and game coaching (the
-- program's own coach) never count. teams NULL = the plan's teams.
CREATE TABLE IF NOT EXISTS program_season_entries (
    id               serial PRIMARY KEY,
    program_id       integer NOT NULL REFERENCES finance_programs(id) ON DELETE CASCADE,
    budget_year_id   integer NOT NULL REFERENCES budget_years(id),
    season_id        integer NOT NULL REFERENCES budget_seasons(id),
    league_season_id integer NOT NULL REFERENCES seasons(id),
    age_band         text,
    teams            integer CHECK (teams >= 0),
    note             text,
    UNIQUE (program_id, budget_year_id, season_id, league_season_id)
);

-- Seed plans: every program × plan season of 2026-27 (winter/spring/summer)
-- and all of 2027-28 / 2028-29. Games per team (owner 11/15 "assume a game
-- for allt eams above u9 … like 20 games"): youth U10+ fall 8 / winter 6 /
-- spring 6; Men's fall 10 / spring 10; Women's 11 / 11. Hours per game from
-- the coaching policies (PPR U10–U11 1.5, U12+ 2, men APSL 3 / Liga 1 2.45 →
-- 2.75, Tri County 2). Summer: no games.
INSERT INTO program_season_plans (program_id, budget_year_id, season_id, games, hours_per_game, note)
SELECT p.id, y.id, s.id,
       CASE WHEN s.code = 'summer' THEN 0
            WHEN p.kind = 'youth' AND p.age_from < 10 THEN 0
            WHEN p.kind = 'youth' THEN CASE s.code WHEN 'fall' THEN 8 ELSE 6 END
            WHEN p.kind = 'men'   THEN CASE s.code WHEN 'winter' THEN 0 ELSE 10 END
            WHEN p.kind = 'women' THEN CASE s.code WHEN 'winter' THEN 0 ELSE 11 END END,
       CASE WHEN p.kind = 'men' THEN 2.75 WHEN p.kind = 'women' THEN 2
            WHEN p.age_from >= 12 THEN 2 WHEN p.age_from >= 10 THEN 1.5 ELSE 0 END,
       'Seeded 11/16 (mig 1390)'
  FROM finance_programs p
  JOIN budget_years y ON y.club_id = p.club_id
  JOIN budget_seasons s ON s.club_id = p.club_id
 WHERE p.club_id = 134
   AND NOT EXISTS (SELECT 1 FROM budget_season_actuals a WHERE a.budget_year_id = y.id AND a.season_id = s.id)
ON CONFLICT (program_id, budget_year_id, season_id) DO NOTHING;

-- Seed competitions for youth: PPR fall (U8 band for U7–U8, U10 for U9–U10,
-- U12 for U11–U12), PPR indoor (winter), ICSL spring (U10 / U12 bands) —
-- the leagues the club's youth teams play now. U5–U6 in-house, U13+ none yet
-- (no rate card). Only league seasons that exist in the rate card.
INSERT INTO program_season_entries (program_id, budget_year_id, season_id, league_season_id, age_band, note)
SELECT p.id, y.id, bs.id, ls.id,
       CASE WHEN p.age_from <= 8 THEN 'U8' WHEN p.age_from <= 10 THEN 'U10' ELSE 'U12' END,
       'Seeded 11/16 (mig 1390)'
  FROM finance_programs p
  JOIN budget_years y ON y.club_id = p.club_id
  JOIN budget_seasons bs ON bs.club_id = p.club_id AND bs.code IN ('fall', 'winter', 'spring')
  JOIN leagues l ON l.name = CASE WHEN bs.code = 'spring' THEN 'Inter-County Soccer League' ELSE 'Philadelphia Parks & Recreation' END
  JOIN seasons ls ON ls.league_id = l.id AND ls.start_date BETWEEN y.starts_on AND y.ends_on
                 AND CASE bs.code WHEN 'fall' THEN ls.name ILIKE 'Fall%' WHEN 'winter' THEN ls.name ILIKE 'Indoor%' ELSE ls.name ILIKE 'Spring%' END
 WHERE p.club_id = 134 AND p.kind = 'youth' AND p.age_from BETWEEN 7 AND 12
   AND NOT (bs.code = 'spring' AND p.age_from < 9)     -- ICSL starts at U10 (U9 plays up)
   AND NOT EXISTS (SELECT 1 FROM budget_season_actuals a WHERE a.budget_year_id = y.id AND a.season_id = bs.id)
ON CONFLICT DO NOTHING;

-- Words
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — pill: programs', 'pill_programs', '🧩 Programs', 320),
    ('Finances — programs: title', 'pg_title', 'Programs', 321),
    ('Finances — programs: note', 'pg_note', 'Each program''s own budget for the year — Men''s, Women''s and each youth age — season by season. A real season (this year''s fall) comes from the books: LeagueApps money, invoices, the calendar. A plan season uses the plan: players × dues, the leagues it enters from their rate cards, and one coach per team for every practice and game. Own net = its own money only — does it pay for itself? Shared costs (club-wide lines) are split by paying players; the grant by each program''s coaching, referees and equipment, CASA rental by players. * = assumed.', 322),
    ('Finances — programs: col program', 'pg_col_program', 'Program', 323),
    ('Finances — programs: col players', 'pg_col_players', 'Players', 324),
    ('Finances — programs: col teams', 'pg_col_teams', 'Teams', 325),
    ('Finances — programs: col dues', 'pg_col_dues', 'Dues', 326),
    ('Finances — programs: col direct', 'pg_col_direct', 'Own costs', 327),
    ('Finances — programs: col own net', 'pg_col_own', 'Own net', 328),
    ('Finances — programs: col shared', 'pg_col_shared', 'Shared costs', 329),
    ('Finances — programs: col support', 'pg_col_support', 'Grant + CASA', 330),
    ('Finances — programs: col net', 'pg_col_net', 'Net with shared', 331),
    ('Finances — programs: youth total', 'pg_youth_total', 'Youth', 332),
    ('Finances — programs: club total', 'pg_club_total', 'Club', 333),
    ('Finances — programs: real season', 'pg_real', 'real', 334),
    ('Finances — programs: plan season', 'pg_plan', 'plan', 335),
    ('Finances — programs: pays for itself', 'pg_ok', '✓ pays for itself', 336),
    ('Finances — programs: short', 'pg_short', '✗ short {amount}', 337),
    ('Finances — programs: tap hint', 'pg_tap', 'Tap a program for its seasons and lines.', 338),
    ('Finances — programs: line dues', 'pg_line_dues', 'Dues', 340),
    ('Finances — programs: line la fees', 'pg_line_la_fees', 'LeagueApps fees', 341),
    ('Finances — programs: line coaching', 'pg_line_coaching', 'Coaching — one coach per team, every practice and game', 342),
    ('Finances — programs: line shared', 'pg_line_shared', 'Shared costs (split by paying players)', 343),
    ('Finances — programs: line grant', 'pg_line_grant', 'Grant (restricted) — its share', 344),
    ('Finances — programs: line casa', 'pg_line_casa', 'CASA field rental — its share', 345),
    ('Finances — programs: own net line', 'pg_line_own', 'Own net', 346),
    ('Finances — programs: net line', 'pg_line_net', 'Net with shared', 347),
    ('Finances — programs: no players', 'pg_none', 'no players expected', 348),
    ('Finances — programs: row practice', 'pg_row_practice', 'Practice h/wk × weeks', 349),
    ('Finances — programs: row games', 'pg_row_games', 'Games × hours', 350),
    ('Finances — programs: row coach', 'pg_row_coach', 'Coach', 351),
    ('Finances — programs: volunteer', 'pg_volunteer', 'volunteer', 352)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);
