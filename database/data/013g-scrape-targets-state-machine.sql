-- Enhance scrape_targets with state machine columns
-- Adds action (what to do) and status (current state) to each target

ALTER TABLE scrape_targets 
    ADD COLUMN IF NOT EXISTS scrape_action_id INTEGER REFERENCES scrape_actions(id) DEFAULT 1,
    ADD COLUMN IF NOT EXISTS scrape_status_id INTEGER REFERENCES scrape_statuses(id) DEFAULT 1;

CREATE INDEX IF NOT EXISTS idx_scrape_targets_action ON scrape_targets(scrape_action_id);
CREATE INDEX IF NOT EXISTS idx_scrape_targets_status ON scrape_targets(scrape_status_id);

-- Set initial status based on existing is_initialized flag
UPDATE scrape_targets 
SET scrape_status_id = CASE 
    WHEN is_initialized = true THEN 3  -- completed
    ELSE 1  -- not_started
END
WHERE scrape_status_id IS NULL OR scrape_status_id = 1;

-- Historical APSL seasons should be marked as needing initial scrape
-- (They're inactive now, will be scraped once then archived)
UPDATE scrape_targets 
SET scrape_action_id = 1,  -- download_and_parse
    scrape_status_id = 1   -- not_started
WHERE id IN (2, 3, 4)  -- Historical APSL seasons
  AND is_active = false;
