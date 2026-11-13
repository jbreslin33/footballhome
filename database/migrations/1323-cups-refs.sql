-- 1323 (2026-11-13): refs for this year's cups.
-- Owner: "you have to add in refs for these cups."
--   * Werner Fricker (state open cup) 2026/27: no published ref fee — assumed
--     at the EPSA / Region I rate the Amateur Cup uses ($120 per team per
--     game), 1 game (knockout).
--   * Philly Grassroots Cup 2027: $130 per match paid by the captain (fee 50,
--     2026 price), not charged for the semifinal or final — 3 group games.
-- Amateur Cup refs ($120 × the 10/18 game) went in with mig 1322.

BEGIN;

WITH f AS (
  INSERT INTO league_fees (season_id, fee_kind, unit, amount_usd, is_assumed, checked_on, note, division_id)
  VALUES (45, 'referee', 'per_game', 120.00, true, '2026-11-13',
          'Not published — assumed at the EPSA / Region I Amateur Cup rate, $120 per team per game (owner 2026-11-13: add refs)', 17)
  RETURNING id
)
INSERT INTO team_fee_plans (entry_id, league_fee_id, season_id, quantity, is_assumed, note)
SELECT e.id, f.id, 45, 1, true, '1 game — knockout (owner 2026-11-13)'
  FROM f, team_season_entries e WHERE e.team_id = 939 AND e.season_id = 45;

INSERT INTO team_fee_plans (entry_id, league_fee_id, season_id, quantity, is_assumed, note)
VALUES (15, 50, 50, 3, true, '3 group games; semifinal and final have no ref fee (owner 2026-11-13: add refs)')
ON CONFLICT (entry_id, league_fee_id) DO NOTHING;

INSERT INTO schema_migrations (filename) VALUES ('1323-cups-refs.sql') ON CONFLICT DO NOTHING;
COMMIT;
