-- CASA Soccer Leagues Scrape Targets
-- CASA Select 2024-2025 Season (Continuous Fall → Spring)
-- Philadelphia, Boston, Lancaster Conferences
--
-- NOTE: Central NJ, South NJ, North NJ have separate fall/spring seasons
-- and are not included here (fall pages not visible yet)
--
-- CASA Traditional has separate fall/spring seasons and is not included

-- Reset sequence to avoid conflicts with 013d-scrape-targets.sql (which uses IDs 1-8, 50, 100)
SELECT setval('scrape_targets_id_seq', (SELECT COALESCE(MAX(id), 0) FROM scrape_targets));

-- ============================================================================
-- PHILADELPHIA CONFERENCE
-- ============================================================================

-- CASA Select Philadelphia Liga 1 - Standings
INSERT INTO scrape_targets (
    source_system_id, 
    scraper_type_id, 
    target_type_id, 
    url, 
    label
) VALUES (
    2,  -- CASA
    1,  -- teampass_html (CASA uses SportsEngine like APSL)
    2,  -- standings
    'https://www.casasoccerleagues.com/season_management_season_page?page_node_id=9090889'
    'CASA Select Philadelphia Liga 1 - Standings'
) ON CONFLICT DO NOTHING;

-- CASA Select Philadelphia Liga 1 - Schedule
INSERT INTO scrape_targets (
    source_system_id, 
    scraper_type_id, 
    target_type_id, 
    url, 
    label
) VALUES (
    2,  -- CASA
    1,  -- teampass_html
    3,  -- schedule
    'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9090889'
    'CASA Select Philadelphia Liga 1 - Schedule'
) ON CONFLICT DO NOTHING;

-- CASA Select Philadelphia Liga 1 - Rosters (Google Sheets)
INSERT INTO scrape_targets (
    source_system_id, 
    scraper_type_id, 
    target_type_id, 
    url, 
    label
) VALUES (
    2,  -- CASA
    2,  -- google_sheets
    4,  -- team_roster
    'https://docs.google.com/spreadsheets/d/e/2PACX-1vSmsWzjTsLR81d-eQTLDM4EnaqzqUOy5OcWLy1Lna1NYVFY7gOj0nZAQdIk99e99g/pub?gid=480494399&output=csv'
    'CASA Select Philadelphia Liga 1 - Rosters'
) ON CONFLICT DO NOTHING;

-- CASA Select Philadelphia Liga 2 - Standings
INSERT INTO scrape_targets (
    source_system_id, 
    scraper_type_id, 
    target_type_id, 
    url, 
    label
) VALUES (
    2,  -- CASA
    1,  -- teampass_html
    2,  -- standings
    'https://www.casasoccerleagues.com/season_management_season_page?page_node_id=9096430'
    'CASA Select Philadelphia Liga 2 - Standings'
) ON CONFLICT DO NOTHING;

-- CASA Select Philadelphia Liga 2 - Schedule
INSERT INTO scrape_targets (
    source_system_id, 
    scraper_type_id, 
    target_type_id, 
    url, 
    label
    scrape_action_id
    scrape_status_id
) VALUES (
    2,  -- CASA
    1,  -- teampass_html
    3,  -- schedule
    'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9096430'
    'CASA Select Philadelphia Liga 2 - Schedule'
) ON CONFLICT DO NOTHING;

-- CASA Select Philadelphia Liga 2 - Rosters (Google Sheets)
INSERT INTO scrape_targets (
    source_system_id, 
    scraper_type_id, 
    target_type_id, 
    url, 
    label
    scrape_action_id
    scrape_status_id
) VALUES (
    2,  -- CASA
    2,  -- google_sheets
    4,  -- team_roster
    'https://docs.google.com/spreadsheets/d/e/2PACX-1vQsDtR6AQPgThg1105AinjkLqHMaWgQfCFJuWqfEtadH41k5OSKYZ2Hqb0N-CnO2Q/pub?gid=310279135&output=csv'
    'CASA Select Philadelphia Liga 2 - Rosters'
) ON CONFLICT DO NOTHING;

-- ============================================================================
-- BOSTON CONFERENCE
-- ============================================================================

-- CASA Select Boston Liga 1 - Standings
INSERT INTO scrape_targets (
    source_system_id, 
    scraper_type_id, 
    target_type_id, 
    url, 
    label
    scrape_action_id
    scrape_status_id
) VALUES (
    2,  -- CASA
    1,  -- teampass_html
    2,  -- standings
    'https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=9090891'
    'CASA Select Boston Liga 1 - Standings'
) ON CONFLICT DO NOTHING;

-- CASA Select Boston Liga 1 - Schedule
INSERT INTO scrape_targets (
    source_system_id, 
    scraper_type_id, 
    target_type_id, 
    url, 
    label
    scrape_action_id
    scrape_status_id
) VALUES (
    2,  -- CASA
    1,  -- teampass_html
    3,  -- schedule
    'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9090891'
    'CASA Select Boston Liga 1 - Schedule'
) ON CONFLICT DO NOTHING;

-- ============================================================================
-- LANCASTER CONFERENCE
-- ============================================================================

-- CASA Select Lancaster Liga 1 - Standings
INSERT INTO scrape_targets (
    source_system_id, 
    scraper_type_id, 
    target_type_id, 
    url, 
    label
    scrape_action_id
    scrape_status_id
) VALUES (
    2,  -- CASA
    1,  -- teampass_html
    2,  -- standings
    'https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=9090893'
    'CASA Select Lancaster Liga 1 - Standings'
) ON CONFLICT DO NOTHING;

-- CASA Select Lancaster Liga 1 - Schedule
INSERT INTO scrape_targets (
    source_system_id, 
    scraper_type_id, 
    target_type_id, 
    url, 
    label
    scrape_action_id
    scrape_status_id
) VALUES (
    2,  -- CASA
    1,  -- teampass_html
    3,  -- schedule
    'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9090893'
    'CASA Select Lancaster Liga 1 - Schedule'
) ON CONFLICT DO NOTHING;
