-- Migration 030: Add custom_positions JSONB to match_lineup_metadata
-- Stores per-slot {x, y} positions in canonical 0-100 space for custom formation mode
ALTER TABLE match_lineup_metadata ADD COLUMN IF NOT EXISTS custom_positions JSONB;
