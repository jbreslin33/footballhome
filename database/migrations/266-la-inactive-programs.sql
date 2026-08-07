-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 266: leagueapps_programs 'inactive' variant
--
-- Owner directive 2026-08-07: on the 1st-Friday-of-month billing run,
-- members who hit 2 months unpaid get moved in LA from the category's
-- "members" (active) sub-program into a brand new "inactive" sub-program
-- (mirrors the existing members/pickup split — LA console confirms each
-- of men/women/boys/girls now has exactly 3 sub-programs: members,
-- inactive, pickup). They still need to show on the FH payments screen
-- (separate top section) so ops can monitor for reactivation, but must
-- disappear from rosters/pool/RSVP — same treatment the old 'paused'
-- variant was built for (see migration 076 + LaPool.cpp §3a).
--
-- Only men's (5093107) and women's (5114228) inactive program ids are
-- confirmed so far. Boys vs girls is still ambiguous — one URL
-- (5114231) was given for both and needs disambiguating before it can
-- be inserted; do NOT guess, a wrong category here misfiles real
-- members. Add boys/girls in a follow-up migration once confirmed.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

ALTER TABLE leagueapps_programs
    DROP CONSTRAINT IF EXISTS leagueapps_programs_variant_check;
ALTER TABLE leagueapps_programs
    ADD CONSTRAINT leagueapps_programs_variant_check
        CHECK (variant IN ('active', 'paused', 'pickup', 'inactive'));

INSERT INTO leagueapps_programs (category, variant, program_id, program_name) VALUES
    ('men',   'inactive', 5093107, 'Lighthouse Men''s Club Inactive Membership'),
    ('women', 'inactive', 5114228, 'Lighthouse Women''s Club Inactive Membership')
ON CONFLICT (program_id) DO UPDATE
    SET category     = EXCLUDED.category,
        variant       = EXCLUDED.variant,
        program_name  = EXCLUDED.program_name,
        updated_at    = NOW();

COMMIT;
