-- Migration 026: Add is_keeper flag to players table
ALTER TABLE players ADD COLUMN IF NOT EXISTS is_keeper BOOLEAN NOT NULL DEFAULT FALSE;
