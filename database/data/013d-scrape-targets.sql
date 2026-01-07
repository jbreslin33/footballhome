-- Scrape Targets Data
-- Defines what to scrape - orchestrator (update.js) queries this table
-- Active targets will be executed when update.sh runs

-- Governing Bodies (static JSON file - runs once to populate hierarchy)
INSERT INTO scrape_targets (id, source_system_id, scraper_type_id, target_type_id, url, label, is_active) VALUES
    (50, 7, 2, 18, 'file://database/config/governing-bodies-source.json', 'Governing Bodies Hierarchy (FIFA → CONCACAF → USSF)', true)
ON CONFLICT (id) DO NOTHING;

-- REST Countries API (for initial country/continent load)
-- API requires 'fields' parameter as of 2026
INSERT INTO scrape_targets (id, source_system_id, scraper_type_id, target_type_id, url, label, is_active) VALUES
    (100, 6, 1, 17, 'https://restcountries.com/v3.1/all?fields=name,cca3,fifa,continents', 'REST Countries API - All Countries', true)
ON CONFLICT (id) DO NOTHING;

-- APSL League Scraping Targets
-- All seasons start active with download_and_parse action (default)
-- After successful scraping, can be manually archived via UPDATE scrape_targets SET scrape_action_id=3, scrape_status_id=6
INSERT INTO scrape_targets (id, source_system_id, scraper_type_id, target_type_id, url, label, is_active) VALUES
    -- APSL Current Season (2025/2026)
    (1, 1, 1, 1, 'https://apslsoccer.com/APSL/Tables/', 'APSL 2025/2026 Season Structure', true),
    
    -- APSL Historical Seasons (active by default to populate on fresh rebuild)
    (2, 1, 1, 1, 'https://apslsoccer.com/APSL/Tables/?Table_Season=396', 'APSL 2022/2023 Season Structure', true),
    (3, 1, 1, 1, 'https://apslsoccer.com/APSL/Tables/?Table_Season=2597', 'APSL 2023/2024 Season Structure', true),
    (4, 1, 1, 1, 'https://apslsoccer.com/APSL/Tables/?Table_Season=6020', 'APSL 2024/2025 Season Structure', true)
ON CONFLICT (id) DO NOTHING;

-- Cosmopolitan Soccer League (CSL) - APSL Feeder League
-- Target type 1 (League Structure), Source system 2 (CSL)
INSERT INTO scrape_targets (id, source_system_id, scraper_type_id, target_type_id, url, label, is_active) VALUES
    (5, 2, 1, 1, 'https://www.cosmosoccerleague.com/CSL/Tables/', 'CSL 2025/2026 Season Structure', true)
ON CONFLICT (id) DO NOTHING;
