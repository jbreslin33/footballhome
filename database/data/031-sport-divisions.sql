-- Sport Divisions (Football Home club divisions)
-- Divisions within clubs for different age groups or competition levels
-- Example: Lighthouse 1893 SC has "1893 SC Soccer", "Boys Club", "Old Timers"

INSERT INTO sport_divisions (id, club_id, display_name, sport, is_active) VALUES
    (1, 1, '1893 SC Soccer', 'Soccer', true),
    (2, 1, 'Boys Club', 'Soccer', true),
    (3, 1, 'Old Timers', 'Soccer', true)
ON CONFLICT (id) DO NOTHING;
