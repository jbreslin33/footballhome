-- 273-medford-ethiopia-opponent-aliases.sql (2026-08-11)
--
-- Two upcoming Sunday (2026-08-16) matches whose gcal Opponent: text
-- doesn't exact-match a teams.name row, so they were falling through to
-- the Lighthouse crest on #my and on generated social graphics
-- (game_day / lineup / post_game — see SocialPostCard.js and
-- content-posts.js, all of which read opponent_logo_url from
-- CalendarController's gcal_opponent_aliases join, same pipeline
-- migration 258 set up):
--
--   "Medford Strikers APSL" (gcal) vs teams.name "Medford Strikers"
--   (id 37, already has a real APSL-scraped logo_url) — alias only.
--
--   "Ethiopa" (gcal, as typed) — an adult-league pickup opponent with
--   no scraped team row at all (same pattern as the "Germany" row,
--   id 907, under the Lighthouse Adult League division). Flag is public
--   domain (national flags aren't copyrightable); PNG pulled from
--   Wikimedia Commons and stored locally at frontend/images/flags/et.png
--   rather than hotlinked.

BEGIN;

INSERT INTO teams (name, division_id, kind, logo_url, slug, is_active, is_pool, roster_source)
VALUES ('Ethiopia', 73, 'official', '/images/flags/et.png', 'ethiopia', true, false, 'direct')
ON CONFLICT (slug) DO NOTHING;

INSERT INTO gcal_opponent_aliases (alias, team_id, notes)
SELECT 'Medford Strikers APSL', 37, 'Medford Strikers — APSL, confirmed 2026-08-11'
WHERE NOT EXISTS (SELECT 1 FROM gcal_opponent_aliases WHERE alias = 'Medford Strikers APSL')
ON CONFLICT (alias) DO NOTHING;

INSERT INTO gcal_opponent_aliases (alias, team_id, notes)
SELECT 'Ethiopa', t.id, 'Lighthouse Adult League opponent, as typed in gcal (missing the second "i")'
FROM teams t WHERE t.slug = 'ethiopia'
ON CONFLICT (alias) DO NOTHING;

COMMIT;
