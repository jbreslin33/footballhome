-- 1759 (2026-11-23): Liga 1 plays 21 games this year (was 22); 22 stays the norm for 2027/28.
--
-- Owner 2026-11-23: "liga 1 21 games full year".  The calendar has 12 CASA
-- league games in the fall window (Sep 13 – Dec 6), so spring is 9.
-- One count, three places that held it: the plan's referee quantity, the
-- referee policy's seasons and the coaching policy's seasons (which said
-- 11 + 11).
-- 2026-27: refs 21 × $130 = $2,730 (was $2,860), game coaching 21 × $55 = $1,155.

BEGIN;

UPDATE team_fee_plans SET quantity = 21, note = '21 games in the full year, $130 every game (owner 2026-11-23)' WHERE id = 8;
-- 2027/28 stays at 22: "21 this year maybe 22 next … that is eventual norm"
UPDATE team_fee_plans SET quantity = 22, note = '22 games — the normal full year (owner 2026-11-23); 2026/27 has 21' WHERE id IN (48, 50);

UPDATE ref_fee_seasons SET home_games_expected = 12, note = '12 league games on the calendar, Sep 13 – Dec 6' WHERE id IN (3, 16);
UPDATE ref_fee_seasons SET home_games_expected = 9,  note = '21 in the full year (owner 2026-11-23) less the 12 of fall' WHERE id IN (4, 17);

INSERT INTO schema_migrations (filename) VALUES ('1759-liga1-21-games.sql') ON CONFLICT DO NOTHING;
COMMIT;
