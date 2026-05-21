-- Migration 039: Drop legacy flat boolean columns from players table
-- These were migrated to normalized tables in migration 038:
--   is_injured / is_suspended_league / is_suspended_inhouse -> player_availability
--   elig_* flags -> player_eligibilities
--   internal_role -> coach_assessments

ALTER TABLE players
    DROP COLUMN IF EXISTS internal_role,
    DROP COLUMN IF EXISTS is_injured,
    DROP COLUMN IF EXISTS is_suspended_league,
    DROP COLUMN IF EXISTS is_suspended_inhouse,
    DROP COLUMN IF EXISTS elig_apsl_starter,
    DROP COLUMN IF EXISTS elig_apsl_bench,
    DROP COLUMN IF EXISTS elig_liga1_starter,
    DROP COLUMN IF EXISTS elig_liga1_bench,
    DROP COLUMN IF EXISTS elig_liga2_starter,
    DROP COLUMN IF EXISTS elig_liga2_bench;
