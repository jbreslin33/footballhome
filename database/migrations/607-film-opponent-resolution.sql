-- 607 (2026-10-19) — Film: name BOTH teams on every row.
-- Owner: "the game film for apsl should try to find who home team was
-- playing via fuzzy logic based on schedule. remember the date should be
-- right be could be off a little … if its only home team listed for
-- playres they may not know easy who the away team was and that might be
-- who they were looking for."
--
-- Until now league_fixtures carried only OUR TeamPass .ics feed, so only
-- Lighthouse's film rows could name the matchup.  A new fixture-source
-- system 'teampass_json' (LeagueFixtureSync) pulls the league site's
-- Jumbotron widget data — one json with every division's teams and games,
-- filtered to our division by program_id '<leagueSiteId>/<divisionId>' —
-- and the fixture upsert dedupes the overlap with our own .ics feed.  The
-- source row is loaded operationally (psql), never by migration, like the
-- film sheet's csv_url.  The film matcher then resolves every row's game —
-- same fuzzy rule as before: alias → club, nearest fixture within window
-- ±3 days — and FilmSync re-pulls the fixtures on the sheet's staleness
-- cadence.
--
-- This is the matched row's wording, and the sheet alias the list was
-- missing ('PSC' = Philadelphia Soccer Club on the league site).
BEGIN;

INSERT INTO film_team_aliases (alias, feed_name) VALUES
  ('psc', 'Philadelphia Soccer Club')
ON CONFLICT (alias) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', 'Film — matched game, not ours', 'film', 'matched', NULL,
       '{day} · {home} vs {away}', 7, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'film' AND tier = 'matched');

COMMIT;
