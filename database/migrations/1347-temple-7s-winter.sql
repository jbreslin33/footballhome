-- 1347 (2026-11-13): Men's — 3 teams in CASA Winter 2 2026-27 Open 7s, Temple, Saturdays.
--
-- Owner: "lets add 3 teams for temple winter … $829 per team 5 games.
-- Saturdays. refs $30 per game. playoffs but i would not factor that in …
-- its for men."
-- Page: https://www.casasoccerleagues.com/page/show/9669620-winter-2-2026-27-open-7s-temple-saturday
--   new teams $829 early bird (by Tue Dec 8; $879 general to Dec 15, $979 late)
--   "5 matches + playoffs", 7v7 indoors on turf, Temple STAR Complex
--   "$30 match official fee per match … paid each match by BOTH teams"
--   Matchweek One Sat Jan 2 — end date not posted: 5 Saturdays → Jan 30 (assumed)
--
--   league      CASA Open 7s (new; not Select / Traditional)
--   season      Winter 2 2026/27, 2027-01-02 … 2027-01-30
--   teams       Temple 7s A / B / C (Men's) — budget only: inactive, off the
--               boards and the tuition card, no dues_rank (not in full house)
--   pill        Men's › Temple 7s (one pill; B and C via budget_scope)
--   plan        each: entry $829 × 1 (installment Dec 8, early bird) + refs $30 × 5
--               = $979; three = $2,937. Playoffs not budgeted — added if we go.

BEGIN;

INSERT INTO leagues (organization_id, name, website_url, source_system_id, sex_restriction_id)
SELECT organization_id, 'CASA Open 7s', website_url, source_system_id, sex_restriction_id FROM leagues WHERE id = 2;

INSERT INTO seasons (league_id, name, start_date, end_date)
SELECT id, 'Winter 2 2026/27', '2027-01-02', '2027-01-30' FROM leagues WHERE organization_id = 2 AND name = 'CASA Open 7s';

INSERT INTO teams (club_id, name, slug, gender_category, roster_source, label, short_label, color,
                   is_active, club_section_id, field_size, on_tuition_card, league_roster, board_archived_at, updated_at)
VALUES (134, 'Lighthouse Temple 7s A', 'lighthouse-temple-7s-a', 'mens', 'direct', '7️⃣ Temple 7s A', 'Temple A', '#0f766e', false, 1, 7, false, false, now(), now()),
       (134, 'Lighthouse Temple 7s B', 'lighthouse-temple-7s-b', 'mens', 'direct', '7️⃣ Temple 7s B', 'Temple B', '#0f766e', false, 1, 7, false, false, now(), now()),
       (134, 'Lighthouse Temple 7s C', 'lighthouse-temple-7s-c', 'mens', 'direct', '7️⃣ Temple 7s C', 'Temple C', '#0f766e', false, 1, 7, false, false, now(), now());

INSERT INTO cash_flow_scopes (code, label, parent, category, leagues, section_code, sort_order, team_id)
SELECT 'temple7s', 'Temple 7s', 'mens', NULL, '{}', NULL, 15, id FROM teams WHERE slug = 'lighthouse-temple-7s-a';

WITH s AS (
  SELECT s.id FROM seasons s JOIN leagues l ON l.id = s.league_id WHERE l.name = 'CASA Open 7s' AND s.name = 'Winter 2 2026/27'
)
INSERT INTO league_fees (season_id, fee_kind, unit, amount_usd, is_assumed, source_url, source_quote, checked_on, note)
SELECT s.id, v.kind, v.unit, v.amt, false,
       'https://www.casasoccerleagues.com/page/show/9669620-winter-2-2026-27-open-7s-temple-saturday', v.quote, '2026-11-13', v.note
  FROM s, (VALUES ('team_entry', 'per_team_season', 829.00, 'New teams: $829 early bird, $879 general, $979 late', 'New-team early bird, by Tue Dec 8 (owner 2026-11-13)'),
                  ('referee',    'per_game',         30.00, '$30 match official fee per match … paid each match by BOTH teams', 'Our share per match')) AS v(kind, unit, amt, quote, note);

WITH s AS (
  SELECT s.id FROM seasons s JOIN leagues l ON l.id = s.league_id WHERE l.name = 'CASA Open 7s' AND s.name = 'Winter 2 2026/27'
), e AS (
  INSERT INTO team_season_entries (team_id, season_id, status, note, budget_from_plan, budget_scope)
  SELECT t.id, s.id, 'planned', 'CASA Winter 2 Open 7s, Temple, Saturdays (owner 2026-11-13)', true,
         CASE WHEN t.slug = 'lighthouse-temple-7s-a' THEN NULL ELSE 'temple7s' END
    FROM s, teams t WHERE t.slug LIKE 'lighthouse-temple-7s-_'
  RETURNING id, season_id
), p AS (
  INSERT INTO team_fee_plans (entry_id, league_fee_id, season_id, quantity, is_assumed, note)
  SELECT e.id, f.id, e.season_id, CASE f.fee_kind WHEN 'team_entry' THEN 1 ELSE 5 END, false,
         CASE f.fee_kind WHEN 'team_entry' THEN 'Team entry, early bird' ELSE '5 matches (owner 2026-11-13); playoffs not budgeted' END
    FROM e JOIN league_fees f ON f.season_id = e.season_id
  RETURNING entry_id
)
INSERT INTO team_season_installments (entry_id, due_on, amount, note)
SELECT e.id, '2026-12-08', 829.00, 'Early bird deadline' FROM e;

INSERT INTO schema_migrations (filename) VALUES ('1347-temple-7s-winter.sql') ON CONFLICT DO NOTHING;
COMMIT;
