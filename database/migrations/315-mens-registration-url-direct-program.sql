-- 315 — Point the Men's registration link at the program page, not the
-- league page that lists Membership AND Pickup side by side.
--
-- Why (2026-08-26, owner: "dude the mens text more info is sending people
-- to members and pickup reg page! all leads links email and text for all
-- programs must go directly to proper member reg for men or women or boys
-- or girls. we are losing players!").
--
-- Migration 291 set this row to the id 5039296 on the stated belief that
-- Men's active membership "has a DIFFERENT public checkout id (5039296)
-- than the LA-internal admin/API league id (5039300)". The internal-vs-
-- API half of that is right and is untouched here — program_id stays
-- 5039300 everywhere, which is what LaPool / MensRoster /
-- PaymentsController / TeamReconciliation match payments and roster sync
-- against. What was wrong is which page each id serves. Loaded in a real
-- browser 2026-08-26:
--
--   .../5039296-lighthouse-mens-club-1893-soccer-membership
--       → the LEAGUE page: a sport/season/day filter form above a LIST of
--         programs, each with its own Register button —
--           • Lighthouse Men's Club 1893 Soccer Membership   [Register]
--           • Lighthouse Men's Club 1893 Pickup Soccer …     [Register]
--         A man arriving from a recruiting email is one click from
--         registering as a Pickup member instead of a Club member. That
--         is the reported bug, and it is also how a lead ends up in the
--         wrong programme entirely (cf. person 22546, registered Pickup
--         on 2026-08-07 when the parent meant to join the club).
--
--   .../5039300-lighthouse-mens-club-1893-soccer-membership
--       → the PROGRAM page: one title, one Register button, $1.00,
--         "Return to Lighthouse Mens Club 1893 Soccer Membership" linking
--         back up to the league page. This is the shape boys (5039252),
--         girls (5039357) and women (5039340) already have — all three
--         verified the same way on the same day, all three correct, all
--         three using the id that equals their program_id.
--
-- So men was the one category whose URL id disagreed with its program_id,
-- and that disagreement is exactly what made it the one category pointing
-- at a chooser instead of a checkout. Aligning it makes all four
-- consistent: registration_url is always the program page for
-- program_id.
--
-- Scoped by program_id and by the wrong URL, so it cannot fire twice and
-- cannot touch a row someone has since corrected by hand.
BEGIN;

UPDATE leagueapps_programs
   SET registration_url = 'https://lighthouse1893.leagueapps.com/leagues/soccer-(outdoor)/5039300-lighthouse-mens-club-1893-soccer-membership',
       updated_at       = NOW()
 WHERE program_id = 5039300
   AND registration_url LIKE '%5039296-lighthouse-mens-club-1893-soccer-membership%';

-- Guard 1: the men's active row now points at its own program id.
DO $$
DECLARE u TEXT;
BEGIN
    SELECT registration_url INTO u
      FROM leagueapps_programs
     WHERE category = 'men' AND variant = 'active';
    IF u IS NULL OR u NOT LIKE '%/5039300-%' THEN
        RAISE EXCEPTION 'men/active registration_url is not the 5039300 program page: %', u;
    END IF;
END $$;

-- Guard 2: the invariant this migration establishes — every registerable
-- programme's URL contains its own program_id. A future row that repeats
-- the 291 mistake fails here instead of quietly sending leads to a
-- chooser page. Inactive rows hold NULL by design and are exempt.
DO $$
DECLARE bad TEXT;
BEGIN
    SELECT string_agg(category || '/' || variant || ' → ' || registration_url, '; ') INTO bad
      FROM leagueapps_programs
     WHERE registration_url IS NOT NULL
       AND registration_url NOT LIKE '%/' || program_id::text || '-%';
    IF bad IS NOT NULL THEN
        RAISE EXCEPTION 'registration_url does not contain its own program_id: %', bad;
    END IF;
END $$;

-- Guard 3: no lead-facing link may point at a pickup programme. Members
-- and Pickup are separate registrations and nobody should hold both, so
-- an 'active' row advertising the pickup checkout would recreate the same
-- loss in the opposite direction.
DO $$
DECLARE bad TEXT;
BEGIN
    SELECT string_agg(category, ', ') INTO bad
      FROM leagueapps_programs
     WHERE variant = 'active' AND registration_url ILIKE '%pickup%';
    IF bad IS NOT NULL THEN
        RAISE EXCEPTION 'active registration_url points at a pickup programme: %', bad;
    END IF;
END $$;

COMMIT;
