-- 1870 (2026-11-24) — MLS NEXT Pro's clubs and standings, read from Wikipedia.  Owner, of the 3D
-- pyramid: "where are mls next pro teams".  It had no feed (ESPN does not carry it).  Its season
-- article keeps the standings in one template per conference; the Sports-table reader now takes
-- several pages joined by " ; " and names each table from its page ("Eastern Conference").
-- New season = new page titles (the year is in them).
UPDATE pro_leagues
   SET feed_system = 'wikipedia_sports_table',
       feed_locator = 'Template:2026 MLS Next Pro Eastern Conference table ; Template:2026 MLS Next Pro Western Conference table',
       website_url = COALESCE(website_url, 'https://www.mlsnextpro.com/'),
       refresh_hours = 24, last_fetched_at = NULL, last_ok_at = NULL, last_fetch_note = NULL
 WHERE name = 'MLS NEXT Pro' AND feed_system IS NULL;
