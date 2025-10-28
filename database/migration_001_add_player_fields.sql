-- Migration: Add player-specific fields to users table
-- This adds position and jersey_number fields for player profiles

ALTER TABLE users 
ADD COLUMN position VARCHAR(50),
ADD COLUMN jersey_number INTEGER;

-- Add a constraint to ensure jersey numbers are unique within teams
-- We'll need a more complex constraint later, but for now keep it simple
ALTER TABLE users 
ADD CONSTRAINT check_jersey_number 
CHECK (jersey_number IS NULL OR (jersey_number >= 1 AND jersey_number <= 99));

-- Update existing sample data with some position info
UPDATE users 
SET position = 'midfielder', jersey_number = 10 
WHERE email = 'player1@footballhome.org';

UPDATE users 
SET position = 'forward', jersey_number = 7 
WHERE email = 'player2@footballhome.org';