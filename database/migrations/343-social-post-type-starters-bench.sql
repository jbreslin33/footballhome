-- social_post_types row 1: pre_match_announcement → starters_bench
-- (Game Center slice E, owner plan 2026-08-28; landed 2026-09-07).
--
-- The row was seeded in migration 010 as a generic "Pre-Match
-- Announcement". Game Center repurposed it as the Starters & Bench pill
-- (the team-sheet post) and every screen has been relabelling it in JS
-- ever since. Rename the wire value so the code reads the way the club
-- talks, and let display_name be the one place the wording lives —
-- game-center.js and SocialPostCard.js now read it from
-- GET /api/social/post-types instead of hardcoded label maps.
--
-- Posts reference the type by id, so the 5 existing starters/bench
-- posts and the per-team posting schedules are untouched.
BEGIN;
UPDATE social_post_types
   SET name         = 'starters_bench',
       display_name = 'Starters & Bench',
       description  = 'Starting XI and bench reveal — the team sheet post'
 WHERE name = 'pre_match_announcement';

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM social_post_types WHERE name = 'starters_bench') THEN
        RAISE EXCEPTION 'starters_bench post type missing after rename';
    END IF;
    IF EXISTS (SELECT 1 FROM social_post_types WHERE name = 'pre_match_announcement') THEN
        RAISE EXCEPTION 'pre_match_announcement still present';
    END IF;
END $$;
COMMIT;
