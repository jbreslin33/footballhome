-- Migration 043: manual lineup status flags per player
-- Adds persistent checkboxes used by Game Day Lineup across all teams.

ALTER TABLE players
  ADD COLUMN IF NOT EXISTS on_official_roster_override BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_lighthouse_registered BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_paid_up_to_date BOOLEAN NOT NULL DEFAULT false;
