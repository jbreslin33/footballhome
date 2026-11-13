-- 1326 (2026-11-13): U23 plays 6 games.
-- Owner: "u23 is 6 games. and possible playoffs so we would not assume
-- playoff right?" — the budget is the minimum season; playoff refs get added
-- if we qualify.
BEGIN;
UPDATE team_fee_plans p SET quantity = 6, is_assumed = false,
       note = '6 games (owner 2026-11-13); playoffs not budgeted — added if we qualify'
  FROM league_fees f, team_season_entries e, teams t
 WHERE f.id = p.league_fee_id AND f.fee_kind = 'referee' AND e.id = p.entry_id AND t.id = e.team_id AND t.name = 'Lighthouse Mens Club U23';
INSERT INTO schema_migrations (filename) VALUES ('1326-u23-six-games.sql') ON CONFLICT DO NOTHING;
COMMIT;
