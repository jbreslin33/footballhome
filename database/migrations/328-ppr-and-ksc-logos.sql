-- PPR league crest + Kensington Soccer Club opponent crest (owner 2026-09-05).
--
-- Owner supplied both images for the U8 Travel vs KSC game on 9/13 (PPR):
--   * Philadelphia Parks & Recreation Soccer — organizations.id=6 already
--     carried /images/leagues/phila-parks-rec.jpg (migration 298); the new
--     400x400 crest is saved alongside as .png and the org repointed.
--   * Kensington Soccer Club — no teams/clubs row exists, so the crest goes
--     in opponent_logo_cache (migration 289) keyed by the exact Opponent:
--     text.  Seeding it here also stops CalendarController's one-time
--     TheSportsDb lookup from firing for these strings.  Three spellings so
--     whichever the gcal description uses resolves.
-- Idempotent.
UPDATE organizations
   SET logo_url = '/images/leagues/phila-parks-rec.png'
 WHERE id = 6
   AND logo_url IS DISTINCT FROM '/images/leagues/phila-parks-rec.png';

INSERT INTO opponent_logo_cache (opponent_text, logo_url, source, fetched_at)
VALUES ('KSC',                    '/images/teams/logos/kensington-soccer-club.png', 'manual', now()),
       ('Kensington Soccer Club', '/images/teams/logos/kensington-soccer-club.png', 'manual', now()),
       ('Kensington SC',          '/images/teams/logos/kensington-soccer-club.png', 'manual', now())
ON CONFLICT (lower(btrim(opponent_text))) DO UPDATE
   SET logo_url = EXCLUDED.logo_url, source = 'manual', fetched_at = now();
