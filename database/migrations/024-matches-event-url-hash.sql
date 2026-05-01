-- Migration 024: Add event_url_hash to matches
--
-- APSL event pages require a full URL with a hex hash:
--   https://apslsoccer.com/APSL/Event/{numeric_id}_{HASH}
--
-- The numeric part is already stored in external_id.
-- This column stores the uppercase hex hash so we can construct
-- the event URL directly without re-fetching the team schedule page.
--
-- Only populated for APSL matches (source_system_id = 1).
-- NULL for CASA and CSL (their event URLs don't use this pattern).

ALTER TABLE matches ADD COLUMN IF NOT EXISTS event_url_hash VARCHAR(50);
