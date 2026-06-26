-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 069: Audit columns — updated_at on persons/teams/users
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- - persons + users already have updated_at columns, but no trigger
--   maintains them.
-- - teams is missing the column entirely.
--
-- Adds:
--   1. A generic set_updated_at() trigger function.
--   2. teams.updated_at column (backfilled to created_at).
--   3. BEFORE UPDATE triggers on persons, teams, users.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

-- Generic trigger function (idempotent)
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- teams: add updated_at column, backfill, default
ALTER TABLE teams ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ;
UPDATE teams SET updated_at = COALESCE(created_at, NOW()) WHERE updated_at IS NULL;
ALTER TABLE teams ALTER COLUMN updated_at SET DEFAULT NOW();
ALTER TABLE teams ALTER COLUMN updated_at SET NOT NULL;

-- Triggers (drop-then-create so re-run is safe)
DROP TRIGGER IF EXISTS trg_persons_set_updated_at ON persons;
CREATE TRIGGER trg_persons_set_updated_at
    BEFORE UPDATE ON persons
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_teams_set_updated_at ON teams;
CREATE TRIGGER trg_teams_set_updated_at
    BEFORE UPDATE ON teams
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_users_set_updated_at ON users;
CREATE TRIGGER trg_users_set_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

COMMIT;
