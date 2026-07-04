-- LeagueApps sub-program registry
--
-- Historically the four sub-programs under the "Membership" umbrella
-- league (5039296) were hard-coded in the C++ backend (Boys=5039252,
-- Girls=5039357, Men's=5039300).  Now that LA supports parallel
-- "Paused Membership" sub-programs (used to freeze billing + play
-- eligibility while keeping the person on file), we want the linker
-- and the leads-suppression pipeline to sweep BOTH the active and
-- the paused sub-program for every category, without another code
-- change every time a new sub-program is added.
--
-- Rule (user directive 2026-07-01): presence in ANY row of ANY
-- sub-program listed here = member.  Do NOT filter by
-- registrationStatus (SPOT_RESERVED / SPOT_PENDING / WAITING_LIST /
-- free-agent all count).  Paused rows are members too — they just
-- shouldn't get billed or cold-emailed.
--
-- category  : 'men' | 'women' | 'boys' | 'girls'  (drives which
--             members-card bucket the row shows up in)
-- variant   : 'active' | 'paused'                 (billing/play flag)
-- program_id: LA program-id used with
--             /v2/sites/{site}/export/registrations-2?program-id=X

CREATE TABLE IF NOT EXISTS leagueapps_programs (
    id          SERIAL PRIMARY KEY,
    category    TEXT NOT NULL CHECK (category IN ('men', 'women', 'boys', 'girls')),
    variant     TEXT NOT NULL CHECK (variant IN ('active', 'paused')),
    program_id  BIGINT NOT NULL UNIQUE,
    program_name TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (category, variant)
);

CREATE INDEX IF NOT EXISTS idx_leagueapps_programs_category
    ON leagueapps_programs (category, variant);

-- Seed with the six sub-programs as of 2026-07-01.  Idempotent on
-- program_id so re-runs are safe and program renames get picked up.

INSERT INTO leagueapps_programs (category, variant, program_id, program_name) VALUES
    ('men',   'active', 5039300, 'Lighthouse 1893 Men''s Club Soccer Membership'),
    ('men',   'paused', 5064676, 'Men''s Club Paused Membership'),
    ('boys',  'active', 5039252, 'Lighthouse 1897 Boys Club Soccer Membership'),
    ('boys',  'paused', 5064618, 'Boys Club Paused Membership'),
    ('girls', 'active', 5039357, 'Lighthouse 1898 Girl''s Club Soccer Membership'),
    ('girls', 'paused', 5064662, 'Girls Club Paused Membership')
ON CONFLICT (program_id) DO UPDATE
    SET program_name = EXCLUDED.program_name,
        updated_at   = NOW();
