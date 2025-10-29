-- Migration 002: Normalize home_away field in events table
-- This replaces the CHECK constraint with a proper lookup table

-- Create home_away_status lookup table
CREATE TABLE home_away_statuses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(20) UNIQUE NOT NULL,          -- 'home', 'away', 'neutral'
    display_name VARCHAR(50) NOT NULL,         -- 'Home', 'Away', 'Neutral Venue'
    description TEXT,                          -- Additional context
    sort_order INTEGER DEFAULT 0,             -- For display ordering
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert standard home/away statuses
INSERT INTO home_away_statuses (id, name, display_name, description, sort_order) VALUES 
('550e8400-e29b-41d4-a716-446655440801', 'home', 'Home', 'Event at our home venue', 1),
('550e8400-e29b-41d4-a716-446655440802', 'away', 'Away', 'Event at opponent or external venue', 2),
('550e8400-e29b-41d4-a716-446655440803', 'neutral', 'Neutral Venue', 'Event at a neutral/shared venue', 3);

-- Add new foreign key column to events table (allowing NULL for backwards compatibility)
ALTER TABLE events 
ADD COLUMN home_away_status_id UUID REFERENCES home_away_statuses(id);

-- Migrate existing data (cast text to UUID)
UPDATE events 
SET home_away_status_id = (
    CASE 
        WHEN home_away = 'home' THEN '550e8400-e29b-41d4-a716-446655440801'::UUID
        WHEN home_away = 'away' THEN '550e8400-e29b-41d4-a716-446655440802'::UUID
        ELSE '550e8400-e29b-41d4-a716-446655440801'::UUID  -- Default to 'home' for NULL values
    END
);

-- Drop the old CHECK constraint and column (in separate steps for safety)
ALTER TABLE events DROP CONSTRAINT IF EXISTS events_home_away_check;
ALTER TABLE events DROP COLUMN IF EXISTS home_away;

-- Add index for performance
CREATE INDEX idx_events_home_away_status ON events(home_away_status_id);

-- Make the new column NOT NULL now that data is migrated
ALTER TABLE events 
ALTER COLUMN home_away_status_id SET NOT NULL;

-- Add comment for documentation
COMMENT ON TABLE home_away_statuses IS 'Lookup table for event venue status (home/away/neutral) replacing CHECK constraint';
COMMENT ON COLUMN events.home_away_status_id IS 'References home_away_statuses table - replaces home_away VARCHAR field';