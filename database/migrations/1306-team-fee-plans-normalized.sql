-- 1306 (2026-11-12): league fees normalized — proposed per team, then actual.
-- Owner: "lets do league fees for each team for men first … we need to
-- normalize and then show me tables".
--
--   invoice_line_categories  top level, owner's order (+ Bonds, refundable)
--   fee_kinds                each kind of league charge → its category;
--                            refundable lives here now (was per fee row)
--   fee_units                what the quantity counts (have)
--   fee_tiers                early bird / general / late (was free text)
--   league_divisions         a league season's divisions, parent for groups
--                            (DRC › Group B).  Not the scraper's `divisions`
--                            table — that one needs a conference and teams
--                            cascade off it.
--   league_fees              the rate card; division_id + tier FK + valid_until
--   team_season_entries      team in a league season; division_id
--   team_fee_plans           PROPOSED: entry × rate-card fee × quantity.  The
--                            amount is never copied — rate × quantity.
--   team_season_installments when what we owe a league for an entry is due
--   team_fee_plan_lines      view: one row per plan line, proposed $
--   team_season_fee_check    view: per entry, proposed vs installments
--
-- Judgement call (owner "sure"): per-game quantity is a stored estimate; the
-- published schedule count is shown beside it later, never overwrites it.
-- Old budget_lines / ref_fee_seasons / cash_flow_planned rows keep #finances
-- and #cash-flow running until they read these tables (after Men's check).

BEGIN;

-- ── categories ───────────────────────────────────────────────────────────
INSERT INTO invoice_line_categories (code, label, sort_order)
VALUES ('bonds', 'Bonds (refundable):', 10) ON CONFLICT (code) DO NOTHING;

-- ── fee kinds → category, refundable ────────────────────────────────────
ALTER TABLE fee_kinds ADD COLUMN IF NOT EXISTS category text REFERENCES invoice_line_categories(code);
ALTER TABLE fee_kinds ADD COLUMN IF NOT EXISTS is_refundable boolean NOT NULL DEFAULT false;
UPDATE fee_kinds SET category = CASE code
    WHEN 'team_entry'   THEN 'league_dues'
    WHEN 'credit'       THEN 'league_dues'
    WHEN 'assignor'     THEN 'referees'
    WHEN 'software'     THEN 'league_dues'
    WHEN 'player_fee'   THEN 'registrations'
    WHEN 'extra_player' THEN 'registrations'
    WHEN 'round_entry'  THEN 'league_dues'
    WHEN 'referee'      THEN 'referees'
    WHEN 'bond'         THEN 'bonds' END,
  is_refundable = (code = 'bond');
ALTER TABLE fee_kinds ALTER COLUMN category SET NOT NULL;

-- every refundable fee row was a bond — the fact moves to the kind
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM league_fees f JOIN fee_kinds k ON k.code = f.fee_kind
              WHERE f.is_refundable <> k.is_refundable) THEN
    RAISE EXCEPTION 'league_fees.is_refundable disagrees with fee_kinds';
  END IF;
END $$;
ALTER TABLE league_fees DROP COLUMN is_refundable;

-- ── price tiers ──────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS fee_tiers (
  code       text PRIMARY KEY,
  label      text NOT NULL,
  sort_order integer NOT NULL
);
INSERT INTO fee_tiers VALUES ('early_bird', 'Early bird', 1), ('general', 'General', 2), ('late', 'Late', 3)
ON CONFLICT (code) DO NOTHING;
ALTER TABLE league_fees ADD CONSTRAINT league_fees_tier_fkey FOREIGN KEY (tier) REFERENCES fee_tiers(code);
ALTER TABLE league_fees ADD COLUMN IF NOT EXISTS valid_until date;
UPDATE league_fees SET valid_until = '2026-06-30' WHERE id = 6;   -- CASA "Early bird closed June 30"

-- ── divisions ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS league_divisions (
  id         serial PRIMARY KEY,
  season_id  integer NOT NULL REFERENCES seasons(id) ON DELETE CASCADE,
  parent_id  integer REFERENCES league_divisions(id),
  name       text NOT NULL,
  sort_order integer NOT NULL DEFAULT 0,
  UNIQUE (season_id, parent_id, name)
);
INSERT INTO league_divisions (season_id, name)
SELECT DISTINCT season_id, division FROM league_fees WHERE COALESCE(division, '') <> ''
UNION
SELECT DISTINCT season_id, division FROM team_season_entries
 WHERE COALESCE(division, '') <> '' AND division NOT LIKE '% — %';
-- "Delaware River Conference — Group B" = Group B under DRC
INSERT INTO league_divisions (season_id, parent_id, name)
SELECT e.season_id, p.id, split_part(e.division, ' — ', 2)
  FROM team_season_entries e
  JOIN league_divisions p ON p.season_id = e.season_id AND p.name = split_part(e.division, ' — ', 1) AND p.parent_id IS NULL
 WHERE e.division LIKE '% — %';

ALTER TABLE league_fees         ADD COLUMN division_id integer REFERENCES league_divisions(id);
ALTER TABLE team_season_entries ADD COLUMN division_id integer REFERENCES league_divisions(id);
UPDATE league_fees f SET division_id = d.id FROM league_divisions d
 WHERE d.season_id = f.season_id AND d.parent_id IS NULL AND d.name = f.division;
UPDATE team_season_entries e SET division_id = d.id FROM league_divisions d
 WHERE d.season_id = e.season_id AND d.parent_id IS NULL AND d.name = e.division AND e.division NOT LIKE '% — %';
UPDATE team_season_entries e SET division_id = c.id
  FROM league_divisions c JOIN league_divisions p ON p.id = c.parent_id
 WHERE c.season_id = e.season_id AND e.division = p.name || ' — ' || c.name;
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM league_fees WHERE COALESCE(division, '') <> '' AND division_id IS NULL)
  OR EXISTS (SELECT 1 FROM team_season_entries WHERE COALESCE(division, '') <> '' AND division_id IS NULL) THEN
    RAISE EXCEPTION 'division text left unmapped';
  END IF;
END $$;
ALTER TABLE league_fees         DROP COLUMN division;
ALTER TABLE team_season_entries DROP COLUMN division;

-- ── proposed: team fee plans ─────────────────────────────────────────────
ALTER TABLE league_fees         ADD CONSTRAINT league_fees_id_season_key         UNIQUE (id, season_id);
ALTER TABLE team_season_entries ADD CONSTRAINT team_season_entries_id_season_key UNIQUE (id, season_id);

CREATE TABLE IF NOT EXISTS team_fee_plans (
  id            serial PRIMARY KEY,
  entry_id      integer NOT NULL,
  league_fee_id integer NOT NULL,
  season_id     integer NOT NULL,          -- ties the fee and the entry to ONE season
  quantity      numeric(8,2) NOT NULL CHECK (quantity >= 0),
  is_assumed    boolean NOT NULL DEFAULT false,
  note          text,
  UNIQUE (entry_id, league_fee_id),
  FOREIGN KEY (entry_id, season_id)      REFERENCES team_season_entries (id, season_id) ON DELETE CASCADE,
  FOREIGN KEY (league_fee_id, season_id) REFERENCES league_fees (id, season_id)         ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS team_season_installments (
  id       serial PRIMARY KEY,
  entry_id integer NOT NULL REFERENCES team_season_entries(id) ON DELETE CASCADE,
  due_on   date NOT NULL,
  amount   numeric(10,2) NOT NULL,
  note     text
);

-- ── Men's teams moved on (from budget_line_fees, ref_fee_seasons,
--    cash_flow_planned, budget_lines.paid_before_usd) ─────────────────────
INSERT INTO team_fee_plans (entry_id, league_fee_id, season_id, quantity, is_assumed, note) VALUES
  -- APSL (team 35), entry 1
  (1,  1, 39,  1, false, NULL),
  (1,  2, 39,  1, false, NULL),
  (1,  3, 39, 36, false, 'budget_line_fees: 36 players on the main roster'),
  (1,  5, 39, 11, false, '6 fall + 5 spring home games (owner 2026-11-03)'),
  -- Reserves (team 938), entry 16
  (16, 51, 39, 15, true, 'cash_flow_planned: 15 reserve adds, Nov–May'),
  -- Liga 1 (team 120), entry 2
  (2,  7, 40,  1, false, 'General tier — early bird closed June 30'),
  (2,  9, 40, 15, true, 'cash_flow_planned: 15 player adds (planned at $25; rate card says $23)'),
  (2, 10, 40, 22, true, '12 fall + 10 spring games (spring guessed)'),
  -- Cups (team 939)
  (11, 28, 43, 1, false, 'Played 10/18 at Phoenix SCM; the $200 entry is on no invoice'),
  (12, 41, 44, 1, true,  NULL),
  (12, 42, 44, 1, true,  NULL),
  (13, 43, 46, 1, true,  NULL),
  (14, 44, 48, 1, true,  NULL),
  (14, 45, 48, 1, true,  NULL),
  (15, 48, 50, 1, true,  'General tier assumed');

INSERT INTO team_season_installments (entry_id, due_on, amount, note) VALUES
  (1, '2026-07-31', 2388.75, 'Paid before Aug 1 (budget_lines.paid_before_usd)'),
  (1, '2026-11-30', 1250.00, 'APSL balance, payments 1–5 of 9 at $250'),
  (1, '2026-12-31',  980.00, 'APSL balance, payments 6–9 of 9 (last $230)'),
  (2, '2026-07-31',  519.49, 'Paid before Aug 1 (budget_lines.paid_before_usd)'),
  (2, '2026-12-27',  250.19, 'Liga 1 league payment 1 of 3'),
  (2, '2027-02-25',  250.19, 'Liga 1 league payment 2 of 3'),
  (2, '2027-04-26',  250.19, 'Liga 1 league payment 3 of 3');

-- ── views ────────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW team_fee_plan_lines AS
SELECT p.id AS plan_id, e.id AS entry_id, e.team_id, t.name AS team,
       l.name AS league, s.name AS season,
       CASE WHEN pd.id IS NULL THEN d.name ELSE pd.name || ' › ' || d.name END AS entry_division,
       fd.name AS fee_division,
       c.code AS category, c.sort_order AS category_order,
       k.code AS fee_kind, k.label AS fee_label, k.sort_order AS kind_order, k.is_refundable,
       f.tier, f.unit, f.amount_usd AS rate, p.quantity,
       round(f.amount_usd * p.quantity, 2) AS proposed,
       (p.is_assumed OR f.is_assumed) AS is_assumed, p.note
  FROM team_fee_plans p
  JOIN team_season_entries e ON e.id = p.entry_id
  JOIN teams t ON t.id = e.team_id
  JOIN seasons s ON s.id = p.season_id
  JOIN leagues l ON l.id = s.league_id
  JOIN league_fees f ON f.id = p.league_fee_id
  JOIN fee_kinds k ON k.code = f.fee_kind
  JOIN invoice_line_categories c ON c.code = k.category
  LEFT JOIN league_divisions d  ON d.id = e.division_id
  LEFT JOIN league_divisions pd ON pd.id = d.parent_id
  LEFT JOIN league_divisions fd ON fd.id = f.division_id;

-- what we owe a league per entry (referees are paid per game, not to the
-- league, so they stay out of the installment check)
CREATE OR REPLACE VIEW team_season_fee_check AS
WITH owed AS (
  SELECT entry_id, sum(proposed) AS proposed_to_league
    FROM team_fee_plan_lines WHERE category NOT IN ('referees') AND NOT is_refundable GROUP BY entry_id
), inst AS (
  SELECT entry_id, sum(amount) AS installments, count(*) AS n FROM team_season_installments GROUP BY entry_id
)
SELECT e.id AS entry_id, t.name AS team, l.name AS league, s.name AS season,
       COALESCE(o.proposed_to_league, 0) AS proposed_to_league,
       COALESCE(i.installments, 0) AS installments, COALESCE(i.n, 0) AS installment_count,
       COALESCE(i.installments, 0) - COALESCE(o.proposed_to_league, 0) AS difference
  FROM team_season_entries e
  JOIN teams t ON t.id = e.team_id
  JOIN seasons s ON s.id = e.season_id
  JOIN leagues l ON l.id = s.league_id
  LEFT JOIN owed o ON o.entry_id = e.id
  LEFT JOIN inst i ON i.entry_id = e.id;

INSERT INTO schema_migrations (filename) VALUES ('1306-team-fee-plans-normalized.sql') ON CONFLICT DO NOTHING;
COMMIT;
