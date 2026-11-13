-- 1316 (2026-11-13): APSL game filming — Game in Frame, 3 games × $75.
--
-- Owner: "put in 3 game in frame games. $75 each … filming service, they
-- video the games and announce them."  Not paid to the league; like referees
-- it is a per-game cost of playing this season, so it sits on the season's
-- price list (league_fees) and the team plan.  New category Filming & media.
-- team_season_fee_check now counts only what is owed TO the league (league
-- dues + registrations), so per-game vendors stay out of it.

BEGIN;

INSERT INTO invoice_line_categories (code, label, sort_order)
VALUES ('media', 'Filming & media:', 11) ON CONFLICT (code) DO NOTHING;

INSERT INTO fee_kinds (code, label, sort_order, category, is_refundable)
VALUES ('game_film', 'Game filming + announcing', 10, 'media', false)
ON CONFLICT (code) DO NOTHING;

WITH f AS (
  INSERT INTO league_fees (season_id, fee_kind, unit, amount_usd, is_assumed, checked_on, note)
  VALUES (39, 'game_film', 'per_game', 75.00, false, '2026-11-13',
          'Game in Frame: films and announces the game (owner 2026-11-13)')
  RETURNING id
)
INSERT INTO team_fee_plans (entry_id, league_fee_id, season_id, quantity, is_assumed, note)
SELECT 1, f.id, 39, 3, false, '3 games filmed by Game in Frame (owner 2026-11-13)' FROM f;

CREATE OR REPLACE VIEW team_season_fee_check AS
WITH owed AS (
  SELECT entry_id, sum(proposed) AS proposed_to_league
    FROM team_fee_plan_lines WHERE category IN ('league_dues', 'registrations') AND NOT is_refundable GROUP BY entry_id
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

INSERT INTO schema_migrations (filename) VALUES ('1316-apsl-game-filming.sql') ON CONFLICT DO NOTHING;
COMMIT;
