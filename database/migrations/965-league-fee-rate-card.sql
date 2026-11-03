-- 965 (2026-11-03) — league fee rate card + team season entries; budget lines
-- and referee projections corrected from the leagues' own published fees, and
-- invoice lines tied to the budget lines they pay (no more double projection).
--
-- Owner 2026-11-03: "do the invoice to budget matching" / "look up ppr dues.
-- look up tri county dues. look up casa dues. look up apsl dues. this should
-- allow you to add to budget and we can pull out the duplicate payments for
-- them. same with refs" / "look up inter county soccer league. u10 and u12.
-- ppr indoor u10 and u12 … CASA Grass roots cup as we will enter that" /
-- "also add in us amateur cup for men. werner fricker cup for men. us open
-- cup qualifiers for men" / "how would you normalize that in db for
-- expenses?" — the agreed shape:
--
--   leagues (exists) → seasons (exists: one edition of a league)
--     league_fees          what the league CHARGES that edition (rate card),
--                          every row carrying its source URL + quoted text
--     team_season_entries  which of OUR teams is in (or plans) that edition
--   invoice_lines (exists) what we actually PAID; budget_lines (exists) what
--   we still expect, now linked to the fees they are made of
--   (budget_line_fees), and ref_fee_policies to the referee fee they use.
--
-- Owner facts the same day: "casa is 130 per game whether home or away";
-- "apsl is 310 per game only home"; "open cup is 500 entry fee with 1500 bond
-- you get back. refs are included in entry fee for whole tournament. so its
-- 500 total for open cup … it only has a registration fee … no ref fee".
--
-- Not published anywhere (left out, owner to supply): Tri County dues and
-- referee amounts (paid in cash on game day), CASA "U12 premier league"
-- (no such CASA division found), EPSA state-round referee fees, Region I
-- Fricker entry fee and bond.
--
-- Step 2 (later, C++): Expenses::projection() derives budget amounts from
-- budget_line_fees × league_fees instead of budget_lines.amount_usd.

BEGIN;

-- ── 1. Shape ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS fee_kinds (
    code       TEXT PRIMARY KEY,
    label      TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0
);
INSERT INTO fee_kinds (code, label, sort_order) VALUES
    ('team_entry',   'Team / club entry fee',            1),
    ('credit',       'Credit against the entry fee',     2),
    ('assignor',     'Referee assignor fee',             3),
    ('software',     'League software fee',              4),
    ('player_fee',   'Player registration fee',          5),
    ('extra_player', 'Player beyond those included',     6),
    ('round_entry',  'Entry fee for a later cup round',  7),
    ('referee',      'Referee fee',                      8),
    ('bond',         'Bond / deposit (refundable)',      9)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS fee_units (
    code  TEXT PRIMARY KEY,
    label TEXT NOT NULL
);
INSERT INTO fee_units (code, label) VALUES
    ('per_team_season', 'per team, per season'),
    ('per_player',      'per player'),
    ('per_game',        'per game, each team pays its own'),
    ('per_home_game',   'per home game, home team pays'),
    ('per_entry',       'once per entry')
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS league_fees (
    id            SERIAL PRIMARY KEY,
    season_id     INTEGER NOT NULL REFERENCES seasons(id) ON DELETE CASCADE,
    fee_kind      TEXT NOT NULL REFERENCES fee_kinds(code),
    unit          TEXT NOT NULL REFERENCES fee_units(code),
    amount_usd    NUMERIC(10,2) NOT NULL,
    division      TEXT,                  -- 'Liga 1', 'Open Mens' …
    age_band      TEXT,                  -- 'U10' — NULL = every age
    tier          TEXT,                  -- 'early_bird' / 'general' / 'late'
    is_refundable BOOLEAN NOT NULL DEFAULT false,
    is_assumed    BOOLEAN NOT NULL DEFAULT false,   -- carried from an older edition / not confirmed
    source_url    TEXT,
    source_quote  TEXT,
    checked_on    DATE NOT NULL DEFAULT CURRENT_DATE,
    note          TEXT
);
COMMENT ON TABLE league_fees IS 'Rate card (mig 965): what a league charges in one season edition, each row with its source URL and the quoted wording. Fix a wrong fee here by migration.';

CREATE TABLE IF NOT EXISTS team_season_entries (
    id         SERIAL PRIMARY KEY,
    team_id    INTEGER NOT NULL REFERENCES teams(id),
    season_id  INTEGER NOT NULL REFERENCES seasons(id) ON DELETE CASCADE,
    division   TEXT,
    status     TEXT NOT NULL DEFAULT 'planned' CHECK (status IN ('planned', 'entered', 'withdrawn')),
    note       TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (team_id, season_id)
);
COMMENT ON TABLE team_season_entries IS 'Which of our teams is in, or plans to enter, a league season (mig 965). A fee only applies to us through an entry.';

CREATE TABLE IF NOT EXISTS budget_line_fees (
    budget_line_id INTEGER NOT NULL REFERENCES budget_lines(id) ON DELETE CASCADE,
    league_fee_id  INTEGER NOT NULL REFERENCES league_fees(id) ON DELETE CASCADE,
    entry_id       INTEGER NOT NULL REFERENCES team_season_entries(id) ON DELETE CASCADE,
    quantity       NUMERIC(8,2) NOT NULL DEFAULT 1,
    PRIMARY KEY (budget_line_id, league_fee_id, entry_id)
);
COMMENT ON TABLE budget_line_fees IS 'The rate-card fees a budget line is made of (mig 965).';

ALTER TABLE ref_fee_policies ADD COLUMN IF NOT EXISTS league_fee_id INTEGER REFERENCES league_fees(id) ON DELETE SET NULL;

-- ── 2. Leagues not yet known ────────────────────────────────────────────────
INSERT INTO organizations (name, short_name, website_url)
SELECT v.n, v.s, v.u FROM (VALUES
    ('Inter-County Soccer League',              'ICSL',      'https://icsl.demosphere-secure.com'),
    ('United States Adult Soccer Association',  'USASA',     'https://usadultsoccer.com'),
    ('U.S. Soccer Federation',                  'U.S. Soccer','https://www.ussoccer.com')
) AS v(n, s, u)
WHERE NOT EXISTS (SELECT 1 FROM organizations o WHERE o.name = v.n);

INSERT INTO leagues (organization_id, name, website_url)
SELECT o.id, v.l, v.u
  FROM (VALUES
    ('Inter-County Soccer League',             'Inter-County Soccer League',          'https://icsl.demosphere-secure.com'),
    ('United States Adult Soccer Association', 'USASA National Amateur Cup',          'https://usadultsoccer.com/national-amateur-cup/'),
    ('United States Adult Soccer Association', 'Werner Fricker Open Cup',             'https://usadultsoccer.com/?p=8178'),
    ('U.S. Soccer Federation',                 'Lamar Hunt U.S. Open Cup qualifying', 'https://www.ussoccer.com'),
    ('CASA Soccer Leagues',                    'Philly Grassroots Cup',               'https://www.casasoccerleagues.com/page/show/9345724-philly-grassroots-cup')
  ) AS v(org, l, u)
  JOIN organizations o ON o.name = v.org
 WHERE NOT EXISTS (SELECT 1 FROM leagues x WHERE x.name = v.l);

-- Calendar tag spellings → the new organizations (ICSL games tag "ICSL").
INSERT INTO gcal_league_aliases (alias, organization_id, notes)
SELECT v.a, o.id, 'mig 965' FROM (VALUES
    ('ICSL', 'Inter-County Soccer League'), ('Inter-County', 'Inter-County Soccer League'),
    ('Inter-County Soccer League', 'Inter-County Soccer League'), ('PPR Indoor', 'Philadelphia Parks & Recreation')
) AS v(a, org) JOIN organizations o ON o.name = v.org
ON CONFLICT (alias) DO NOTHING;

-- ── 3. Seasons (editions) ───────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION pg_temp.lg(p_name text) RETURNS int LANGUAGE sql AS $$
  SELECT id FROM leagues WHERE name = p_name ORDER BY id LIMIT 1 $$;

INSERT INTO seasons (league_id, name, start_date, end_date)
SELECT pg_temp.lg(v.l), v.n, v.s::date, v.e::date FROM (VALUES
    ('American Premier Soccer League',       '2026/2027',   '2026-08-01', '2027-05-31'),
    ('CASA Select',                          '2026/2027',   '2026-09-13', '2027-06-30'),
    ('Inter-County Soccer League',           'Fall 2026',   '2026-09-12', '2026-12-06'),
    ('Inter-County Soccer League',           'Spring 2027', '2027-04-04', '2027-05-23'),
    ('USASA National Amateur Cup',           '2026/2027',   '2026-08-28', '2027-07-31'),
    ('USASA National Amateur Cup',           '2027/2028',   '2027-08-01', '2028-07-31'),
    ('Werner Fricker Open Cup',              '2026/2027',   '2026-08-28', '2027-06-30'),
    ('Werner Fricker Open Cup',              '2027/2028',   '2027-08-01', '2028-06-30'),
    ('Lamar Hunt U.S. Open Cup qualifying',  '2027',        '2026-08-04', '2026-11-22'),
    ('Lamar Hunt U.S. Open Cup qualifying',  '2028',        '2027-08-01', '2027-11-30'),
    ('Philly Grassroots Cup',                '2026',        '2026-06-06', '2026-07-19'),
    ('Philly Grassroots Cup',                '2027',        '2027-06-01', '2027-07-31')
) AS v(l, n, s, e)
ON CONFLICT (league_id, name) DO NOTHING;
UPDATE seasons SET end_date   = '2026-11-30' WHERE league_id = 8 AND name = 'Fall 2026' AND end_date IS NULL;
UPDATE seasons SET start_date = '2027-01-03', end_date = '2027-03-28' WHERE league_id = 8 AND name = 'Indoor 2026–27' AND start_date IS NULL;

CREATE OR REPLACE FUNCTION pg_temp.ss(p_league int, p_name text) RETURNS int LANGUAGE sql AS $$
  SELECT id FROM seasons WHERE league_id = p_league AND name = p_name $$;

-- ── 4. Rate card ────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION pg_temp.fee(p_season int, p_kind text, p_unit text, p_amt numeric, p_div text, p_age text, p_tier text,
                                       p_refund bool, p_assumed bool, p_url text, p_quote text, p_note text) RETURNS int LANGUAGE plpgsql AS $$
DECLARE v int;
BEGIN
  SELECT id INTO v FROM league_fees
   WHERE season_id = p_season AND fee_kind = p_kind AND unit = p_unit
     AND division IS NOT DISTINCT FROM p_div AND age_band IS NOT DISTINCT FROM p_age AND tier IS NOT DISTINCT FROM p_tier;
  IF v IS NULL THEN
    INSERT INTO league_fees (season_id, fee_kind, unit, amount_usd, division, age_band, tier, is_refundable, is_assumed, source_url, source_quote, note)
    VALUES (p_season, p_kind, p_unit, p_amt, p_div, p_age, p_tier, p_refund, p_assumed, p_url, p_quote, p_note) RETURNING id INTO v;
  END IF;
  RETURN v;
END $$;

DO $$
DECLARE
  apsl   int := pg_temp.ss(1, '2026/2027');
  casa   int := pg_temp.ss(2, '2026/2027');
  pprf   int := pg_temp.ss(8, 'Fall 2026');
  ppri   int := pg_temp.ss(8, 'Indoor 2026–27');
  icslf  int := pg_temp.ss(pg_temp.lg('Inter-County Soccer League'), 'Fall 2026');
  icsls  int := pg_temp.ss(pg_temp.lg('Inter-County Soccer League'), 'Spring 2027');
  nac    int := pg_temp.ss(pg_temp.lg('USASA National Amateur Cup'), '2026/2027');
  fri    int := pg_temp.ss(pg_temp.lg('Werner Fricker Open Cup'), '2026/2027');
  oc27   int := pg_temp.ss(pg_temp.lg('Lamar Hunt U.S. Open Cup qualifying'), '2027');
  grc    int := pg_temp.ss(pg_temp.lg('Philly Grassroots Cup'), '2026');
  u_apsl text := 'https://apslsoccer.com/APSL/Constitution_fees';
  u_man  text := 'https://app.teampass.com/MediaContent//2026/08/14/15/u_APSL_Regulations___Club_Manual_2026_2027_1786744951184_1_107089106_252709.pdf';
  u_casa text := 'https://www.casasoccerleagues.com/layout_container/show_layout_tab?layout_container_id=134213546&page_node_id=9496152&tab_element_id=373416';
  u_ppro text := 'https://www.phila.gov/media/20260828162900/Parks-Rec-Outdoor-Soccer-%E2%80%93-Bylaws-2026.pdf';
  u_ppri text := 'https://www.phila.gov/media/20260105113559/Parks-Rec-Indoor-Soccer-Bylaws-2026.docx';
  u_icf  text := 'https://icsl.demosphere-secure.com/fall-youth-soccer-league';
  u_ics  text := 'https://icsl.demosphere-secure.com/spring-youth-soccer-league';
  u_icr  text := 'https://icsl.demosphere-secure.com/referee-fees--amp--information/youth-game-referee-fee-schedule';
  u_epsa text := 'https://easternpasoccerassociation.net/wp-content/uploads/2026/08/EPSA-CUP-COMPETITION-REMITTANCE-FORM-2026-2027.docx';
  u_usa  text := 'https://usadultsoccer.com/wp-content/uploads/2026/02/National_Cup_policies_2026-compressed.pdf';
  u_r1   text := 'https://easternpasoccerassociation.net/wp-content/uploads/2026/01/USASA-Region-I-Cup-Playing-Rules.pdf';
  u_oc   text := 'https://cdn.sanity.io/files/oyf3dba6/production/45f58f0e5b7724b6ba0ee1524cc6772ece04fd33.pdf';
  u_grc  text := 'http://web.archive.org/web/20260627063758/https://www.casasoccerleagues.com/page/show/9345724-philly-grassroots-cup';
BEGIN
  -- APSL — Delaware River Conference (Group B), not Metropolitan ($2,400).
  PERFORM pg_temp.fee(apsl, 'team_entry', 'per_team_season', 1750, 'Delaware River Conference', NULL, NULL, false, false, u_apsl,
    'Club Fee - $1,750 ($250 credit if club has a reserve or 2nd team playing in feeder league)', NULL);
  PERFORM pg_temp.fee(apsl, 'credit', 'per_team_season', -250, 'Delaware River Conference', NULL, NULL, false, false, u_apsl,
    '$250 credit if club has a reserve or 2nd team playing in feeder league', 'Our Liga 1 team is the feeder side');
  PERFORM pg_temp.fee(apsl, 'player_fee', 'per_player', 40, 'Delaware River Conference', NULL, NULL, false, false, u_apsl,
    'Player Fee - $40 per player', NULL);
  PERFORM pg_temp.fee(apsl, 'bond', 'per_entry', 1000, 'Delaware River Conference', NULL, NULL, true, false, u_apsl,
    'Club Bond - $1,000 (one time fee)', 'Manual §7.1.2: forfeited unless the club stays at least three seasons');
  PERFORM pg_temp.fee(apsl, 'referee', 'per_home_game', 310, 'Delaware River Conference', NULL, NULL, false, false, u_man,
    '$130 (center); $90 (each AR); $70 (4th official) — §3.1.4 "The home team is responsible for all referee fees"',
    'Owner 2026-11-03: "apsl is 310 per game only home" (center + 2 ARs)');

  -- CASA Philadelphia Select 2026-27, Liga 1 (team hosting = own field).
  PERFORM pg_temp.fee(casa, 'team_entry', 'per_team_season', 1699, 'Liga 1', NULL, 'early_bird', false, false, u_casa, 'Team Hosting Early Bird: $1,699', 'Early bird closed June 30');
  PERFORM pg_temp.fee(casa, 'team_entry', 'per_team_season', 1799, 'Liga 1', NULL, 'general',    false, false, u_casa, 'General: $1,799', NULL);
  PERFORM pg_temp.fee(casa, 'team_entry', 'per_team_season', 1899, 'Liga 1', NULL, 'late',       false, false, u_casa, 'Late: $1,899', NULL);
  PERFORM pg_temp.fee(casa, 'extra_player', 'per_player', 23, 'Liga 1', NULL, NULL, false, false, u_casa,
    'State affiliation registration included for up to 25 players … $23 per player', 'Roster cap of 35');
  PERFORM pg_temp.fee(casa, 'referee', 'per_game', 130, 'Liga 1', NULL, NULL, false, false, u_casa,
    '$130 match official fee per match … paid each match by BOTH teams, regardless of home vs away.',
    'Owner 2026-11-03: "casa is 130 per game whether home or away"');

  -- PPR outdoor Fall 2026.
  PERFORM pg_temp.fee(pprf, 'team_entry', 'per_team_season', 475, NULL, 'U8',  NULL, false, false, u_ppro, 'U8, U9 and U10 = $475.00 plus $30 Assignor''s Fee', NULL);
  PERFORM pg_temp.fee(pprf, 'team_entry', 'per_team_season', 475, NULL, 'U10', NULL, false, false, u_ppro, 'U8, U9 and U10 = $475.00 plus $30 Assignor''s Fee', NULL);
  PERFORM pg_temp.fee(pprf, 'team_entry', 'per_team_season', 500, NULL, 'U12', NULL, false, false, u_ppro, 'U11 & U12 = $500.00 plus $30 Assignor''s Fee', NULL);
  PERFORM pg_temp.fee(pprf, 'assignor', 'per_team_season', 30, NULL, NULL, NULL, false, false, u_ppro, 'plus $30 Assignor''s Fee (Venmo: Gordon-Dunlop)', NULL);
  PERFORM pg_temp.fee(pprf, 'referee', 'per_game', 25, NULL, 'U8',  NULL, false, false, u_ppro, 'REFEREE FEES U10, U9 and U8 = $50 ($25.00 per team)', NULL);
  PERFORM pg_temp.fee(pprf, 'referee', 'per_game', 25, NULL, 'U10', NULL, false, false, u_ppro, 'REFEREE FEES U10, U9 and U8 = $50 ($25.00 per team)', NULL);
  PERFORM pg_temp.fee(pprf, 'referee', 'per_game', 30, NULL, 'U12', NULL, false, false, u_ppro, 'U11& U12= $60 ($30 per team)',
    'Owner 2026-10-13 (mig 579): U12 refs are $35 — the projection keeps $35');

  -- PPR Indoor 2026-27 (2026 bylaws, the Jan–Mar 2026 edition; carried forward).
  PERFORM pg_temp.fee(ppri, 'team_entry', 'per_team_season', 200, NULL, NULL, NULL, false, true, u_ppri, 'League Fee - $200 per Team ($100 PPR Teams)', '2026 edition; 2027 bylaws not out yet');
  PERFORM pg_temp.fee(ppri, 'assignor', 'per_team_season', 30, NULL, NULL, NULL, false, true, u_ppri, 'Referee Assignor Fees - $30.00 per team', NULL);
  PERFORM pg_temp.fee(ppri, 'referee', 'per_game', 25, NULL, NULL, NULL, false, true, u_ppri, 'Game Referee Fees - $25.00 per team. (All Ages)', NULL);

  -- ICSL.
  PERFORM pg_temp.fee(icslf, 'team_entry', 'per_team_season', 500, '7v7', 'U10', NULL, false, false, u_icf, '7v7 Teams $500', 'Registration was due 6/12/26 — we are not in Fall 2026');
  PERFORM pg_temp.fee(icslf, 'team_entry', 'per_team_season', 550, '9v9', 'U12', NULL, false, false, u_icf, '9v9 Teams $550', NULL);
  PERFORM pg_temp.fee(icslf, 'software', 'per_team_season', 10, NULL, NULL, NULL, false, false, u_icf, 'additional $10 for GotSport Software Fee', NULL);
  PERFORM pg_temp.fee(icsls, 'team_entry', 'per_team_season', 195, NULL, NULL, NULL, false, false, u_ics, '$195 per team', 'PAYMENT & REGISTRATION DUE 2/22/27; 6 Game schedule');
  PERFORM pg_temp.fee(icsls, 'software', 'per_team_season', 10, NULL, NULL, NULL, false, false, u_ics, 'additional $10 for GotSport Software Fee', NULL);
  PERFORM pg_temp.fee(icsls, 'referee', 'per_game', 25, '7v7', 'U10', NULL, false, false, u_icr, 'U-9/10 R $50 … Both teams will split and pay half of the referee fee', 'U12 and below will have one Ref');
  PERFORM pg_temp.fee(icsls, 'referee', 'per_game', 30, '9v9', 'U12', NULL, false, false, u_icr, 'U-11/12 R $60 … Both teams will split and pay half of the referee fee', NULL);

  -- USASA National Amateur Cup 2026-27 (EPSA state rounds → Region I → finals).
  PERFORM pg_temp.fee(nac, 'team_entry', 'per_entry', 200, 'EPSA state rounds', NULL, NULL, false, false, u_epsa, 'USSF AMATEUR MENS — 8/28/2026 — $200.00', 'EPSA subsidizes the field at $75 per team per match');
  PERFORM pg_temp.fee(nac, 'round_entry', 'per_entry', 50, 'USASA qualifying', NULL, NULL, false, false, u_usa, '$50.00 … entering qualifying rounds', '§204');
  PERFORM pg_temp.fee(nac, 'round_entry', 'per_entry', 100, 'Region I', NULL, NULL, false, false, u_usa, '$100.00 … when progressing to the regional rounds', '§204');
  PERFORM pg_temp.fee(nac, 'bond', 'per_entry', 500, 'Region I', NULL, NULL, true, false, u_usa, '$500.00 … within seven days of the team''s entering or advancing to the Regional Rounds', '§601');
  PERFORM pg_temp.fee(nac, 'referee', 'per_game', 120, 'Region I', NULL, NULL, false, true, u_r1, 'Each team is responsible … $120 per team, $240 total', '2024 edition of the Region I rules');

  -- Werner Fricker Open Cup 2026-27 (EPSA Open Mens is the state round).
  PERFORM pg_temp.fee(fri, 'team_entry', 'per_entry', 250, 'EPSA Open Mens', NULL, NULL, false, false, u_epsa, 'EPSA OPEN MENS — 8/28/2026 — $250.00', 'Region I entry fee and bond not published');

  -- Lamar Hunt U.S. Open Cup 2027, Open Division qualifying (fall 2026).
  PERFORM pg_temp.fee(oc27, 'team_entry', 'per_entry', 200, 'Open Division qualifying', NULL, NULL, false, false, u_oc,
    '$2,100 … $200 entry fee, $400 referee fee, $1500 performance bond (refunded if all obligations are met)', NULL);
  PERFORM pg_temp.fee(oc27, 'referee', 'per_entry', 400, 'Open Division qualifying', NULL, NULL, false, false, u_oc,
    '$400 referee fee … U.S. Soccer will assign all match referees … paid directly by U.S. Soccer', 'One payment covers every qualifying round');
  PERFORM pg_temp.fee(oc27, 'bond', 'per_entry', 1500, 'Open Division qualifying', NULL, NULL, true, false, u_oc,
    '$1500 performance bond (refunded if all obligations are met)', '$300 per occurrence charged against it for changes; a forfeit costs the rest');

  -- Philly Grassroots Cup 2026 (the only edition so far).
  PERFORM pg_temp.fee(grc, 'team_entry', 'per_entry', 1250, '11v11 Open', NULL, 'early_bird', false, false, u_grc, '$1250 (early bird)', NULL);
  PERFORM pg_temp.fee(grc, 'team_entry', 'per_entry', 1400, '11v11 Open', NULL, 'general',    false, false, u_grc, '$1400 (general)', NULL);
  PERFORM pg_temp.fee(grc, 'team_entry', 'per_entry', 1500, '11v11 Open', NULL, 'late',       false, false, u_grc, '$1500 (late)', NULL);
  PERFORM pg_temp.fee(grc, 'referee', 'per_game', 130, '11v11 Open', NULL, NULL, false, false, u_grc,
    '$130 match official fee per match paid by the captain (not included in registration fee); not charged for the Semifinal or Final matches',
    'Not projected: "3 games guaranteed" group stage');
END $$;

-- Next editions' entry fees, assumed at this year's price.
INSERT INTO league_fees (season_id, fee_kind, unit, amount_usd, division, tier, is_refundable, is_assumed, source_url, source_quote, note)
SELECT s.id, f.fee_kind, f.unit, f.amount_usd, f.division, f.tier, f.is_refundable, true, f.source_url, f.source_quote, 'Assumed at the ' || p.name || ' price'
  FROM league_fees f
  JOIN seasons p ON p.id = f.season_id
  JOIN seasons s ON s.league_id = p.league_id AND s.name = CASE p.name WHEN '2026/2027' THEN '2027/2028' WHEN '2027' THEN '2028' WHEN '2026' THEN '2027' END
 WHERE p.league_id IN (pg_temp.lg('USASA National Amateur Cup'), pg_temp.lg('Werner Fricker Open Cup'), pg_temp.lg('Lamar Hunt U.S. Open Cup qualifying'), pg_temp.lg('Philly Grassroots Cup'))
   AND (f.fee_kind IN ('team_entry', 'referee', 'bond') OR (f.fee_kind = 'round_entry' AND f.division = 'USASA qualifying'))
   AND f.division NOT IN ('Region I')
   AND NOT EXISTS (SELECT 1 FROM league_fees x WHERE x.season_id = s.id AND x.fee_kind = f.fee_kind AND x.tier IS NOT DISTINCT FROM f.tier
                    AND x.division IS NOT DISTINCT FROM f.division);

-- ── 5. Our entries ──────────────────────────────────────────────────────────
INSERT INTO team_season_entries (team_id, season_id, division, status, note)
SELECT v.t, v.s, v.d, v.st, v.n FROM (VALUES
    (35,  pg_temp.ss(1, '2026/2027'), 'Delaware River Conference — Group B', 'entered', NULL),
    (120, pg_temp.ss(2, '2026/2027'), 'Liga 1', 'entered', NULL),
    (901, pg_temp.ss(7, 'Fall 2026'), NULL, 'entered', 'Dues and referee amounts not published; women pay their own refs on game day'),
    (912, pg_temp.ss(8, 'Fall 2026'), 'U8 Boys Red', 'entered', NULL),
    (913, pg_temp.ss(8, 'Fall 2026'), 'U10 Boys Blue', 'entered', NULL),
    (914, pg_temp.ss(8, 'Fall 2026'), 'U12 Boys', 'entered', NULL),
    (913, pg_temp.ss(8, 'Indoor 2026–27'), 'U10', 'planned', 'Owner 2026-11-03: PPR indoor U10 and U12'),
    (914, pg_temp.ss(8, 'Indoor 2026–27'), 'U12', 'planned', NULL),
    (913, pg_temp.ss(pg_temp.lg('Inter-County Soccer League'), 'Spring 2027'), '7v7', 'planned', 'Owner 2026-11-03: ICSL U10 and U12'),
    (914, pg_temp.ss(pg_temp.lg('Inter-County Soccer League'), 'Spring 2027'), '9v9', 'planned', NULL),
    (939, pg_temp.ss(pg_temp.lg('USASA National Amateur Cup'), '2026/2027'), 'EPSA state rounds', 'entered', 'Played 10/18 at Phoenix SCM; the $200 entry is on no invoice'),
    (939, pg_temp.ss(pg_temp.lg('USASA National Amateur Cup'), '2027/2028'), NULL, 'planned', 'Owner 2026-11-03'),
    (939, pg_temp.ss(pg_temp.lg('Werner Fricker Open Cup'), '2027/2028'), NULL, 'planned', 'Owner 2026-11-03'),
    (939, pg_temp.ss(pg_temp.lg('Lamar Hunt U.S. Open Cup qualifying'), '2028'), 'Open Division qualifying', 'planned', 'Owner 2026-11-03; 2027 entry closed Aug 4, 2026'),
    (939, pg_temp.ss(pg_temp.lg('Philly Grassroots Cup'), '2027'), '11v11 Open', 'planned', 'Owner 2026-11-03: "we will enter that"; 2027 edition not announced')
) AS v(t, s, d, st, n)
WHERE v.s IS NOT NULL
ON CONFLICT (team_id, season_id) DO NOTHING;

-- ── 6. Referee projections ──────────────────────────────────────────────────
-- Liga 1: every game, home or away (CASA + owner).  12 on the fall schedule;
-- the year is "18–22 regular season games", so spring ≈ 10.
UPDATE ref_fee_policies SET home_only = false,
       league_fee_id = (SELECT id FROM league_fees WHERE season_id = pg_temp.ss(2, '2026/2027') AND fee_kind = 'referee'),
       note = 'Every game, home or away — CASA: "paid each match by BOTH teams" (mig 965)'
 WHERE id = 2 AND kind = 'referee';
UPDATE ref_fee_seasons SET home_games_expected = 12 WHERE policy_id = 2 AND label = 'Fall 2026';
UPDATE ref_fee_seasons SET home_games_expected = 10 WHERE policy_id = 2 AND label = 'Spring 2027';

UPDATE ref_fee_policies SET league_fee_id = (SELECT id FROM league_fees WHERE season_id = pg_temp.ss(1, '2026/2027') AND fee_kind = 'referee')
 WHERE id = 1 AND kind = 'referee';

-- PPR outdoor: each team pays its half at every game; 10 games a team; the
-- league is Sept–Nov only, so the indoor and spring windows come off these
-- policies (indoor gets its own below, spring is ICSL).
UPDATE ref_fee_policies p SET home_only = false,
       league_fee_id = (SELECT id FROM league_fees WHERE season_id = pg_temp.ss(8, 'Fall 2026') AND fee_kind = 'referee' AND age_band = p.age_band),
       note = 'Every game, each team pays half — PPR bylaws 2026 (mig 965)'
 WHERE p.id IN (3, 4, 5) AND p.kind = 'referee';
UPDATE ref_fee_seasons SET home_games_expected = 10 WHERE policy_id IN (3, 4, 5) AND label = 'Fall 2026';
DELETE FROM ref_fee_seasons WHERE policy_id IN (3, 4, 5) AND label IN ('Indoor 2026/27', 'Spring 2027');

-- New policies: PPR Indoor U10/U12 and ICSL U10/U12 (Spring 2027).
CREATE OR REPLACE FUNCTION pg_temp.pol(p_label text, p_league int, p_labels text[], p_age text, p_rate numeric, p_fee int, p_sort int, p_note text,
                                       p_season text, p_from date, p_to date, p_games int) RETURNS void LANGUAGE plpgsql AS $$
DECLARE v int;
BEGIN
  SELECT id INTO v FROM ref_fee_policies WHERE club_id = 134 AND label = p_label AND kind = 'referee';
  IF v IS NULL THEN
    INSERT INTO ref_fee_policies (club_id, label, club_section_id, league_id, event_league_labels, event_category, age_band, per_game_usd, home_only, sort_order, note, kind, league_fee_id)
    VALUES (134, p_label, 3, p_league, p_labels, 'boys', p_age, p_rate, false, p_sort, p_note, 'referee', p_fee) RETURNING id INTO v;
    INSERT INTO ref_fee_seasons (policy_id, label, starts_on, ends_on, home_games_expected, is_assumed)
    VALUES (v, p_season, p_from, p_to, p_games, true);
  END IF;
END $$;
SELECT pg_temp.pol('PPR Indoor U10', 8, '{"PPR Indoor"}', 'U10', 25, (SELECT id FROM league_fees WHERE season_id = pg_temp.ss(8, 'Indoor 2026–27') AND fee_kind = 'referee'), 7,
                   'Every game, $25 per team — PPR indoor bylaws 2026 (mig 965). Last season: 8–9 games', 'Indoor 2026/27', '2027-01-03', '2027-03-28', 9);
SELECT pg_temp.pol('PPR Indoor U12', 8, '{"PPR Indoor"}', 'U12', 25, (SELECT id FROM league_fees WHERE season_id = pg_temp.ss(8, 'Indoor 2026–27') AND fee_kind = 'referee'), 8,
                   'Every game, $25 per team — PPR indoor bylaws 2026 (mig 965). Last season: 10 games', 'Indoor 2026/27', '2027-01-03', '2027-03-28', 10);
SELECT pg_temp.pol('ICSL U10', pg_temp.lg('Inter-County Soccer League'), '{ICSL,Inter-County}', 'U10', 25,
                   (SELECT id FROM league_fees WHERE season_id = pg_temp.ss(pg_temp.lg('Inter-County Soccer League'), 'Spring 2027') AND fee_kind = 'referee' AND age_band = 'U10'), 9,
                   'Every game, half the $50 — ICSL 2026-27 fee schedule (mig 965)', 'Spring 2027', '2027-04-04', '2027-05-23', 6);
SELECT pg_temp.pol('ICSL U12', pg_temp.lg('Inter-County Soccer League'), '{ICSL,Inter-County}', 'U12', 30,
                   (SELECT id FROM league_fees WHERE season_id = pg_temp.ss(pg_temp.lg('Inter-County Soccer League'), 'Spring 2027') AND fee_kind = 'referee' AND age_band = 'U12'), 10,
                   'Every game, half the $60 — ICSL 2026-27 fee schedule (mig 965)', 'Spring 2027', '2027-04-04', '2027-05-23', 6);

-- ── 7. Budget lines from the rate card ──────────────────────────────────────
CREATE OR REPLACE FUNCTION pg_temp.link(p_line int, p_fee int, p_team int, p_season int, p_qty numeric) RETURNS void LANGUAGE sql AS $$
  INSERT INTO budget_line_fees (budget_line_id, league_fee_id, entry_id, quantity)
  SELECT p_line, p_fee, (SELECT id FROM team_season_entries WHERE team_id = p_team AND season_id = p_season), p_qty
   WHERE p_fee IS NOT NULL
  ON CONFLICT DO NOTHING $$;

-- APSL $2,940 = $1,750 − $250 + 36 players × $40 (owner's figure, now explained).
UPDATE budget_lines SET note = '$1,750 club fee − $250 reserve credit + 36 players × $40 (APSL Delaware River fees, mig 965)' WHERE id = 1;
SELECT pg_temp.link(1, f.id, 35, f.season_id, CASE f.fee_kind WHEN 'player_fee' THEN 36 ELSE 1 END)
  FROM league_fees f WHERE f.season_id = pg_temp.ss(1, '2026/2027') AND f.fee_kind IN ('team_entry', 'credit', 'player_fee');

-- Liga 1 stays the owner's $1,770.45; the rate card shows CASA's tiers.
SELECT pg_temp.link(2, f.id, 120, f.season_id, 1)
  FROM league_fees f WHERE f.season_id = pg_temp.ss(2, '2026/2027') AND f.fee_kind = 'team_entry' AND f.tier = 'general';

-- PPR Fall: one line for the three teams (one plan pays all three on the
-- invoices) — $475 + $475 + $500 + 3 × $30 assignor.
UPDATE budget_lines SET label = 'PPR Fall 2026 — U8, U10, U12 league fees + assignor', amount_usd = 1540.00, is_assumed = false,
       note = 'PPR outdoor bylaws 2026 (mig 965)' WHERE id = 4;
UPDATE budget_lines SET is_active = false, note = 'Folded into budget line 4 (mig 965)' WHERE id IN (7, 10);
SELECT pg_temp.link(4, f.id, CASE f.age_band WHEN 'U8' THEN 912 WHEN 'U10' THEN 913 ELSE 914 END, f.season_id, 1)
  FROM league_fees f WHERE f.season_id = pg_temp.ss(8, 'Fall 2026') AND f.fee_kind = 'team_entry';
SELECT pg_temp.link(4, f.id, t.t, f.season_id, 1)
  FROM league_fees f, (VALUES (912), (913), (914)) AS t(t) WHERE f.season_id = pg_temp.ss(8, 'Fall 2026') AND f.fee_kind = 'assignor';

-- Winter = PPR Indoor, U10 and U12 only: $200 + $30 each.
UPDATE budget_lines SET is_active = false, note = 'No U8 indoor team (owner 2026-11-03, mig 965)' WHERE id = 5;
UPDATE budget_lines SET label = 'PPR Indoor 2026–27 — U10 league fee + assignor', amount_usd = 230.00, is_assumed = true,
       note = 'PPR indoor bylaws 2026, carried forward (mig 965)' WHERE id = 8;
UPDATE budget_lines SET label = 'PPR Indoor 2026–27 — U12 league fee + assignor', amount_usd = 230.00, is_assumed = true,
       note = 'PPR indoor bylaws 2026, carried forward (mig 965)' WHERE id = 11;
SELECT pg_temp.link(b.id, f.id, b.t, f.season_id, 1)
  FROM (VALUES (8, 913), (11, 914)) AS b(id, t), league_fees f
 WHERE f.season_id = pg_temp.ss(8, 'Indoor 2026–27') AND f.fee_kind IN ('team_entry', 'assignor');

-- Spring = ICSL, U10 and U12: $195 + $10 each, due 2/22/27.
UPDATE budget_lines SET is_active = false, note = 'No U8 spring league (owner 2026-11-03, mig 965)' WHERE id = 6;
UPDATE budget_lines SET label = 'ICSL Spring 2027 — U10 team fee + GotSport', amount_usd = 205.00, is_assumed = false,
       period_start = '2027-02-01', period_end = '2027-05-23', note = 'ICSL spring league (mig 965)' WHERE id = 9;
UPDATE budget_lines SET label = 'ICSL Spring 2027 — U12 team fee + GotSport', amount_usd = 205.00, is_assumed = false,
       period_start = '2027-02-01', period_end = '2027-05-23', note = 'ICSL spring league (mig 965)' WHERE id = 12;
SELECT pg_temp.link(b.id, f.id, b.t, f.season_id, 1)
  FROM (VALUES (9, 913), (12, 914)) AS b(id, t), league_fees f
 WHERE f.season_id = pg_temp.ss(pg_temp.lg('Inter-County Soccer League'), 'Spring 2027') AND f.fee_kind IN ('team_entry', 'software');

-- Cups, next cycle (entries due Aug 2027), and the Grassroots Cup 2027.
CREATE OR REPLACE FUNCTION pg_temp.bl(p_label text, p_amt numeric, p_from date, p_to date, p_assumed bool, p_sort int, p_note text) RETURNS int LANGUAGE plpgsql AS $$
DECLARE v int;
BEGIN
  SELECT id INTO v FROM budget_lines WHERE club_id = 134 AND label = p_label;
  IF v IS NULL THEN
    INSERT INTO budget_lines (club_id, club_section_id, category, label, amount_usd, amount_per, period_start, period_end, spread, is_assumed, sort_order, note)
    VALUES (134, 1, 'league_dues', p_label, p_amt, 'fixed', p_from, p_to, 'start', p_assumed, p_sort, p_note) RETURNING id INTO v;
  END IF;
  RETURN v;
END $$;
DO $$
DECLARE
  nac  int := pg_temp.ss(pg_temp.lg('USASA National Amateur Cup'), '2027/2028');
  fri  int := pg_temp.ss(pg_temp.lg('Werner Fricker Open Cup'), '2027/2028');
  oc   int := pg_temp.ss(pg_temp.lg('Lamar Hunt U.S. Open Cup qualifying'), '2028');
  grc  int := pg_temp.ss(pg_temp.lg('Philly Grassroots Cup'), '2027');
  b    int;
BEGIN
  b := pg_temp.bl('US Amateur Cup 2027-28 — EPSA + USASA entry', 250, '2027-08-01', '2027-08-31', true, 30,
                  'EPSA $200 + USASA qualifying $50, at 2026-27 prices; Region I adds $100 + $500 bond if we advance (mig 965)');
  PERFORM pg_temp.link(b, f.id, 939, nac, 1) FROM league_fees f WHERE f.season_id = nac AND f.fee_kind IN ('team_entry', 'round_entry');
  b := pg_temp.bl('Werner Fricker Open Cup 2027-28 — EPSA Open Mens entry', 250, '2027-08-01', '2027-08-31', true, 31,
                  'EPSA Open Mens $250 at the 2026-27 price; Region I fees not published (mig 965)');
  PERFORM pg_temp.link(b, f.id, 939, fri, 1) FROM league_fees f WHERE f.season_id = fri AND f.fee_kind = 'team_entry';
  b := pg_temp.bl('U.S. Open Cup 2028 qualifying — entry (refs included)', 500, '2027-08-01', '2027-08-31', false, 32,
                  'Owner 2026-11-03: "$500 total … refs are included"; the $1,500 bond comes back, so it is not a cost (mig 965)');
  PERFORM pg_temp.link(b, f.id, 939, oc, 1) FROM league_fees f WHERE f.season_id = oc AND f.fee_kind IN ('team_entry', 'referee');
  b := pg_temp.bl('Philly Grassroots Cup 2027 — entry', 1400, '2027-03-01', '2027-07-31', true, 33,
                  'General price of the 2026 edition; 2027 not announced (mig 965)');
  PERFORM pg_temp.link(b, f.id, 939, grc, 1) FROM league_fees f WHERE f.season_id = grc AND f.fee_kind = 'team_entry' AND f.tier = 'general';
END $$;

-- ── 8. Invoice lines → the budget lines they pay ────────────────────────────
-- Only where a budget line projects the same money; one-offs (seed, soil,
-- carts, lights, Veo, ITC clearances, field rental) have no budget line.
UPDATE invoice_installment_plans SET budget_line_id = 1 WHERE id = 12 AND budget_line_id IS NULL;   -- APSL League Dues plan
UPDATE invoice_lines             SET budget_line_id = 2 WHERE id = 86 AND budget_line_id IS NULL;   -- CASA Liga 1 League payment 11/6
UPDATE invoice_installment_plans SET budget_line_id = 4 WHERE id = 8  AND budget_line_id IS NULL;   -- Youth u8,u10, u12 ($1,200 plan)
UPDATE invoice_lines             SET budget_line_id = 4 WHERE id = 24 AND budget_line_id IS NULL;   -- Assignor Fee u8,u10,u12 PPR Fall
UPDATE invoice_lines             SET budget_line_id = 17 WHERE id IN (15, 87) AND budget_line_id IS NULL;   -- Field Paint 9/11, 11/6

COMMIT;
