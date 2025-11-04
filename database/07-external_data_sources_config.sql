-- Initial configuration for external data sources
-- Insert known league data sources

-- APSL Website Configuration
INSERT INTO external_data_sources (
    name, display_name, slug, base_url, source_type, data_format, 
    authentication_type, update_frequency, is_active
) VALUES (
    'APSL Website', 'Amateur Premier Soccer League Website', 'apsl-website',
    'https://www.apslsoccer.com', 'website_scrape', 'html',
    'none', 'daily', true
);

-- Get the APSL source ID for endpoint configuration
DO $$
DECLARE
    apsl_source_id UUID;
BEGIN
    SELECT id INTO apsl_source_id FROM external_data_sources WHERE slug = 'apsl-website';
    
    -- APSL Standings endpoints for each conference
    INSERT INTO data_source_endpoints (source_id, name, endpoint_path, data_type, extraction_config) VALUES
    (apsl_source_id, 'Delaware River Standings', '/APSL/Tables/table_APSL_DelRiv.html', 'standings', 
     '{"table_selector": ".sortable tbody tr", "team_name": "td:nth-child(2)", "games_played": "td:nth-child(3)", "wins": "td:nth-child(4)", "losses": "td:nth-child(5)", "draws": "td:nth-child(6)", "goals_for": "td:nth-child(7)", "goals_against": "td:nth-child(8)", "points": "td:nth-child(9)"}'),
    
    (apsl_source_id, 'Metro NY/NJ Standings', '/APSL/Tables/table_APSL_Metro.html', 'standings',
     '{"table_selector": ".sortable tbody tr", "team_name": "td:nth-child(2)", "games_played": "td:nth-child(3)", "wins": "td:nth-child(4)", "losses": "td:nth-child(5)", "draws": "td:nth-child(6)", "goals_for": "td:nth-child(7)", "goals_against": "td:nth-child(8)", "points": "td:nth-child(9)"}'),
    
    (apsl_source_id, 'Southeast Standings', '/APSL/Tables/table_APSL_Southeast.html', 'standings',
     '{"table_selector": ".sortable tbody tr", "team_name": "td:nth-child(2)", "games_played": "td:nth-child(3)", "wins": "td:nth-child(4)", "losses": "td:nth-child(5)", "draws": "td:nth-child(6)", "goals_for": "td:nth-child(7)", "goals_against": "td:nth-child(8)", "points": "td:nth-child(9)"}'),
    
    (apsl_source_id, 'Mid-Atlantic Standings', '/APSL/Tables/table_APSL_Mid_Atlantic.html', 'standings',
     '{"table_selector": ".sortable tbody tr", "team_name": "td:nth-child(2)", "games_played": "td:nth-child(3)", "wins": "td:nth-child(4)", "losses": "td:nth-child(5)", "draws": "td:nth-child(6)", "goals_for": "td:nth-child(7)", "goals_against": "td:nth-child(8)", "points": "td:nth-child(9)"}'),
    
    (apsl_source_id, 'Northeast Standings', '/APSL/Tables/table_APSL_Northeast.html', 'standings',
     '{"table_selector": ".sortable tbody tr", "team_name": "td:nth-child(2)", "games_played": "td:nth-child(3)", "wins": "td:nth-child(4)", "losses": "td:nth-child(5)", "draws": "td:nth-child(6)", "goals_for": "td:nth-child(7)", "goals_against": "td:nth-child(8)", "points": "td:nth-child(9)"}'),
    
    (apsl_source_id, 'South Atlantic Standings', '/APSL/Tables/table_APSL_South_Atlantic.html', 'standings',
     '{"table_selector": ".sortable tbody tr", "team_name": "td:nth-child(2)", "games_played": "td:nth-child(3)", "wins": "td:nth-child(4)", "losses": "td:nth-child(5)", "draws": "td:nth-child(6)", "goals_for": "td:nth-child(7)", "goals_against": "td:nth-child(8)", "points": "td:nth-child(9)"}');
END $$;

-- Placeholder for CASA League (when they have a website/API)
INSERT INTO external_data_sources (
    name, display_name, slug, base_url, source_type, data_format,
    authentication_type, update_frequency, is_active
) VALUES (
    'CASA League System', 'Central Atlantic Soccer Association', 'casa-league',
    'https://casaleague.com', 'rest_api', 'json',
    'api_key', 'daily', false  -- Set to false until we have real integration
);

-- Placeholder for Tri-County Women's League
INSERT INTO external_data_sources (
    name, display_name, slug, base_url, source_type, data_format,
    authentication_type, update_frequency, is_active
) VALUES (
    'TCWL System', 'Tri-County Women\'s League', 'tcwl-system',
    'https://tcwl.org', 'website_scrape', 'html',
    'none', 'weekly', false  -- Set to false until we have real integration
);