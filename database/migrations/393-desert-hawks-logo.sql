-- 393 — Desert Hawks FC crest.
--
-- Owner 2026-09-21: "desert hawks logo" + the club's profile image.
-- The cache held an auto-fetched thesportsdb badge for a different
-- "Desert Hawks"; replace it with the real crest, same as 389: a local
-- copy (frontend/images/teams/logos/, white surround cut away, cropped
-- to the crest) keyed on fh_events.opponent, source 'manual' so the
-- fetcher leaves it alone.
INSERT INTO opponent_logo_cache (opponent_text, logo_url, source)
VALUES ('Desert Hawks', '/images/teams/logos/desert-hawks.png', 'manual')
ON CONFLICT (lower(btrim(opponent_text)))
DO UPDATE SET logo_url = EXCLUDED.logo_url, source = EXCLUDED.source, fetched_at = now();
