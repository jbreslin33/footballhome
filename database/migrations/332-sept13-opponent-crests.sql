-- Opponent crests for the 9/13 slate (owner-supplied images, 2026-09-05):
-- Roxborough United (U12), Fishtown (U10), Feels Good FC (APSL), Sierra
-- Stars (Liga 1).  Seeded in opponent_logo_cache keyed by the Opponent:
-- text plus the obvious spellings, source='manual', same as KSC in 328.
--
-- Sierra Stars deliberately NOT aliased to teams 467/490 ("Philadelphia
-- Sierra Stars", scraped): both rows carry philly-soccer-club.png, which
-- is Philadelphia SC's badge, not theirs.  The cache row wins nothing
-- over an alias in CalendarController's COALESCE, so an alias would have
-- shown the wrong crest.
INSERT INTO opponent_logo_cache (opponent_text, logo_url, source, fetched_at) VALUES
  ('Roxborough United',         '/images/teams/logos/roxborough-united.png', 'manual', now()),
  ('SC Roxborough United',      '/images/teams/logos/roxborough-united.png', 'manual', now()),
  ('Roxborough',                '/images/teams/logos/roxborough-united.png', 'manual', now()),
  ('Fishtown',                  '/images/teams/logos/fishtown.png',          'manual', now()),
  ('Fishtown AC',               '/images/teams/logos/fishtown.png',          'manual', now()),
  ('Fishtown A.C.',             '/images/teams/logos/fishtown.png',          'manual', now()),
  ('Feels Good FC',             '/images/teams/logos/feels-good-fc.png',     'manual', now()),
  ('FeelsGood FC',              '/images/teams/logos/feels-good-fc.png',     'manual', now()),
  ('Feelsgood',                 '/images/teams/logos/feels-good-fc.png',     'manual', now()),
  ('Sierra Stars',              '/images/teams/logos/sierra-stars.png',      'manual', now()),
  ('Philadelphia Sierra Stars', '/images/teams/logos/sierra-stars.png',      'manual', now())
ON CONFLICT (lower(btrim(opponent_text))) DO UPDATE
   SET logo_url = EXCLUDED.logo_url, source = 'manual', fetched_at = now();
