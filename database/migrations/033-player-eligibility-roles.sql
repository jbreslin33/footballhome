-- Replace single internal_role with 6 boolean eligibility columns
-- A player can now be eligible for multiple leagues/tiers simultaneously

ALTER TABLE players
  ADD COLUMN IF NOT EXISTS elig_apsl_starter  BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS elig_apsl_bench    BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS elig_liga1_starter BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS elig_liga1_bench   BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS elig_liga2_starter BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS elig_liga2_bench   BOOLEAN NOT NULL DEFAULT false;

-- Migrate existing internal_role data
UPDATE players SET elig_apsl_starter  = true WHERE internal_role = 'apsl_starter';
UPDATE players SET elig_apsl_bench    = true WHERE internal_role = 'apsl_bench';
UPDATE players SET elig_liga1_starter = true WHERE internal_role = 'liga1_starter';
UPDATE players SET elig_liga1_bench   = true WHERE internal_role = 'liga1_bench';
UPDATE players SET elig_liga2_starter = true WHERE internal_role = 'liga2_starter';
UPDATE players SET elig_liga2_bench   = true WHERE internal_role = 'liga2_bench';
