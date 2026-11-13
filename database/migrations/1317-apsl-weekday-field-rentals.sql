-- 1317 (2026-11-13): APSL weekday home games on a rented lit field.
--
-- Owner: "a few times we have to rent a field for apsl game if we have to
-- host weekday game since we don't have lights. so maybe bake in 2 rentals a
-- year at 250 each."  Per home game on a rented field, assumed 2 a year.

BEGIN;

INSERT INTO fee_kinds (code, label, sort_order, category, is_refundable)
VALUES ('field_rental', 'Field rental for a home game', 11, 'field_rentals', false)
ON CONFLICT (code) DO NOTHING;

WITH f AS (
  INSERT INTO league_fees (season_id, fee_kind, unit, amount_usd, is_assumed, checked_on, note)
  VALUES (39, 'field_rental', 'per_home_game', 250.00, true, '2026-11-13',
          'Lit field for a weekday home game — Lighthouse has no lights (owner 2026-11-13)')
  RETURNING id
)
INSERT INTO team_fee_plans (entry_id, league_fee_id, season_id, quantity, is_assumed, note)
SELECT 1, f.id, 39, 2, true, '2 weekday home games a year on a rented field (owner 2026-11-13)' FROM f;

INSERT INTO schema_migrations (filename) VALUES ('1317-apsl-weekday-field-rentals.sql') ON CONFLICT DO NOTHING;
COMMIT;
