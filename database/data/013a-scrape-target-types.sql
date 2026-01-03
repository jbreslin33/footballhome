-- Scrape Target Types Lookup Data
-- Defines the types of data that can be scraped

INSERT INTO scrape_target_types (id, name, description, sort_order) VALUES
    (1, 'league_structure', 'League standings/table with teams and divisions', 1),
    (2, 'team_roster', 'Team roster with player names and numbers', 2),
    (3, 'match_schedule', 'Match schedule with dates and opponents', 3),
    (4, 'match_event', 'Match event details (goals, cards, lineups)', 4),
    (5, 'venue_info', 'Venue/location information from mapping services', 5),
    (6, 'chat_messages', 'Chat messages and participants from messaging platforms', 6)
ON CONFLICT (id) DO NOTHING;
