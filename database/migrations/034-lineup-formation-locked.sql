-- Migration 034: Add formation_locked flag to match_lineup_metadata
ALTER TABLE match_lineup_metadata
  ADD COLUMN IF NOT EXISTS formation_locked BOOLEAN NOT NULL DEFAULT true;
