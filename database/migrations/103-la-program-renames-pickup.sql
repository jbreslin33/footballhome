-- 2026-07-07 — LA program renames + paused→pickup restructuring
--
-- On LA admin, the four "Paused Membership" sub-programs were retired:
--   • Men's paused (5064676) was DELETED on LA (mens pickup 5070075 already existed).
--   • Boys, Girls, and Women's "paused" programs were RENAMED to "Pickup" —
--     same program IDs, new purpose (pay-per-session tier that grants only the
--     Pickup pool team, not the full mens/boys/girls/womens Full roster).
--
-- Cosmetic name changes on the four "active" programs shift the year to
-- after "Club": "Lighthouse [Gender] Club [YEAR] Soccer Membership".
--
-- Womens founding year corrected 1893 → 1895 (LA is source of truth).
--
-- The 12 person_la_memberships rows currently pointing at 5064676 are
-- ended here so we can drop the leagueapps_programs row. All 12 people
-- are already registered on Mens Pickup (5070075) on the LA side —
-- the nightly LaPool sync will re-add them on the pickup program.

BEGIN;

-- 1. Delete all person_la_memberships rows referencing the retired mens paused
--    program (12 rows, all still active — no historical rows exist). The FK
--    prevents deleting the program while any row references it. Losing the
--    "paused" audit trail is acceptable here: all 12 people are already
--    registered on Mens Pickup (5070075) on the LA side, and the nightly
--    LaPool sync will re-add fresh pickup rows on its next run.
DELETE FROM person_la_memberships WHERE la_program_id = 5064676;

-- 2. Delete the retired mens paused program.
DELETE FROM leagueapps_programs WHERE program_id = 5064676;

-- 3. Rename the four "active" programs to match LA's new naming.
UPDATE leagueapps_programs SET program_name = 'Lighthouse Men''s Club 1893 Soccer Membership',    updated_at = NOW() WHERE program_id = 5039300;
UPDATE leagueapps_programs SET program_name = 'Lighthouse Boys Club 1897 Soccer Membership',      updated_at = NOW() WHERE program_id = 5039252;
UPDATE leagueapps_programs SET program_name = 'Lighthouse Girl''s Club 1898 Soccer Membership',   updated_at = NOW() WHERE program_id = 5039357;
UPDATE leagueapps_programs SET program_name = 'Lighthouse Women''s Club 1895 Soccer Membership',  updated_at = NOW() WHERE program_id = 5039340;

-- 4. Rename the mens pickup program.
UPDATE leagueapps_programs SET program_name = 'Lighthouse Men''s Club 1893 Pickup Soccer Membership', updated_at = NOW() WHERE program_id = 5070075;

-- 5. Flip boys/girls/womens paused → pickup (same program_id, new variant + name).
UPDATE leagueapps_programs
   SET variant = 'pickup',
       program_name = 'Lighthouse Boys Club 1897 Pickup Soccer Membership',
       updated_at = NOW()
 WHERE program_id = 5064618;

UPDATE leagueapps_programs
   SET variant = 'pickup',
       program_name = 'Lighthouse Girl''s Club 1898 Pickup Soccer Membership',
       updated_at = NOW()
 WHERE program_id = 5064662;

UPDATE leagueapps_programs
   SET variant = 'pickup',
       program_name = 'Lighthouse Women''s Club 1895 Pickup Soccer Membership',
       updated_at = NOW()
 WHERE program_id = 5064686;

COMMIT;
