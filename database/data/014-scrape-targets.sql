-- Scrape Targets Data
-- Defines actual URLs to scrape with their configurations
-- Using normalized entity-specific tables

-- APSL League Structure Scraping
INSERT INTO scrape_targets (id, source_system_id, scraper_type_id, target_type_id, url, label, is_active, is_initialized) VALUES
    (1, 1, 1, 1, 'https://apslsoccer.com/standings/', 'APSL Standings/Structure', true, false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO conference_structure_scrape_targets (scrape_target_id, season_id) VALUES
    (1, 1)  -- APSL 2025 season
ON CONFLICT (scrape_target_id) DO NOTHING;

-- Note: Additional scrape targets (team rosters, schedules, match events) 
-- will be created automatically after structure discovery
-- or can be added via admin UI

-- Google Places API for Venue Info
INSERT INTO scrape_targets (id, source_system_id, scraper_type_id, target_type_id, url, label, is_active, is_initialized) VALUES
    (30, 3, 4, 11, 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json', 'Google Places - Find Venue', true, false),
    (31, 3, 4, 11, 'https://maps.googleapis.com/maps/api/place/details/json', 'Google Places - Venue Details', true, false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO venue_details_scrape_targets (scrape_target_id, venue_name_search, requires_api_key) VALUES
    (30, '', true),  -- Generic search endpoint
    (31, '', true)   -- Generic details endpoint
ON CONFLICT (scrape_target_id) DO NOTHING;

-- GroupMe API for Chat Messages  
INSERT INTO scrape_targets (id, source_system_id, scraper_type_id, target_type_id, url, label, is_active, is_initialized) VALUES
    (40, 4, 3, 12, 'https://api.groupme.com/v3/groups/{group_id}/messages', 'GroupMe Messages (Template)', true, false),
    (41, 4, 3, 14, 'https://api.groupme.com/v3/groups', 'GroupMe Groups List', true, false)
ON CONFLICT (id) DO NOTHING;

-- Note: Specific chat scrape targets will be created after chats are imported
-- via admin UI or initial GroupMe sync
