-- Scrape Targets Data
-- Defines what to scrape - orchestrator (update.js) queries this table
-- Active targets will be executed when update.sh runs

-- REST Countries API (for initial country/continent load)
-- API requires 'fields' parameter as of 2026
INSERT INTO scrape_targets (id, source_system_id, scraper_type_id, target_type_id, url, label, is_active) VALUES
    (100, 6, 1, 17, 'https://restcountries.com/v3.1/all?fields=name,cca3,fifa,continents', 'REST Countries API - All Countries', true)
ON CONFLICT (id) DO NOTHING;

-- APSL League Scraping Targets
INSERT INTO scrape_targets (id, source_system_id, scraper_type_id, target_type_id, url, label, is_active) VALUES
    -- APSL Standings Page (league structure)
    (1, 1, 1, 1, 'https://apslsoccer.com/standings/', 'APSL Standings/Structure', true)
ON CONFLICT (id) DO NOTHING;
