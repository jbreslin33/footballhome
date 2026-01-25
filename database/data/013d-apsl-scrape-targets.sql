-- APSL League Scraping Targets
-- All seasons start active with download_and_parse action (default)
-- After successful scraping, can be manually archived via UPDATE scrape_targets SET scrape_action_id=3, scrape_status_id=6

INSERT INTO scrape_targets (id, source_system_id, scraper_type_id, target_type_id, url, label) VALUES
    -- APSL Current Season (2025/2026)
    (1, 1, 1, 1, 'https://apslsoccer.com/APSL/Tables/', 'APSL 2025/2026 Season Structure'),
    
    -- APSL Historical Seasons
    (2, 1, 1, 1, 'https://apslsoccer.com/APSL/Tables/?Table_Season=396', 'APSL 2022/2023 Season Structure'),
    (3, 1, 1, 1, 'https://apslsoccer.com/APSL/Tables/?Table_Season=2597', 'APSL 2023/2024 Season Structure'),
    (4, 1, 1, 1, 'https://apslsoccer.com/APSL/Tables/?Table_Season=6020', 'APSL 2024/2025 Season Structure')
ON CONFLICT (id) DO NOTHING;
