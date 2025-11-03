-- Known Soccer Venues Data
-- Pre-populated venues with Google Places data where available
-- Loads during database initialization to provide venue options

-- Major Soccer Venues (with Google Places data where known)
INSERT INTO venues (
    name, short_name, venue_type, address, city, state, postal_code, country,
    latitude, longitude, formatted_address, surface_type, capacity,
    facilities, wheelchair_accessible, parking_available, 
    data_source, is_active
) VALUES

-- Example venues - replace with real known venues
('Red Bull Arena', 'RBA', 'stadium', 
 '600 Cape May St', 'Harrison', 'NJ', '07029', 'USA',
 40.7369, -74.1500, '600 Cape May St, Harrison, NJ 07029, USA',
 'grass', 25000,
 ARRAY['changing_rooms', 'covered_seating', 'scoreboard', 'floodlights', 'parking', 'concessions'],
 true, true, 'google_places', true),

('Yankee Stadium', 'YS Soccer', 'stadium',
 '1 E 161st St', 'Bronx', 'NY', '10451', 'USA', 
 40.8296, -73.9262, '1 E 161st St, Bronx, NY 10451, USA',
 'grass', 54251,
 ARRAY['changing_rooms', 'covered_seating', 'scoreboard', 'floodlights', 'parking', 'concessions'],
 true, true, 'google_places', true),

-- Community Fields 
('Randalls Island Field 70', 'Field 70', 'field',
 'Randalls Island Park', 'New York', 'NY', '10035', 'USA',
 40.7900, -73.9240, 'Randalls Island Park, New York, NY 10035, USA',
 'grass', 200,
 ARRAY['goals', 'water_fountain', 'parking'],
 true, true, 'user_added', true)

;