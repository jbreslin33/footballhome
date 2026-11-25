-- 1877 (2026-11-24) — The League for Clubs' partner leagues: Midwest, Mountain and Upstate PL
-- standings, read from their own sites.  Owner: "and norcal divsison 2 and gulf coast premer
-- league etc" · "do midwest upstate and mountain and commit".
-- Two new readers (LeagueTableReaders): html_table — a page with one <table> per division
-- (Midwest PL, Mountain PL); text_grid — a Squarespace page whose table is a grid of text boxes
-- (Upstate PL).  Locator = the page, then optionally the tables' names in page order joined by
-- " ; " (Midwest names its tables in a tab row away from them).  The three hosts were added to
-- the scraper VPN's proxy allow-list (.docker/scraper/tinyproxy.filter).
-- NorCal Division 2 (no site known) and the Gulf Coast PL (its site answers almost nothing) and
-- Metroplex PL (a JavaScript stats app) stay named boxes for now.
ALTER TABLE pro_leagues DROP CONSTRAINT IF EXISTS pro_leagues_feed_system_check;
ALTER TABLE pro_leagues ADD CONSTRAINT pro_leagues_feed_system_check CHECK (feed_system = ANY (ARRAY[
  'espn', 'espn_teams', 'modular11', 'google_sheet', 'wikipedia_sports_table', 'wikipedia_club_list', 'html_table', 'text_grid']));

UPDATE pro_leagues SET feed_system = 'html_table', refresh_hours = 24,
       feed_locator = 'https://www.midwestpl.com/standings/ ; Gateway ; Heartland ; Great Lakes West ; Great Lakes East'
 WHERE name = 'Midwest Premier League' AND feed_system IS NULL;
UPDATE pro_leagues SET feed_system = 'html_table', refresh_hours = 24,
       feed_locator = 'https://mountainpl.com/standings'
 WHERE name = 'Mountain Premier League' AND feed_system IS NULL;
UPDATE pro_leagues SET feed_system = 'text_grid', refresh_hours = 24,
       feed_locator = 'https://www.uplny.com/standings'
 WHERE name = 'Upstate Premier League' AND feed_system IS NULL;
