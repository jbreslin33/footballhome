-- 097 — Add "pickup" variant + Men's Club Pickup Membership program (5070075).
--
-- Context (2026-07-06):
--   A new free-tier LA sub-program was created so that community members
--   who want to drop in on pickup soccer can register without paying dues.
--   URL: http://lighthouse1893.leagueapps.com/leagues/soccer-(outdoor)/5070075-mens-club-pickup-membership
--
-- Semantics (see backend/src/models/LaPool.cpp for the sync path):
--   active  → Practice pool team (908) + Pickup pool team (909) + specific
--             assigned team (APSL/Liga1/Liga2) if any
--   paused  → excluded from ALL pool teams (dormant, no notifications, no
--             RSVP surface).  Grows silently as the "on-file archive."
--   pickup  → Pickup pool team (909) ONLY.  Can RSVP to match_type_id=7
--             pickup events, cannot see Practice/Games.
--
-- Schema changes:
--   1. Extend the variant CHECK to allow 'pickup'.
--   2. Insert the new program row.
--   3. Add a nullable registration_url column so the frontend can deep-link
--      users into LA registration without hard-coding URLs in JS/HTML.

BEGIN;

-- 1. Extend variant CHECK to allow 'pickup' (in addition to active/paused).
ALTER TABLE leagueapps_programs
    DROP CONSTRAINT IF EXISTS leagueapps_programs_variant_check;
ALTER TABLE leagueapps_programs
    ADD CONSTRAINT leagueapps_programs_variant_check
        CHECK (variant IN ('active', 'paused', 'pickup'));

-- 2. Add registration_url so the "you must register" CTA on the FH My
--    Schedule screen can deep-link into LA without hard-coding the URL.
ALTER TABLE leagueapps_programs
    ADD COLUMN IF NOT EXISTS registration_url TEXT;

-- 3. Backfill registration_url for the existing active-variant programs
--    (paused programs are dormant, no CTA needed).  Idempotent: only
--    updates rows that are still NULL, so re-runs are safe and future
--    URL edits by hand are preserved.
UPDATE leagueapps_programs
   SET registration_url = 'http://lighthouse1893.leagueapps.com/leagues/soccer-(outdoor)/5039300-lighthouse-1893-men-s-club-soccer-membership'
 WHERE program_id = 5039300
   AND registration_url IS NULL;

-- 4. Insert the new pickup sub-program.  On conflict (program_id) update
--    the URL/name so re-running the migration keeps them current.
INSERT INTO leagueapps_programs (category, variant, program_id, program_name, registration_url)
VALUES ('men', 'pickup', 5070075, 'Men''s Club Pickup Membership',
        'http://lighthouse1893.leagueapps.com/leagues/soccer-(outdoor)/5070075-mens-club-pickup-membership')
ON CONFLICT (program_id) DO UPDATE
    SET program_name     = EXCLUDED.program_name,
        registration_url = EXCLUDED.registration_url,
        updated_at       = NOW();

COMMIT;
