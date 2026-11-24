-- 1839 (2026-11-24) — 🔺 #apsl-pyramid: the clubs in the Concacaf Champions Cup.
-- Owner: "show champtions cup clubs right?" · "actually show current if we are in between right?".
--
-- A knockout cup has no table.  feed_system 'espn_teams' = the feed's team list for the
-- season in play (site.api.espn.com/apis/site/v2/sports/soccer/<locator>/teams): PyramidSync
-- keeps it as one table named after the season, the clubs with no figures, and /api/pyramid
-- marks the league field: true so the page lists names only.  Between editions the feed
-- still answers the last one played — the current field.
ALTER TABLE pro_leagues DROP CONSTRAINT IF EXISTS pro_leagues_feed_system_check;
ALTER TABLE pro_leagues ADD CONSTRAINT pro_leagues_feed_system_check CHECK (feed_system IN ('espn', 'espn_teams'));

UPDATE pro_leagues SET feed_system = 'espn_teams', feed_locator = 'concacaf.champions', refresh_hours = 24
 WHERE name = 'Concacaf Champions Cup';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT m.category, 'Pathway — a cup''s field heading ({season} {n})', 'apsl_pyramid', 'pro_field', NULL, '{season} field — {n} clubs', m.sort_order + 1, true, true, m.is_public
  FROM message_templates m
 WHERE m.kind = 'apsl_pyramid' AND m.tier = 'path_pro_link'
   AND NOT EXISTS (SELECT 1 FROM message_templates x WHERE x.kind = 'apsl_pyramid' AND x.tier = 'pro_field');
