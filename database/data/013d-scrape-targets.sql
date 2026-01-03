-- Scrape Targets Data
-- Defines actual URLs to scrape with their configurations

-- APSL League Scraping Targets
INSERT INTO scrape_targets (id, source_system_id, scraper_type_id, target_type_id, url, label, params, is_active) VALUES
    -- APSL Standings Page (league structure)
    (1, 1, 1, 1, 'https://apslsoccer.com/standings/', 'APSL Standings/Structure', NULL, true),
    
    -- APSL Team Rosters (parameterized - team_url will be appended)
    (2, 1, 1, 2, 'https://apslsoccer.com/APSL/Team/{team_id}', 'APSL Team Roster (Template)', '{"is_template": true, "param": "team_id"}'::jsonb, true),
    
    -- APSL Match Events (parameterized - event_id will be appended)
    (3, 1, 1, 4, 'https://apslsoccer.com/APSL/Event/{event_id}', 'APSL Match Event (Template)', '{"is_template": true, "param": "event_id"}'::jsonb, true)
ON CONFLICT (id) DO NOTHING;

-- CASA League Scraping Targets
INSERT INTO scrape_targets (id, source_system_id, scraper_type_id, target_type_id, url, label, params, is_active) VALUES
    -- CASA Over 40 Division
    (10, 2, 1, 1, 'https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=9090889', 'CASA Over 40 Standings', '{"division": "Over 40"}'::jsonb, true),
    (11, 2, 1, 3, 'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9090889', 'CASA Over 40 Schedule', '{"division": "Over 40"}'::jsonb, true),
    (12, 2, 2, 2, 'https://docs.google.com/spreadsheets/d/14eQOJ60T0XNru6twNp59rP4RNrAuO2Gf/htmlview?gid=732556598', 'CASA Over 40 Roster Sheet', '{"division": "Over 40", "gid": "732556598"}'::jsonb, true),
    
    -- CASA Over 50 Division  
    (13, 2, 1, 1, 'https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=9096430', 'CASA Over 50 Standings', '{"division": "Over 50"}'::jsonb, true),
    (14, 2, 1, 3, 'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9096430', 'CASA Over 50 Schedule', '{"division": "Over 50"}'::jsonb, true),
    (15, 2, 2, 2, 'https://docs.google.com/spreadsheets/d/195usWo3fmXLw4IUOY_vEdB4dAk7EVfTu/htmlview?gid=1361313939', 'CASA Over 50 Roster Sheet', '{"division": "Over 50", "gid": "1361313939"}'::jsonb, true)
ON CONFLICT (id) DO NOTHING;

-- Google Places API for Venue Info
INSERT INTO scrape_targets (id, source_system_id, scraper_type_id, target_type_id, url, label, params, is_active) VALUES
    (20, 3, 4, 5, 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json', 'Google Places - Find Venue', '{"requires_api_key": true}'::jsonb, true),
    (21, 3, 4, 5, 'https://maps.googleapis.com/maps/api/place/details/json', 'Google Places - Venue Details', '{"requires_api_key": true}'::jsonb, true)
ON CONFLICT (id) DO NOTHING;

-- GroupMe API for Chat Messages
INSERT INTO scrape_targets (id, source_system_id, scraper_type_id, target_type_id, url, label, params, is_active) VALUES
    (30, 4, 3, 6, 'https://api.groupme.com/v3/groups/{group_id}/messages', 'GroupMe Messages (Template)', '{"is_template": true, "param": "group_id", "requires_api_key": true}'::jsonb, true),
    (31, 4, 3, 6, 'https://api.groupme.com/v3/groups', 'GroupMe Groups List', '{"requires_api_key": true}'::jsonb, true)
ON CONFLICT (id) DO NOTHING;
