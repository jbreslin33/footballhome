-- 1333 (2026-11-13): Liga 2 in spring — an option on the Year plan.
--
-- Owner: "the budget assumes eventually a liga 2 team full year and the hope
-- is to have one for spring … just have an option on finance page to add
-- liga 2 in spring."
--
--   team_season_entries.is_option  an entry the Year plan leaves out until
--        its switch is on (never on the grid / #cash-flow)
--   team     Lighthouse Mens Club Liga 2 — budget only (inactive, off boards)
--   pill     Men's › Liga 2
--   division CASA Select 2026/2027 › Liga 2
--   spring   all assumed: $1,899 dues (Liga 1's price — a spring-only price
--            unknown), 25 players included + 10 × $23, refs $130 × 10 games
--            (Liga 1's spring count), James's game coaching $49 × 10 (2.45 h ×
--            $20), kits $35 × 35.  Practices are shared — no extra.
--   new fee kinds: kit (Uniforms), game_coaching (Coaching) — a team's own
--            per-player / per-game costs on its season's price list

BEGIN;

ALTER TABLE team_season_entries ADD COLUMN IF NOT EXISTS is_option boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN team_season_entries.is_option IS 'Year plan option: counted only when its switch is on (mig 1333)';

INSERT INTO fee_kinds (code, label, sort_order, category, is_refundable) VALUES
  ('kit',           'Kits',          13, 'uniforms', false),
  ('game_coaching', 'Game coaching', 14, 'labor',    false)
ON CONFLICT (code) DO NOTHING;

WITH t AS (
  INSERT INTO teams (club_id, name, slug, gender_category, roster_source, label, short_label, color,
                     is_active, club_section_id, field_size, on_tuition_card, league_roster, board_archived_at, max_roster, updated_at)
  VALUES (134, 'Lighthouse Mens Club Liga 2', 'lighthouse-mens-club-liga-2', 'mens', 'direct', '🏆 Liga 2', 'Liga 2', '#1d4ed8',
          false, 1, 11, false, false, now(), 35, now())
  RETURNING id
), sc AS (
  INSERT INTO cash_flow_scopes (code, label, parent, category, leagues, section_code, sort_order, team_id)
  SELECT 'liga2', 'Liga 2', 'mens', NULL, '{}', NULL, 16, t.id FROM t RETURNING team_id
), d AS (
  INSERT INTO league_divisions (season_id, name, sort_order) VALUES (40, 'Liga 2', 2) RETURNING id
), f AS (
  INSERT INTO league_fees (season_id, fee_kind, unit, amount_usd, is_assumed, checked_on, note, division_id, players_included)
  SELECT 40, v.kind, v.unit, v.amt, true, '2026-11-13', v.note, d.id, v.incl
    FROM d, (VALUES ('team_entry',    'per_team_season', 1899.00, 25,        'Assumed at Liga 1''s price — a spring-only price unknown'),
                    ('extra_player',  'per_player',        23.00, NULL::int, 'Same as Liga 1: 25 included, then $23'),
                    ('referee',       'per_game',         130.00, NULL,      'Same as Liga 1: $130 every game, both teams'),
                    ('game_coaching', 'per_game',          49.00, NULL,      'James: 2.45 h × $20 a game, like Liga 1'),
                    ('kit',           'per_player',        35.00, NULL,      '$35 a kit, like every man')) AS v(kind, unit, amt, incl, note)
  RETURNING id, fee_kind
), e AS (
  INSERT INTO team_season_entries (team_id, season_id, status, note, division_id, budget_from_plan, is_option)
  SELECT sc.team_id, 40, 'planned', 'Spring 2027', d.id, true, true FROM sc, d
  RETURNING id
)
INSERT INTO team_fee_plans (entry_id, league_fee_id, season_id, quantity, is_assumed, note)
SELECT e.id, f.id, 40,
       CASE f.fee_kind WHEN 'team_entry' THEN 1 WHEN 'extra_player' THEN 10 WHEN 'kit' THEN 35 ELSE 10 END, true,
       CASE f.fee_kind WHEN 'team_entry'    THEN 'Spring entry'
                       WHEN 'extra_player'  THEN '35 planned: 25 included + 10'
                       WHEN 'kit'           THEN '35 men'
                       ELSE '10 spring games, like Liga 1''s spring' END
  FROM e, f;

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public) VALUES
  ('Finances', 'Finances — Year plan option switch (off)', 'finances', 'plan_option_add', '＋ {team} in {when}', true, 86, true, false),
  ('Finances', 'Finances — Year plan option switch (on)',  'finances', 'plan_option_on',  '✓ {team} in {when} — tap to take out', true, 87, true, false),
  ('Finances', 'Finances — Year plan option tag',          'finances', 'plan_option_tag', 'option', true, 88, true, false);

INSERT INTO schema_migrations (filename) VALUES ('1333-liga2-spring-option.sql') ON CONFLICT DO NOTHING;
COMMIT;
