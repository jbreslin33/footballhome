-- 1844 (2026-11-24) — 🔺 #apsl-pyramid: the regional leagues under The League for Clubs, and
-- the national leagues' divisions in one row.
--
-- Owner: "usl2 and league for clubs should go linear across as they are all their 1st
-- divsions. usl2 has no feeders. leaguje for clubs has some if you can find them".
--
-- Found on the league's own site (theleaguefc.com, read 2026-11-24):
--   • FAQ: in Northern California "the bottom clubs drop to NorCal Division 2, which starts
--     in 2026 … promotion and relegation will be in full effect" → kind 'promotion', under
--     the NorCal table.
--   • FAQ: the South Region's Gulf Coast conference "was created in partnership with the Gulf
--     Coast Premier League" → kind 'partner', under the Gulf Coast tables.
--   • Its partner-league strip also names the Metroplex, Mountain, Midwest and Upstate
--     Premier Leagues → kind 'partner', no conference named (the site hopes "to institute
--     promotion from some regional leagues … in the future" — not in force).
-- None of their tables is mirrored yet: they are named, with a link, no feed.
--
-- pro_leagues.feeds_league_id  the league this one sits under
-- pro_leagues.feeds_tables     the upper league's table(s) it sits under — a name fragment
--                              ('Gulf Coast' = Gulf Coast East + West); NULL = none named
-- pro_leagues.feed_kind        how it is tied (pro_league_feed_kinds)
CREATE TABLE IF NOT EXISTS pro_league_feed_kinds (
    code  text PRIMARY KEY,
    label text NOT NULL
);
INSERT INTO pro_league_feed_kinds (code, label) VALUES
    ('promotion', 'Promotion and relegation'),
    ('partner',   'Partner league — no promotion yet')
ON CONFLICT (code) DO NOTHING;

ALTER TABLE pro_leagues ADD COLUMN IF NOT EXISTS feeds_league_id integer REFERENCES pro_leagues(id) ON DELETE CASCADE;
ALTER TABLE pro_leagues ADD COLUMN IF NOT EXISTS feeds_tables text;
ALTER TABLE pro_leagues ADD COLUMN IF NOT EXISTS feed_kind text REFERENCES pro_league_feed_kinds(code);
ALTER TABLE pro_leagues ADD COLUMN IF NOT EXISTS website_url text;
ALTER TABLE pro_leagues DROP CONSTRAINT IF EXISTS pro_leagues_feeder_check;
ALTER TABLE pro_leagues ADD CONSTRAINT pro_leagues_feeder_check CHECK ((feeds_league_id IS NULL) = (feed_kind IS NULL));

INSERT INTO pro_league_tiers (tier, label, by_standards, beside_pyramid)
VALUES (5, 'Regional league', false, true)
ON CONFLICT (tier) DO NOTHING;

UPDATE pro_leagues SET website_url = 'https://www.theleaguefc.com/' WHERE name = 'The League for Clubs' AND website_url IS NULL;
UPDATE pro_leagues SET website_url = 'https://www.uslleaguetwo.com/' WHERE name = 'USL League Two' AND website_url IS NULL;

INSERT INTO pro_leagues (tier, name, sort_order, feeds_league_id, feeds_tables, feed_kind, website_url)
SELECT 5, v.name, v.ord, l.id, v.tables, v.kind, v.url
  FROM pro_leagues l
  JOIN (VALUES
    ('NorCal Division 2',          1, 'NorCal',     'promotion', NULL),
    ('Gulf Coast Premier League',  2, 'Gulf Coast', 'partner',   'https://gcplsoccer.com/'),
    ('Metroplex Premier League',   3, NULL,         'partner',   'https://www.mplsoccer.com/'),
    ('Mountain Premier League',    4, NULL,         'partner',   'https://mountainpl.com/'),
    ('Midwest Premier League',     5, NULL,         'partner',   'https://www.midwestpl.com/'),
    ('Upstate Premier League',     6, NULL,         'partner',   'https://www.uplny.com/')
  ) AS v(name, ord, tables, kind, url) ON true
 WHERE l.name = 'The League for Clubs'
ON CONFLICT (name) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT m.category, v.label, 'apsl_pyramid', v.tier, NULL, v.body, m.sort_order + v.n, true, true, m.is_public
  FROM message_templates m
  JOIN (VALUES
    (2, 'A regional league under a national one: not mirrored', 'feeder_no_table', 'Table not mirrored yet'),
    (3, 'Heading over a league''s partner leagues with no conference named', 'feeder_partners', 'Partner regional leagues')
  ) AS v(n, label, tier, body) ON true
 WHERE m.kind = 'apsl_pyramid' AND m.tier = 'path_pro_link'
   AND NOT EXISTS (SELECT 1 FROM message_templates x WHERE x.kind = 'apsl_pyramid' AND x.tier = v.tier);

-- One switch for all of them (owner: "put a button that says show non apsl open pyramind.
-- like we have for show pro"): ☰ Show on screen → Non-APSL open pyramid; each league keeps
-- its own switch beneath it.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT m.category, 'Show on screen: the national leagues beside the APSL', 'apsl_pyramid', 'feature_open', NULL, 'Non-APSL open pyramid', m.sort_order + 1, true, true, m.is_public
  FROM message_templates m
 WHERE m.kind = 'apsl_pyramid' AND m.tier = 'feature_pro'
   AND NOT EXISTS (SELECT 1 FROM message_templates x WHERE x.kind = 'apsl_pyramid' AND x.tier = 'feature_open');
