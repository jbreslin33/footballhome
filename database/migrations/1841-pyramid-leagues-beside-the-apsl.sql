-- 1841 (2026-11-24) — 🔺 #apsl-pyramid: the national leagues beside the APSL.
--
-- Owner: "we need to add some leagues that will be at same level as apsl. and can be toggled
-- on and off. they would go into the pls too they would be 4th div … usl2, upsl, casa u23,
-- league for clubs. you would have to find these league standings if they are not accessble
-- then they don't get a spot" · "dont' get ip banned lol use vpn" · "use oop like we do for
-- apsl and casa for these other league so they can extend".
--
-- They live in pro_leagues beside the divisions above (the table is "a league drawn around
-- the pyramid, and where its table is read"), on a tier of their own:
--   pro_league_tiers.beside_pyramid  true = drawn level with the APSL's conferences, tied
--                                    into the standards box above like them; each league
--                                    is a switch under ☰ Show on screen.
-- Readers (backend/src/services/LeagueTableReaders.*, one class per source):
--   'modular11'     USL League Two — modular11.com, a table per division, through the VPN proxy
--   'google_sheet'  The League for Clubs — the public Google Sheet its site draws from
-- No spot: UPSL (upsl.com answers a Cloudflare challenge — never worked round).
-- Not yet: CASA U23 (its table has not been found).
ALTER TABLE pro_league_tiers ADD COLUMN IF NOT EXISTS beside_pyramid boolean NOT NULL DEFAULT false;

ALTER TABLE pro_leagues DROP CONSTRAINT IF EXISTS pro_leagues_feed_system_check;
ALTER TABLE pro_leagues ADD CONSTRAINT pro_leagues_feed_system_check
  CHECK (feed_system IN ('espn', 'espn_teams', 'modular11', 'google_sheet'));

INSERT INTO pro_league_tiers (tier, label, by_standards, beside_pyramid)
VALUES (4, 'National league — level with the APSL', false, true)
ON CONFLICT (tier) DO NOTHING;

INSERT INTO pro_leagues (tier, name, sort_order, feed_system, feed_locator, refresh_hours) VALUES
  (4, 'USL League Two',       1, 'modular11',    'league-two', 24),
  (4, 'The League for Clubs', 2, 'google_sheet', '1yIRp-XbW9ZEVOO2djinmr0VymjElVGijoVpXkxWByfI/Standings', 24)
ON CONFLICT (name) DO NOTHING;
