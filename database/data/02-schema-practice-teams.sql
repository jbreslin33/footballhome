-- ========================================
-- PRACTICE TEAMS JUNCTION TABLE
-- ========================================
-- Allows a single practice to be assigned to multiple teams
-- (e.g. "Club Wide Training" applies to Lighthouse, Boys Club, and Old Timers)

CREATE TABLE IF NOT EXISTS practice_teams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    practice_id UUID NOT NULL REFERENCES practices(id) ON DELETE CASCADE,
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    is_primary BOOLEAN DEFAULT false, -- The "owning" team (usually from practices.team_id)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(practice_id, team_id)
);

CREATE INDEX idx_practice_teams_practice ON practice_teams(practice_id);
CREATE INDEX idx_practice_teams_team ON practice_teams(team_id);

-- Trigger to automatically populate practice_teams from practices.team_id
-- This ensures backward compatibility and data integrity
CREATE OR REPLACE FUNCTION sync_practice_teams()
RETURNS TRIGGER AS $$
BEGIN
    -- On INSERT, add the primary team to practice_teams
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO practice_teams (practice_id, team_id, is_primary)
        VALUES (NEW.id, NEW.team_id, true)
        ON CONFLICT (practice_id, team_id) DO NOTHING;
    
    -- On UPDATE of team_id, update the primary entry in practice_teams
    ELSIF (TG_OP = 'UPDATE' AND OLD.team_id != NEW.team_id) THEN
        -- Remove old primary
        DELETE FROM practice_teams 
        WHERE practice_id = OLD.id AND team_id = OLD.team_id AND is_primary = true;
        
        -- Add new primary
        INSERT INTO practice_teams (practice_id, team_id, is_primary)
        VALUES (NEW.id, NEW.team_id, true)
        ON CONFLICT (practice_id, team_id) 
        DO UPDATE SET is_primary = true;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_sync_practice_teams ON practices;
CREATE TRIGGER trg_sync_practice_teams
AFTER INSERT OR UPDATE OF team_id ON practices
FOR EACH ROW
EXECUTE FUNCTION sync_practice_teams();

-- Backfill existing practices
INSERT INTO practice_teams (practice_id, team_id, is_primary)
SELECT id, team_id, true
FROM practices
ON CONFLICT DO NOTHING;
