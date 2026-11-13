-- 1318 (2026-11-13): APSL home-game physio, budgeted.
--
-- Owner: "also bake in physio fee. we try to use volunteer for it … but we
-- should budget 100 a home game for it."  $100 × every home game (the same
-- count the referee line uses), assumed — a volunteer game comes in under
-- budget.  New category Medical / physio.

BEGIN;

INSERT INTO invoice_line_categories (code, label, sort_order)
VALUES ('medical', 'Medical / physio:', 12) ON CONFLICT (code) DO NOTHING;

INSERT INTO fee_kinds (code, label, sort_order, category, is_refundable)
VALUES ('physio', 'Physio at a home game', 12, 'medical', false)
ON CONFLICT (code) DO NOTHING;

WITH f AS (
  INSERT INTO league_fees (season_id, fee_kind, unit, amount_usd, is_assumed, checked_on, note)
  VALUES (39, 'physio', 'per_home_game', 100.00, true, '2026-11-13',
          'Volunteers when we can; budgeted for every home game (owner 2026-11-13)')
  RETURNING id
)
INSERT INTO team_fee_plans (entry_id, league_fee_id, season_id, quantity, is_assumed, note)
SELECT 1, f.id, 39, 11, true, 'Every home game: 6 fall + 5 spring (owner 2026-11-13)' FROM f;

INSERT INTO schema_migrations (filename) VALUES ('1318-apsl-home-game-physio.sql') ON CONFLICT DO NOTHING;
COMMIT;
