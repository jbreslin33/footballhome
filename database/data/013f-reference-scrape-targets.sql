-- Reference Data Scrape Targets
-- Global/shared data sources (countries, governing bodies, venues)

-- Governing Bodies (static JSON file - runs once to populate hierarchy)
INSERT INTO scrape_targets (id, source_system_id, scraper_type_id, target_type_id, url, label) VALUES
    (50, 7, 2, 18, 'file://database/config/governing-bodies-source.json', 'Governing Bodies Hierarchy (FIFA → CONCACAF → USSF)')
ON CONFLICT (id) DO NOTHING;

-- REST Countries API (for initial country/continent load)
-- API requires 'fields' parameter as of 2026
INSERT INTO scrape_targets (id, source_system_id, scraper_type_id, target_type_id, url, label) VALUES
    (100, 6, 1, 17, 'https://restcountries.com/v3.1/all?fields=name,cca3,fifa,continents', 'REST Countries API - All Countries')
ON CONFLICT (id) DO NOTHING;
