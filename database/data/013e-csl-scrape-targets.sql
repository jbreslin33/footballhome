-- Cosmopolitan Soccer League (CSL) - APSL Feeder League
-- Target type 1 (League Structure), Source system 3 (CSL)

INSERT INTO scrape_targets (id, source_system_id, scraper_type_id, target_type_id, url, label) VALUES
    -- CSL Current Season (2025/2026)
    (5, 3, 1, 1, 'https://www.cosmosoccerleague.com/CSL/Tables/', 'CSL 2025/2026 Season Structure'),
    
    -- CSL Historical Seasons
    (6, 3, 1, 1, 'https://www.cosmosoccerleague.com/CSL/Tables/?Table_Season=395', 'CSL 2022/2023 Season Structure'),
    (7, 3, 1, 1, 'https://www.cosmosoccerleague.com/CSL/Tables/?Table_Season=2596', 'CSL 2023/2024 Season Structure'),
    (8, 3, 1, 1, 'https://www.cosmosoccerleague.com/CSL/Tables/?Table_Season=6026', 'CSL 2024/2025 Season Structure')
ON CONFLICT (id) DO NOTHING;
