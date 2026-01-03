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
    -- CASA Traditional League - Philadelphia Division 1 Liga 1
    (10, 2, 1, 1, 'https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=9090889', 'CASA Traditional Philly D1L1 Standings', '{"league": "Traditional", "region": "Philadelphia", "division": "1", "liga": "1"}'::jsonb, true),
    (11, 2, 1, 3, 'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9090889', 'CASA Traditional Philly D1L1 Schedule', '{"league": "Traditional", "region": "Philadelphia", "division": "1", "liga": "1"}'::jsonb, true),
    (12, 2, 2, 2, 'https://docs.google.com/spreadsheets/d/14eQOJ60T0XNru6twNp59rP4RNrAuO2Gf/htmlview?gid=732556598', 'CASA Traditional Philly D1L1 Roster', '{"league": "Traditional", "region": "Philadelphia", "division": "1", "liga": "1", "gid": "732556598"}'::jsonb, true),
    
    -- CASA Traditional League - Philadelphia Division 2 Liga 2
    (13, 2, 1, 1, 'https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=9096430', 'CASA Traditional Philly D2L2 Standings', '{"league": "Traditional", "region": "Philadelphia", "division": "2", "liga": "2"}'::jsonb, true),
    (14, 2, 1, 3, 'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9096430', 'CASA Traditional Philly D2L2 Schedule', '{"league": "Traditional", "region": "Philadelphia", "division": "2", "liga": "2"}'::jsonb, true),
    (15, 2, 2, 2, 'https://docs.google.com/spreadsheets/d/195usWo3fmXLw4IUOY_vEdB4dAk7EVfTu/htmlview?gid=1361313939', 'CASA Traditional Philly D2L2 Roster', '{"league": "Traditional", "region": "Philadelphia", "division": "2", "liga": "2", "gid": "1361313939"}'::jsonb, true),
    
    -- CASA Traditional League - Boston Division 1 Liga 1
    (16, 2, 1, 1, 'https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=9090891', 'CASA Traditional Boston D1L1 Standings', '{"league": "Traditional", "region": "Boston", "division": "1", "liga": "1"}'::jsonb, true),
    (17, 2, 1, 3, 'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9090891', 'CASA Traditional Boston D1L1 Schedule', '{"league": "Traditional", "region": "Boston", "division": "1", "liga": "1"}'::jsonb, true),
    
    -- CASA Select League - Lancaster Division 1 Liga 1
    (18, 2, 1, 1, 'https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=9090893', 'CASA Select Lancaster D1L1 Standings', '{"league": "Select", "region": "Lancaster", "division": "1", "liga": "1"}'::jsonb, true),
    (19, 2, 1, 3, 'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9090893', 'CASA Select Lancaster D1L1 Schedule', '{"league": "Select", "region": "Lancaster", "division": "1", "liga": "1"}'::jsonb, true),
    (20, 2, 2, 2, 'https://docs.google.com/spreadsheets/d/1OnHnhrSRA3Wp2eCs_9-dJhDBlVhSEoobFDGTYvQTfvE/htmlview?gid=661044352', 'CASA Select Lancaster D1L1 Roster', '{"league": "Select", "region": "Lancaster", "division": "1", "liga": "1", "gid": "661044352"}'::jsonb, true),
    
    -- CASA Select League - Central New Jersey Liga 1
    (21, 2, 1, 1, 'https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=9124981', 'CASA Select Central NJ L1 Standings', '{"league": "Select", "region": "Central NJ", "liga": "1"}'::jsonb, true),
    (22, 2, 1, 3, 'https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=9124981', 'CASA Select Central NJ L1 Schedule', '{"league": "Select", "region": "Central NJ", "liga": "1"}'::jsonb, true),
    (23, 2, 2, 2, 'https://docs.google.com/spreadsheets/d/1tStu09AvdhBJtYLXl49R-oa5XgFYDo9j/htmlview?gid=229389251', 'CASA Select Central NJ L1 Roster', '{"league": "Select", "region": "Central NJ", "liga": "1", "gid": "229389251"}'::jsonb, true)
ON CONFLICT (id) DO NOTHING;

-- Google Places API for Venue Info
INSERT INTO scrape_targets (id, source_system_id, scraper_type_id, target_type_id, url, label, params, is_active) VALUES
    (30, 3, 4, 5, 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json', 'Google Places - Find Venue', '{"requires_api_key": true}'::jsonb, true),
    (31, 3, 4, 5, 'https://maps.googleapis.com/maps/api/place/details/json', 'Google Places - Venue Details', '{"requires_api_key": true}'::jsonb, true)
ON CONFLICT (id) DO NOTHING;

-- GroupMe API for Chat Messages
INSERT INTO scrape_targets (id, source_system_id, scraper_type_id, target_type_id, url, label, params, is_active) VALUES
    (40, 4, 3, 6, 'https://api.groupme.com/v3/groups/{group_id}/messages', 'GroupMe Messages (Template)', '{"is_template": true, "param": "group_id", "requires_api_key": true}'::jsonb, true),
    (41, 4, 3, 6, 'https://api.groupme.com/v3/groups', 'GroupMe Groups List', '{"requires_api_key": true}'::jsonb, true)
ON CONFLICT (id) DO NOTHING;
