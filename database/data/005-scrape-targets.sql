-- Scrape Targets Registry
-- Defines URLs and APIs to fetch data from
-- Scrapers read this table to know what to fetch

CREATE TABLE IF NOT EXISTS scrape_targets (
  id SERIAL PRIMARY KEY,
  source_system_id INTEGER REFERENCES source_systems(id),
  target_type VARCHAR(50) NOT NULL,  -- 'league_structure', 'roster', 'schedule', 'standings', 'reference_data'
  url TEXT NOT NULL,
  description TEXT NOT NULL,
  config JSONB DEFAULT '{}',
  fetch_frequency VARCHAR(20) DEFAULT 'weekly',  -- 'daily', 'weekly', 'monthly', 'once', 'manual'
  last_fetched_at TIMESTAMP,
  is_active BOOLEAN DEFAULT true,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Reference Data Targets (scraped once, rarely changes)
INSERT INTO scrape_targets (source_system_id, target_type, url, description, config, fetch_frequency, notes, is_active) VALUES
  (NULL, 'reference_data', 'https://www.fifa.com/about-fifa/associations', 'FIFA Member Associations', '{"extracts": ["national_federations"]}', 'once', 'All 211 FIFA member associations', true),
  (NULL, 'reference_data', 'https://www.usadultsoccer.com/state-associations', 'USASA State Associations', '{"extracts": ["state_bodies"]}', 'once', 'All 54 USASA state associations', true);

-- APSL Targets
INSERT INTO scrape_targets (source_system_id, target_type, url, description, config, fetch_frequency, notes, is_active) VALUES
  (1, 'league_structure', 'https://apslsoccer.com/standings', 'APSL Standings Page', '{"extracts": ["conferences", "divisions", "teams", "standings"]}', 'weekly', 'Main page with all conference standings', true);

-- CASA Traditional - Philadelphia (single roster for all 7 divisions)
INSERT INTO scrape_targets (source_system_id, target_type, url, description, config, fetch_frequency, notes, is_active) VALUES
  (2, 'roster', 'https://casasoccerleagues.com/roster-viewer?page_node_id=9145726', 'CASA Traditional Philadelphia - All Divisions Roster', '{"conference": "Philadelphia Traditional", "divisions": ["Primera", "Segunda", "Tercera", "Cuarta", "Quinto", "Sexta", "Septima"]}', 'weekly', 'Single roster sheet for all 7 divisions', true),
  
  -- Philadelphia Traditional - Standings (one per division)
  (2, 'standings', 'https://casasoccerleagues.com/standings?page_node_id=9150245', 'CASA Traditional Philadelphia Primera Standings', '{"conference": "Philadelphia Traditional", "division": "Primera"}', 'weekly', 'Primera division standings', true),
  (2, 'standings', 'https://casasoccerleagues.com/standings?page_node_id=9150262', 'CASA Traditional Philadelphia Segunda Standings', '{"conference": "Philadelphia Traditional", "division": "Segunda"}', 'weekly', 'Segunda division standings', true),
  (2, 'standings', 'https://casasoccerleagues.com/standings?page_node_id=9150278', 'CASA Traditional Philadelphia Tercera Standings', '{"conference": "Philadelphia Traditional", "division": "Tercera"}', 'weekly', 'Tercera division standings', true),
  (2, 'standings', 'https://casasoccerleagues.com/standings?page_node_id=9150291', 'CASA Traditional Philadelphia Cuarta Standings', '{"conference": "Philadelphia Traditional", "division": "Cuarta"}', 'weekly', 'Cuarta division standings', true),
  (2, 'standings', 'https://casasoccerleagues.com/standings?page_node_id=9150307', 'CASA Traditional Philadelphia Quinto Standings', '{"conference": "Philadelphia Traditional", "division": "Quinto"}', 'weekly', 'Quinto division standings', true),
  (2, 'standings', 'https://casasoccerleagues.com/standings?page_node_id=9150320', 'CASA Traditional Philadelphia Sexta Standings', '{"conference": "Philadelphia Traditional", "division": "Sexta"}', 'weekly', 'Sexta division standings', true),
  (2, 'standings', 'https://casasoccerleagues.com/standings?page_node_id=9150336', 'CASA Traditional Philadelphia Septima Standings', '{"conference": "Philadelphia Traditional", "division": "Septima"}', 'weekly', 'Septima division standings', true),
  
  -- Philadelphia Traditional - Schedules (one per division)
  (2, 'schedule', 'https://casasoccerleagues.com/schedules?page_node_id=9150245', 'CASA Traditional Philadelphia Primera Schedule', '{"conference": "Philadelphia Traditional", "division": "Primera"}', 'weekly', 'Primera division schedule', true),
  (2, 'schedule', 'https://casasoccerleagues.com/schedules?page_node_id=9150262', 'CASA Traditional Philadelphia Segunda Schedule', '{"conference": "Philadelphia Traditional", "division": "Segunda"}', 'weekly', 'Segunda division schedule', true),
  (2, 'schedule', 'https://casasoccerleagues.com/schedules?page_node_id=9150278', 'CASA Traditional Philadelphia Tercera Schedule', '{"conference": "Philadelphia Traditional", "division": "Tercera"}', 'weekly', 'Tercera division schedule', true),
  (2, 'schedule', 'https://casasoccerleagues.com/schedules?page_node_id=9150291', 'CASA Traditional Philadelphia Cuarta Schedule', '{"conference": "Philadelphia Traditional", "division": "Cuarta"}', 'weekly', 'Cuarta division schedule', true),
  (2, 'schedule', 'https://casasoccerleagues.com/schedules?page_node_id=9150307', 'CASA Traditional Philadelphia Quinto Schedule', '{"conference": "Philadelphia Traditional", "division": "Quinto"}', 'weekly', 'Quinto division schedule', true),
  (2, 'schedule', 'https://casasoccerleagues.com/schedules?page_node_id=9150320', 'CASA Traditional Philadelphia Sexta Schedule', '{"conference": "Philadelphia Traditional", "division": "Sexta"}', 'weekly', 'Sexta division schedule', true),
  (2, 'schedule', 'https://casasoccerleagues.com/schedules?page_node_id=9150336', 'CASA Traditional Philadelphia Septima Schedule', '{"conference": "Philadelphia Traditional", "division": "Septima"}', 'weekly', 'Septima division schedule', true);

-- CASA Traditional - Boston
INSERT INTO scrape_targets (source_system_id, target_type, url, description, config, fetch_frequency, notes, is_active) VALUES
  -- Boston Traditional - Standings (one per division)
  (2, 'standings', 'https://casasoccerleagues.com/standings?page_node_id=9152657', 'CASA Traditional Boston Primera Standings', '{"conference": "Boston Traditional", "division": "Primera"}', 'weekly', 'Primera division standings', true),
  (2, 'standings', 'https://casasoccerleagues.com/standings?page_node_id=9152685', 'CASA Traditional Boston Segunda Standings', '{"conference": "Boston Traditional", "division": "Segunda"}', 'weekly', 'Segunda division standings', true),
  (2, 'standings', 'https://casasoccerleagues.com/standings?page_node_id=9152707', 'CASA Traditional Boston Tercera Standings', '{"conference": "Boston Traditional", "division": "Tercera"}', 'weekly', 'Tercera division standings', true),
  (2, 'standings', 'https://casasoccerleagues.com/standings?page_node_id=9152723', 'CASA Traditional Boston Cuarto Azul Standings', '{"conference": "Boston Traditional", "division": "Cuarto Azul"}', 'weekly', 'Cuarto Azul division standings', true),
  (2, 'standings', 'https://casasoccerleagues.com/standings?page_node_id=9152738', 'CASA Traditional Boston Cuarta Roja Standings', '{"conference": "Boston Traditional", "division": "Cuarta Roja"}', 'weekly', 'Cuarta Roja division standings', true),
  
  -- Boston Traditional - Schedules (one per division)
  (2, 'schedule', 'https://casasoccerleagues.com/schedules?page_node_id=9152657', 'CASA Traditional Boston Primera Schedule', '{"conference": "Boston Traditional", "division": "Primera"}', 'weekly', 'Primera division schedule', true),
  (2, 'schedule', 'https://casasoccerleagues.com/schedules?page_node_id=9152685', 'CASA Traditional Boston Segunda Schedule', '{"conference": "Boston Traditional", "division": "Segunda"}', 'weekly', 'Segunda division schedule', true),
  (2, 'schedule', 'https://casasoccerleagues.com/schedules?page_node_id=9152707', 'CASA Traditional Boston Tercera Schedule', '{"conference": "Boston Traditional", "division": "Tercera"}', 'weekly', 'Tercera division schedule', true),
  (2, 'schedule', 'https://casasoccerleagues.com/schedules?page_node_id=9152723', 'CASA Traditional Boston Cuarto Azul Schedule', '{"conference": "Boston Traditional", "division": "Cuarto Azul"}', 'weekly', 'Cuarto Azul division schedule', true),
  (2, 'schedule', 'https://casasoccerleagues.com/schedules?page_node_id=9152738', 'CASA Traditional Boston Cuarta Roja Schedule', '{"conference": "Boston Traditional", "division": "Cuarta Roja"}', 'weekly', 'Cuarta Roja division schedule', true);

-- CASA Select - Philadelphia
INSERT INTO scrape_targets (source_system_id, target_type, url, description, config, fetch_frequency, notes, is_active) VALUES
  (2, 'roster', 'https://casasoccerleagues.com/roster-viewer?page_node_id=9090889', 'CASA Select Philadelphia Liga 1 Roster', '{"conference": "Philadelphia Select", "division": "Liga 1", "cross_division_matches": true}', 'weekly', 'Liga 1 roster. WARNING: Liga 1/Liga 2 have crossover matches - team names may vary between divisions!', true),
  (2, 'standings', 'https://casasoccerleagues.com/standings?page_node_id=9090889', 'CASA Select Philadelphia Liga 1 Standings', '{"conference": "Philadelphia Select", "division": "Liga 1", "cross_division_matches": true}', 'weekly', 'Liga 1 standings. WARNING: Cross-division matches with Liga 2 - team names may vary!', true),
  (2, 'schedule', 'https://casasoccerleagues.com/schedules?page_node_id=9090889', 'CASA Select Philadelphia Liga 1 Schedule', '{"conference": "Philadelphia Select", "division": "Liga 1", "cross_division_matches": true}', 'weekly', 'Liga 1 schedule. WARNING: Contains Liga 1 vs Liga 2 matches - team names may not match!', true),
  (2, 'roster', 'https://casasoccerleagues.com/roster-viewer?page_node_id=9096430', 'CASA Select Philadelphia Liga 2 Roster', '{"conference": "Philadelphia Select", "division": "Liga 2", "cross_division_matches": true}', 'weekly', 'Liga 2 roster. WARNING: Liga 1/Liga 2 have crossover matches - team names may vary between divisions!', true),
  (2, 'standings', 'https://casasoccerleagues.com/standings?page_node_id=9096430', 'CASA Select Philadelphia Liga 2 Standings', '{"conference": "Philadelphia Select", "division": "Liga 2", "cross_division_matches": true}', 'weekly', 'Liga 2 standings. WARNING: Cross-division matches with Liga 1 - team names may vary!', true),
  (2, 'schedule', 'https://casasoccerleagues.com/schedules?page_node_id=9096430', 'CASA Select Philadelphia Liga 2 Schedule', '{"conference": "Philadelphia Select", "division": "Liga 2", "cross_division_matches": true}', 'weekly', 'Liga 2 schedule. WARNING: Contains Liga 1 vs Liga 2 matches - team names may not match!', true);

-- CASA Select - Boston
INSERT INTO scrape_targets (source_system_id, target_type, url, description, config, fetch_frequency, notes, is_active) VALUES
  (2, 'standings', 'https://casasoccerleagues.com/standings?page_node_id=9090891', 'CASA Select Boston Liga 1 Standings', '{"conference": "Boston Select", "division": "Liga 1", "cross_division_matches": true}', 'weekly', 'Liga 1 standings. WARNING: Cross-division matches with Division 2 - team names may vary!', true),
  (2, 'schedule', 'https://casasoccerleagues.com/schedules?page_node_id=9090891', 'CASA Select Boston Liga 1 Schedule', '{"conference": "Boston Select", "division": "Liga 1", "cross_division_matches": true}', 'weekly', 'Liga 1 schedule. WARNING: Contains Liga 1 vs Division 2 matches - team names may not match!', true);

-- CASA Select - Lancaster
INSERT INTO scrape_targets (source_system_id, target_type, url, description, config, fetch_frequency, notes, is_active) VALUES
  (2, 'roster', 'https://casasoccerleagues.com/roster-viewer?page_node_id=9090893', 'CASA Select Lancaster Liga 1 Roster', '{"conference": "Lancaster Select", "division": "Liga 1", "cross_division_matches": true}', 'weekly', 'Liga 1 roster. WARNING: Liga 1/Division 2 have crossover matches - team names may vary between divisions!', true),
  (2, 'standings', 'https://casasoccerleagues.com/standings?page_node_id=9090893', 'CASA Select Lancaster Liga 1 Standings', '{"conference": "Lancaster Select", "division": "Liga 1", "cross_division_matches": true}', 'weekly', 'Liga 1 standings. WARNING: Cross-division matches with Division 2 - team names may vary!', true),
  (2, 'schedule', 'https://casasoccerleagues.com/schedules?page_node_id=9090893', 'CASA Select Lancaster Liga 1 Schedule', '{"conference": "Lancaster Select", "division": "Liga 1", "cross_division_matches": true}', 'weekly', 'Liga 1 schedule. WARNING: Contains Liga 1 vs Division 2 matches - team names may not match!', true);

-- CASA Select - Central New Jersey
INSERT INTO scrape_targets (source_system_id, target_type, url, description, config, fetch_frequency, notes, is_active) VALUES
  (2, 'roster', 'https://casasoccerleagues.com/roster-viewer?page_node_id=9124981', 'CASA Select Central NJ Liga 1 Roster', '{"conference": "Central New Jersey Select", "division": "Liga 1", "cross_division_matches": true}', 'weekly', 'Liga 1 roster. WARNING: Liga 1/Division 2 have crossover matches - team names may vary between divisions!', true),
  (2, 'standings', 'https://casasoccerleagues.com/standings?page_node_id=9124981', 'CASA Select Central NJ Liga 1 Standings', '{"conference": "Central New Jersey Select", "division": "Liga 1", "cross_division_matches": true}', 'weekly', 'Liga 1 standings. WARNING: Cross-division matches with Division 2 - team names may vary!', true),
  (2, 'schedule', 'https://casasoccerleagues.com/schedules?page_node_id=9124981', 'CASA Select Central NJ Liga 1 Schedule', '{"conference": "Central New Jersey Select", "division": "Liga 1", "cross_division_matches": true}', 'weekly', 'Liga 1 schedule. WARNING: Contains Liga 1 vs Division 2 matches - team names may not match!', true);
