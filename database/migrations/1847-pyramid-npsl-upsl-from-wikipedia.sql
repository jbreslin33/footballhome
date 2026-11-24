-- 1847 (2026-11-24) — 🔺 #apsl-pyramid: NPSL and UPSL, read from Wikipedia.
--
-- Owner: "oh forgot about npsl lol see if you can access them" · "you can get upsl pyramind on
-- wikipedia lol" · "same wiht npsl".
--
-- Neither league's own tables can be read: NPSL's 2026 standings are an embedded ladder whose
-- data API answers 403; upsl.com answers a Cloudflare challenge.  Wikipedia stands in:
--   'wikipedia_sports_table'  NPSL — the season article's conference tables (W D L GF GA, the
--                             article's own source being npsl.com)
--   'wikipedia_club_list'     UPSL — the league article's Premier Division and Division 1 club
--                             lists by conference: names only, there are no standings to read
-- Each box links to the article it is read from.  UPSL Division 1 sits under the Premier
-- Division (feeds_tables '=' = each of its conferences under the Premier conference of the
-- same name).  Division 2 ("will begin play in the fall of 2026") has no list yet.
-- Calendars as the owner gave them: UPSL fall–spring, NPSL summer.
ALTER TABLE pro_leagues DROP CONSTRAINT IF EXISTS pro_leagues_feed_system_check;
ALTER TABLE pro_leagues ADD CONSTRAINT pro_leagues_feed_system_check
  CHECK (feed_system IN ('espn', 'espn_teams', 'modular11', 'google_sheet', 'wikipedia_sports_table', 'wikipedia_club_list'));

INSERT INTO pro_leagues (tier, name, sort_order, feed_system, feed_locator, refresh_hours, calendar, website_url) VALUES
  (4, 'National Premier Soccer League', 3, 'wikipedia_sports_table', '2026 National Premier Soccer League season', 24, 'summer',
   'https://en.wikipedia.org/wiki/2026_National_Premier_Soccer_League_season'),
  (4, 'United Premier Soccer League', 4, 'wikipedia_club_list', 'United Premier Soccer League#Premier Division', 72, 'fifa',
   'https://en.wikipedia.org/wiki/United_Premier_Soccer_League')
ON CONFLICT (name) DO NOTHING;

INSERT INTO pro_leagues (tier, name, sort_order, feed_system, feed_locator, refresh_hours, feeds_league_id, feeds_tables, feed_kind, website_url)
SELECT 5, 'UPSL Division 1', 7, 'wikipedia_club_list', 'United Premier Soccer League#Division 1', 72, l.id, '=', 'promotion',
       'https://en.wikipedia.org/wiki/United_Premier_Soccer_League'
  FROM pro_leagues l WHERE l.name = 'United Premier Soccer League'
ON CONFLICT (name) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT m.category, 'A league''s clubs listed with no table ({n})', 'apsl_pyramid', 'club_list', NULL, '{n} clubs — no standings to read', m.sort_order + 4, true, true, m.is_public
  FROM message_templates m
 WHERE m.kind = 'apsl_pyramid' AND m.tier = 'path_pro_link'
   AND NOT EXISTS (SELECT 1 FROM message_templates x WHERE x.kind = 'apsl_pyramid' AND x.tier = 'club_list');
