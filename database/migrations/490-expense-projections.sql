-- 490 (2026-09-29) — expense projections: referee fees per home game, league
-- dues and kits as budget lines, ticked off as they land on an invoice.
-- Owner: "how can we do projections for expenses too? … going forward we
-- will be putting expenses into my invoice … figure out what projection was
-- invoiced already as we go and take it out of projection" / "lets start with
-- ref fees … they are easy to check off right as they are invoiced right?"
--   apsl only pays when home. $310 per home game. 11 home games (fall/spring =
--   one year, no winter); liga 1 is $130 per game, same year shape;
--   kids $25 per game for u8 and u10, $30 for u12, fall + indoor + spring
--   assumed alike; women pay their own refs ("one of the reasons we don't
--   charge them tuition"); league dues: women $200, APSL $1500, Liga 1
--   $1899, u8/u10/u12 assume $500 for each season; kits $35 per player;
--   "balance on apsl is 2940. this includes player adds and league fee";
--   "for liga 1 league dues are actually 1770.45 we paid so far 769.69";
--   "we are only worried about future expenses from this date forward …
--   project on a monthly/yearly flow" — the grid starts this month, and a
--   played game not yet invoiced rolls into this month.
--
--   ref_fee_policies   what a home game costs, per league (+ youth age band)
--   ref_fee_seasons    how many home games a season should have — the
--                      difference from the games already on the schedules
--                      is spread over the season's remaining months
--   ref_fee_payments   a game ticked as invoiced (one per game)
--   budget_lines       fixed or per-member expenses with a period
--   invoice_lines.budget_line_id / invoice_installment_plans.budget_line_id
--                      what an invoice line counts toward
-- Numbers come from Expenses::projection() (GET /api/finances/expenses).

CREATE TABLE IF NOT EXISTS ref_fee_policies (
    id                   SERIAL PRIMARY KEY,
    club_id              INTEGER NOT NULL,
    label                TEXT NOT NULL,
    club_section_id      INTEGER REFERENCES club_sections(id),
    league_id            INTEGER REFERENCES leagues(id),
    fixture_league_label TEXT,                          -- league_fixture_sources.league_label when the league publishes a feed
    event_league_labels  TEXT[] NOT NULL DEFAULT '{}',  -- fh_events.league spellings otherwise
    event_category       TEXT,                          -- fh_events.category
    age_band             TEXT,                          -- 'U8' — matched as a word in the calendar title
    per_game_usd         NUMERIC(8,2) NOT NULL,
    home_only            BOOLEAN NOT NULL DEFAULT true,
    effective_from       DATE NOT NULL DEFAULT CURRENT_DATE,
    is_active            BOOLEAN NOT NULL DEFAULT true,
    sort_order           INTEGER NOT NULL DEFAULT 0,
    note                 TEXT
);
COMMENT ON TABLE ref_fee_policies IS 'Referee fee per home game by league / youth age band (mig 490). Games come from league_fixtures when the league has a feed, else from the calendar.';

CREATE TABLE IF NOT EXISTS ref_fee_seasons (
    id                   SERIAL PRIMARY KEY,
    policy_id            INTEGER NOT NULL REFERENCES ref_fee_policies(id) ON DELETE CASCADE,
    label                TEXT NOT NULL,
    starts_on            DATE NOT NULL,
    ends_on              DATE NOT NULL,
    home_games_expected  INTEGER NOT NULL,
    is_assumed           BOOLEAN NOT NULL DEFAULT false,
    note                 TEXT
);

CREATE TABLE IF NOT EXISTS ref_fee_payments (
    id                   SERIAL PRIMARY KEY,
    policy_id            INTEGER NOT NULL REFERENCES ref_fee_policies(id),
    invoice_line_id      INTEGER NOT NULL REFERENCES invoice_lines(id) ON DELETE CASCADE,
    fh_event_id          BIGINT REFERENCES fh_events(id) ON DELETE SET NULL,
    league_fixture_id    INTEGER REFERENCES league_fixtures(id) ON DELETE SET NULL,
    game_on              DATE NOT NULL,
    opponent             TEXT,
    amount_usd           NUMERIC(8,2) NOT NULL,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (fh_event_id),
    UNIQUE (league_fixture_id)
);
COMMENT ON TABLE ref_fee_payments IS 'A home game whose referee fee is on an invoice line (mig 490); the line going away frees the game again.';

CREATE TABLE IF NOT EXISTS budget_lines (
    id               SERIAL PRIMARY KEY,
    club_id          INTEGER NOT NULL,
    club_section_id  INTEGER REFERENCES club_sections(id),
    category         TEXT NOT NULL REFERENCES invoice_line_categories(code),
    label            TEXT NOT NULL,
    amount_usd       NUMERIC(10,2) NOT NULL,
    amount_per       TEXT NOT NULL DEFAULT 'fixed' CHECK (amount_per IN ('fixed', 'member')),  -- member: × the section's current members
    paid_before_usd  NUMERIC(10,2) NOT NULL DEFAULT 0,   -- already paid before this tracking started; only the rest projects
    period_start     DATE NOT NULL,
    period_end       DATE NOT NULL,
    spread           TEXT NOT NULL DEFAULT 'start' CHECK (spread IN ('start', 'even')),         -- when the money goes out
    is_assumed       BOOLEAN NOT NULL DEFAULT false,
    is_active        BOOLEAN NOT NULL DEFAULT true,
    sort_order       INTEGER NOT NULL DEFAULT 0,
    note             TEXT
);
COMMENT ON TABLE budget_lines IS 'Planned expenses (mig 490). Invoice lines that count toward one reduce what is still projected.';

ALTER TABLE invoice_lines             ADD COLUMN IF NOT EXISTS budget_line_id INTEGER REFERENCES budget_lines(id) ON DELETE SET NULL;
ALTER TABLE invoice_installment_plans ADD COLUMN IF NOT EXISTS budget_line_id INTEGER REFERENCES budget_lines(id) ON DELETE SET NULL;

-- APSL publishes the team's fixtures as a TeamPass iCal feed; pulled like the
-- CASA SportsEngine feed (mig 488), system tells LeagueFixtureSync how.
INSERT INTO league_fixture_sources (league_id, league_label, season, system, program_id, label, team_page_base)
SELECT 1, 'APSL', '2026/27', 'teampass_ics', 'ical_165430_F16CD2', 'Lighthouse 1893 SC - American Premier Soccer League - 2026/2027', NULL
 WHERE NOT EXISTS (SELECT 1 FROM league_fixture_sources WHERE league_label = 'APSL' AND season = '2026/27');

-- Referee fee policies.
INSERT INTO ref_fee_policies (club_id, label, club_section_id, league_id, fixture_league_label, event_league_labels, event_category, age_band, per_game_usd, home_only, sort_order, note)
SELECT 134, 'APSL', 1, 1, 'APSL', '{APSL}', 'mens', NULL, 310.00, true, 1, 'Home games only'
 WHERE NOT EXISTS (SELECT 1 FROM ref_fee_policies WHERE club_id = 134 AND label = 'APSL');
INSERT INTO ref_fee_policies (club_id, label, club_section_id, league_id, fixture_league_label, event_league_labels, event_category, age_band, per_game_usd, home_only, sort_order, note)
SELECT 134, 'Liga 1', 1, 2, 'CASA', '{CASA,"Liga 1","LIGA 1"}', 'mens', NULL, 130.00, true, 2, 'Home games only'
 WHERE NOT EXISTS (SELECT 1 FROM ref_fee_policies WHERE club_id = 134 AND label = 'Liga 1');
INSERT INTO ref_fee_policies (club_id, label, club_section_id, league_id, fixture_league_label, event_league_labels, event_category, age_band, per_game_usd, home_only, sort_order, note)
SELECT 134, 'Parks & Rec U8', 3, 8, NULL, '{PPR}', 'boys', 'U8', 25.00, true, 3, NULL
 WHERE NOT EXISTS (SELECT 1 FROM ref_fee_policies WHERE club_id = 134 AND label = 'Parks & Rec U8');
INSERT INTO ref_fee_policies (club_id, label, club_section_id, league_id, fixture_league_label, event_league_labels, event_category, age_band, per_game_usd, home_only, sort_order, note)
SELECT 134, 'Parks & Rec U10', 3, 8, NULL, '{PPR}', 'boys', 'U10', 25.00, true, 4, NULL
 WHERE NOT EXISTS (SELECT 1 FROM ref_fee_policies WHERE club_id = 134 AND label = 'Parks & Rec U10');
INSERT INTO ref_fee_policies (club_id, label, club_section_id, league_id, fixture_league_label, event_league_labels, event_category, age_band, per_game_usd, home_only, sort_order, note)
SELECT 134, 'Parks & Rec U12', 3, 8, NULL, '{PPR}', 'boys', 'U12', 30.00, true, 5, NULL
 WHERE NOT EXISTS (SELECT 1 FROM ref_fee_policies WHERE club_id = 134 AND label = 'Parks & Rec U12');
INSERT INTO ref_fee_policies (club_id, label, club_section_id, league_id, fixture_league_label, event_league_labels, event_category, age_band, per_game_usd, home_only, sort_order, note)
SELECT 134, 'Tri County (women)', 2, 7, NULL, '{"Tri County",TCWSL}', 'womens', NULL, 0.00, true, 6, 'The women pay their own referees — one reason they are not charged dues'
 WHERE NOT EXISTS (SELECT 1 FROM ref_fee_policies WHERE club_id = 134 AND label = 'Tri County (women)');

-- Seasons: how many home games each should hold.  Fall counts are what the
-- schedules show today; spring / indoor mirror them (assumed) until published.
CREATE OR REPLACE FUNCTION pg_temp.season(p_label text, p_season text, p_from date, p_to date, p_n int, p_assumed boolean)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO ref_fee_seasons (policy_id, label, starts_on, ends_on, home_games_expected, is_assumed)
  SELECT p.id, p_season, p_from, p_to, p_n, p_assumed FROM ref_fee_policies p
   WHERE p.club_id = 134 AND p.label = p_label
     AND NOT EXISTS (SELECT 1 FROM ref_fee_seasons s WHERE s.policy_id = p.id AND s.label = p_season);
$$;
SELECT pg_temp.season('APSL',   'Fall 2026',   '2026-09-01', '2026-12-31', 6, false);   -- owner: 11 home games a year, 1 played; 6 published for fall
SELECT pg_temp.season('APSL',   'Spring 2027', '2027-03-01', '2027-06-30', 5, true);
SELECT pg_temp.season('Liga 1', 'Fall 2026',   '2026-09-01', '2026-12-31', 7, false);   -- 7 home on the CASA schedule
SELECT pg_temp.season('Liga 1', 'Spring 2027', '2027-03-01', '2027-06-30', 7, true);
SELECT pg_temp.season('Parks & Rec U8',  'Fall 2026',      '2026-09-01', '2026-11-30', 3, false);
SELECT pg_temp.season('Parks & Rec U8',  'Indoor 2026/27', '2026-12-01', '2027-02-28', 3, true);
SELECT pg_temp.season('Parks & Rec U8',  'Spring 2027',    '2027-03-01', '2027-06-15', 3, true);
SELECT pg_temp.season('Parks & Rec U10', 'Fall 2026',      '2026-09-01', '2026-11-30', 4, false);
SELECT pg_temp.season('Parks & Rec U10', 'Indoor 2026/27', '2026-12-01', '2027-02-28', 4, true);
SELECT pg_temp.season('Parks & Rec U10', 'Spring 2027',    '2027-03-01', '2027-06-15', 4, true);
SELECT pg_temp.season('Parks & Rec U12', 'Fall 2026',      '2026-09-01', '2026-11-30', 4, false);
SELECT pg_temp.season('Parks & Rec U12', 'Indoor 2026/27', '2026-12-01', '2027-02-28', 4, true);
SELECT pg_temp.season('Parks & Rec U12', 'Spring 2027',    '2027-03-01', '2027-06-15', 4, true);

-- Budget lines: league dues and kits.
CREATE OR REPLACE FUNCTION pg_temp.budget(p_section int, p_cat text, p_label text, p_amount numeric, p_per text, p_from date, p_to date, p_assumed boolean, p_sort int, p_note text, p_paid numeric DEFAULT 0)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO budget_lines (club_id, club_section_id, category, label, amount_usd, amount_per, paid_before_usd, period_start, period_end, spread, is_assumed, sort_order, note)
  SELECT 134, p_section, p_cat, p_label, p_amount, p_per, p_paid, p_from, p_to, 'start', p_assumed, p_sort, p_note
   WHERE NOT EXISTS (SELECT 1 FROM budget_lines WHERE club_id = 134 AND label = p_label AND period_start = p_from);
$$;
SELECT pg_temp.budget(1, 'league_dues', 'APSL league dues + player adds', 2940.00, 'fixed', '2026-09-01', '2027-06-30', false, 10, 'Balance owed to APSL on 2026-09-29: $1,500 league fee plus player adds (owner)');
SELECT pg_temp.budget(1, 'league_dues', 'Liga 1 league dues',      1770.45, 'fixed', '2026-09-01', '2027-06-30', false, 11, 'Fall + spring = one year; $769.69 paid before 2026-09-29 (owner)', 769.69);
SELECT pg_temp.budget(2, 'league_dues', 'Tri County league dues',   200.00, 'fixed', '2026-09-01', '2027-06-30', false, 12, NULL);
SELECT pg_temp.budget(3, 'league_dues', 'U8 league dues — Fall',    500.00, 'fixed', '2026-09-01', '2026-11-30', true,  20, NULL);
SELECT pg_temp.budget(3, 'league_dues', 'U8 league dues — Winter',  500.00, 'fixed', '2026-12-01', '2027-02-28', true,  21, NULL);
SELECT pg_temp.budget(3, 'league_dues', 'U8 league dues — Spring',  500.00, 'fixed', '2027-03-01', '2027-06-15', true,  22, NULL);
SELECT pg_temp.budget(3, 'league_dues', 'U10 league dues — Fall',   500.00, 'fixed', '2026-09-01', '2026-11-30', true,  23, NULL);
SELECT pg_temp.budget(3, 'league_dues', 'U10 league dues — Winter', 500.00, 'fixed', '2026-12-01', '2027-02-28', true,  24, NULL);
SELECT pg_temp.budget(3, 'league_dues', 'U10 league dues — Spring', 500.00, 'fixed', '2027-03-01', '2027-06-15', true,  25, NULL);
SELECT pg_temp.budget(3, 'league_dues', 'U12 league dues — Fall',   500.00, 'fixed', '2026-09-01', '2026-11-30', true,  26, NULL);
SELECT pg_temp.budget(3, 'league_dues', 'U12 league dues — Winter', 500.00, 'fixed', '2026-12-01', '2027-02-28', true,  27, NULL);
SELECT pg_temp.budget(3, 'league_dues', 'U12 league dues — Spring', 500.00, 'fixed', '2027-03-01', '2027-06-15', true,  28, NULL);
SELECT pg_temp.budget(1, 'uniforms', 'Kits — Mens',   35.00, 'member', '2026-09-01', '2027-06-30', true, 30, '$35 per player');
SELECT pg_temp.budget(2, 'uniforms', 'Kits — Womens', 35.00, 'member', '2026-09-01', '2027-06-30', true, 31, '$35 per player');
SELECT pg_temp.budget(3, 'uniforms', 'Kits — Boys',   35.00, 'member', '2026-09-01', '2027-06-30', true, 32, '$35 per player');
SELECT pg_temp.budget(4, 'uniforms', 'Kits — Girls',  35.00, 'member', '2026-09-01', '2027-06-30', true, 33, '$35 per player');

-- Copy: the #finances page (kind 'finances') and the tick-off on #invoices (kind 'invoices').
CREATE OR REPLACE FUNCTION pg_temp.tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'Finances', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;
SELECT pg_temp.tpl('finances', 'title',           'Finances — title',              '📈 Finances', 1);
SELECT pg_temp.tpl('finances', 'subtitle',        'Finances — subtitle',           'Where the club stands and where it is heading. Billing stays on Payments.', 2);
SELECT pg_temp.tpl('finances', 'pill_summary',    'Finances — pill',               'Summary', 3);
SELECT pg_temp.tpl('finances', 'pill_revenue',    'Finances — pill',               'Revenue', 4);
SELECT pg_temp.tpl('finances', 'pill_expenses',   'Finances — pill',               'Expenses', 5);
SELECT pg_temp.tpl('finances', 'expenses_title',  'Finances — expenses heading',   '🧾 Expense projections', 6);
SELECT pg_temp.tpl('finances', 'expenses_note',   'Finances — expenses note',      'Referee fees are home games × the league rate: games already on the league schedules sit in their month, the rest of each season is spread over its remaining months. League dues and kits are planned lines. Anything on an invoice is taken out; ✓ shows what has been invoiced.', 7);
SELECT pg_temp.tpl('finances', 'refs_title',      'Finances — referee games list', 'Home games the club pays referees for', 8);
SELECT pg_temp.tpl('finances', 'refs_note',       'Finances — referee games note', 'Tick games off on an invoice (Invoices › Referee fees). Played and not yet invoiced games are marked.', 9);
SELECT pg_temp.tpl('finances', 'assumed_note',    'Finances — assumed marker',     '* assumed until the league publishes it', 10);
SELECT pg_temp.tpl('finances', 'net_label',       'Finances — net row',            'Net (dues from members current in dues − expenses)', 11);
SELECT pg_temp.tpl('invoices', 'refs_title',      'Invoices — referee fees heading', 'Referee fees', 100);
SELECT pg_temp.tpl('invoices', 'refs_hint',       'Invoices — referee fees hint',    'Tick the home games this invoice pays the referees for and add them as one Referees line. Ticked games leave the projection on Finances.', 101);
SELECT pg_temp.tpl('invoices', 'refs_button',     'Invoices — referee fees button',  '➕ Add referees line — {n} game(s), {amount}', 102);
SELECT pg_temp.tpl('invoices', 'refs_empty',      'Invoices — no games waiting',     'No home games waiting to be invoiced.', 103);
SELECT pg_temp.tpl('invoices', 'budget_label',    'Invoices — counts-toward select', 'Counts toward', 104);
SELECT pg_temp.tpl('invoices', 'budget_none',     'Invoices — counts-toward none',   '— not a planned expense —', 105);

-- Cash-flow grid wording (same pass, owner: "we are only worried about future
-- expenses from this date forward … project on a monthly/yearly flow" /
-- "same with money coming in right?").
SELECT pg_temp.tpl('finances', 'cash_title',   'Finances — cash flow heading', '💸 Cash flow — this month forward', 12);
SELECT pg_temp.tpl('finances', 'cash_note',    'Finances — cash flow note',    'Money in is dues from members current in dues, at today''s count. Money out is every expense still ahead: referee fees per home game, league dues and kits not yet invoiced. A played game not yet invoiced sits in this month. ✓ = already on an invoice.', 13);
SELECT pg_temp.tpl('finances', 'row_in',       'Finances — money in row',      'Money in', 14);
SELECT pg_temp.tpl('finances', 'row_out',      'Finances — money out row',     'Money out', 15);
SELECT pg_temp.tpl('finances', 'row_dues',     'Finances — dues row',          'Dues — {section}', 16);
SELECT pg_temp.tpl('finances', 'row_net',      'Finances — net row',           'Net', 17);
SELECT pg_temp.tpl('finances', 'col_total',    'Finances — total column',      'Total', 18);
SELECT pg_temp.tpl('finances', 'games_played', 'Finances — played, not invoiced', 'played — not invoiced yet', 19);
