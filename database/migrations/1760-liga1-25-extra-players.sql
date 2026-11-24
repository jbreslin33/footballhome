-- 1760 (2026-11-23): Liga 1 — plan for 25 players past the 25 the dues include (was 10).
--
-- Owner 2026-11-23: "way more than 10 adds above the 25 free. put like 25
-- above the 25 to be safe".  Facts unchanged: roster of 35, first 25 in the
-- league dues, $23 each after that.  The estimate is how many are added in
-- the year — adds and drops take it past the roster size.
-- 25 × $23 = $575 (was $230), both years; the five add payments follow.

BEGIN;

UPDATE team_fee_plans SET quantity = 25, is_assumed = true,
       note = 'Estimate: 25 players past the 25 the league dues include, $23 each — adds and drops through the year; roster is 35 (owner 2026-11-23)'
 WHERE id IN (7, 47);

UPDATE team_season_installments i SET amount = 115.00, note = 'Player adds ' || x.n || ' of 25 × $23'
  FROM (SELECT id, (5 * (row_number() OVER (ORDER BY due_on) - 1) + 1) || '–' || (5 * row_number() OVER (ORDER BY due_on)) AS n
          FROM team_season_installments WHERE entry_id = 2 AND note LIKE 'Player adds%') x
 WHERE i.id = x.id;

INSERT INTO schema_migrations (filename) VALUES ('1760-liga1-25-extra-players.sql') ON CONFLICT DO NOTHING;
COMMIT;
