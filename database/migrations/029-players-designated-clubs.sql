-- Migration 029: Add is_designated and num_clubs flags to players table
ALTER TABLE players ADD COLUMN IF NOT EXISTS is_designated BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE players ADD COLUMN IF NOT EXISTS num_clubs SMALLINT NOT NULL DEFAULT 1;
