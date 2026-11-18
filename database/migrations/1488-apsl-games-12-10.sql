-- 1488 (2026-11-18) — APSL this year is 12 fall + 10 spring after all (owner:
-- "technically this year yes apsl was 12,10 instead of 11,11 so you can do
-- 12,10").  Undoes the APSL half of mig 1486; Liga 1 stays 11 + 11.
BEGIN;
UPDATE ref_fee_seasons SET home_games_expected = 12 WHERE id = 14 AND policy_id = 7;   -- APSL Fall 2026
UPDATE ref_fee_seasons SET home_games_expected = 10 WHERE id = 15 AND policy_id = 7;   -- APSL Spring 2027
COMMIT;
