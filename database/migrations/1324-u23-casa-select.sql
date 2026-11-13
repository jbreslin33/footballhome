-- 1324 (2026-11-13): Men's U23 — a CASA Select division, budgeted from its plan.
--
-- Owner: "u23 league dues 749. registrations for players are same as liga 1.
-- ref fees same as liga 1 … its a div of casa select but not in the pyramid.
-- yes other assumptions are right" (this budget year, 35 players).
--
--   team        Lighthouse Mens Club U23 (Men's) — budget only for now: off
--               the boards and the tuition card, inactive until it has a roster
--   pill        Men's › U23 (cash_flow_scopes)
--   division    CASA Select 2026/2027 › U23 (league_divisions — not the pyramid)
--   rate card   $749 entry; 25 players included then $23 each; refs $130 a
--               game paid by both teams — Liga 1's rules (fees 9, 10)
--   plan        35 players (10 beyond 25, assumed); games assumed like Liga 1:
--               22 (12 fall + 10 spring) — owner gave no count

BEGIN;

WITH t AS (
  INSERT INTO teams (club_id, name, slug, gender_category, roster_source, label, short_label, color,
                     is_active, club_section_id, field_size, on_tuition_card, league_roster, board_archived_at, updated_at)
  VALUES (134, 'Lighthouse Mens Club U23', 'lighthouse-mens-club-u23', 'mens', 'direct', '🏆 U23', 'U23', '#1d4ed8',
          false, 1, 11, false, false, now(), now())
  RETURNING id
), sc AS (
  INSERT INTO cash_flow_scopes (code, label, parent, category, leagues, section_code, sort_order, team_id)
  SELECT 'u23', 'U23', 'mens', NULL, '{}', NULL, 14, t.id FROM t RETURNING team_id
), d AS (
  INSERT INTO league_divisions (season_id, name, sort_order) VALUES (40, 'U23', 1) RETURNING id
), f AS (
  INSERT INTO league_fees (season_id, fee_kind, unit, amount_usd, is_assumed, source_url, source_quote, checked_on, note, division_id)
  SELECT 40, v.kind, v.unit, v.amt, false, l.source_url, l.source_quote, '2026-11-13', v.note, d.id
    FROM d, (VALUES ('team_entry',   'per_team_season', 749.00, NULL::int, 'U23 league dues (owner 2026-11-13)'),
                    ('extra_player', 'per_player',       23.00, 9,         'Same as Liga 1 (owner 2026-11-13)'),
                    ('referee',      'per_game',        130.00, 10,        'Same as Liga 1 (owner 2026-11-13)')) AS v(kind, unit, amt, like_id, note)
    LEFT JOIN league_fees l ON l.id = v.like_id
  RETURNING id, fee_kind
), e AS (
  INSERT INTO team_season_entries (team_id, season_id, status, note, division_id, budget_from_plan)
  SELECT sc.team_id, 40, 'planned', 'CASA Select U23 division, not in the pyramid (owner 2026-11-13)', d.id, true FROM sc, d
  RETURNING id
)
INSERT INTO team_fee_plans (entry_id, league_fee_id, season_id, quantity, is_assumed, note)
SELECT e.id, f.id, 40,
       CASE f.fee_kind WHEN 'team_entry' THEN 1 WHEN 'extra_player' THEN 10 ELSE 22 END,
       f.fee_kind <> 'team_entry',
       CASE f.fee_kind WHEN 'team_entry' THEN 'U23 league dues (owner 2026-11-13)'
                       WHEN 'extra_player' THEN '35 planned like APSL: 25 included + 10 × $23 (owner 2026-11-13)'
                       ELSE 'Games assumed like Liga 1: 12 fall + 10 spring — owner gave no count' END
  FROM e, f;

INSERT INTO schema_migrations (filename) VALUES ('1324-u23-casa-select.sql') ON CONFLICT DO NOTHING;
COMMIT;
