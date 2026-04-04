-- ============================================================================
-- 011: League Logo URLs on source_systems + organizations
-- ============================================================================
-- Adds logo_url to source_systems table and populates APSL/CASA logo paths.
-- Also updates the organizations table with the same logo paths.
-- ============================================================================

-- Add logo_url column to source_systems if it doesn't exist
ALTER TABLE source_systems ADD COLUMN IF NOT EXISTS logo_url TEXT;

-- Set league logo paths (served from frontend/images/leagues/)
UPDATE source_systems SET logo_url = '/images/leagues/apsl.png' WHERE name = 'apsl';
UPDATE source_systems SET logo_url = '/images/leagues/casa.png' WHERE name = 'casa';

-- Also update organizations table
UPDATE organizations SET logo_url = '/images/leagues/apsl.png' WHERE short_name = 'APSL';
UPDATE organizations SET logo_url = '/images/leagues/casa.png' WHERE short_name = 'CASA';
