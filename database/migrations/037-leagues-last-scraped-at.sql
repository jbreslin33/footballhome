-- Migration 037: Add last_scraped_at to leagues
-- Tracks when match schedule data was last imported/scraped from the external league source.
ALTER TABLE leagues
  ADD COLUMN IF NOT EXISTS last_scraped_at timestamp without time zone;
