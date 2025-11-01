-- Migration 003: Normalize Location to Venues Table
-- Description: Replace events.location VARCHAR with proper venues lookup table
-- This enables structured venue data with capacity, facilities, directions, etc.

BEGIN;

-- Create venues table with comprehensive venue information
CREATE TABLE venues (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    short_name VARCHAR(100),                    -- "Training Ground", "Stadium", etc.
    venue_type VARCHAR(50) NOT NULL,            -- 'field', 'stadium', 'gym', 'clubhouse', 'outdoor', 'indoor'
    
    -- Location details
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'USA',
    latitude DECIMAL(10,8),                     -- For GPS coordinates
    longitude DECIMAL(11,8),
    
    -- Venue specifications
    surface_type VARCHAR(50),                   -- 'grass', 'artificial_turf', 'indoor_court', 'hardwood', etc.
    capacity INTEGER,                           -- Max people/players
    field_dimensions VARCHAR(100),              -- "105x68m", "Full size", etc.
    
    -- Facilities and features
    facilities TEXT[],                          -- ['changing_rooms', 'parking', 'floodlights', 'covered_seating']
    equipment_available TEXT[],                 -- ['goals', 'cones', 'bibs', 'first_aid']
    
    -- Accessibility and conditions
    wheelchair_accessible BOOLEAN DEFAULT false,
    weather_covered BOOLEAN DEFAULT false,      -- Indoor or covered facility
    parking_available BOOLEAN DEFAULT true,
    
    -- Contact and booking
    contact_name VARCHAR(100),
    contact_phone VARCHAR(20),
    contact_email VARCHAR(255),
    booking_required BOOLEAN DEFAULT false,
    hourly_rate DECIMAL(8,2),                   -- Cost per hour if applicable
    
    -- Usage restrictions
    available_hours VARCHAR(100),               -- "9AM-10PM", "24/7", etc.
    restrictions TEXT,                          -- Age limits, sport restrictions, etc.
    
    -- Additional info
    directions TEXT,
    notes TEXT,
    website VARCHAR(255),
    
    -- Ownership/management
    owned_by_team BOOLEAN DEFAULT false,
    venue_manager VARCHAR(100),
    
    -- Standard fields
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT valid_coordinates CHECK (
        (latitude IS NULL AND longitude IS NULL) OR 
        (latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180)
    )
);

-- Add venue_id to events table
ALTER TABLE events ADD COLUMN venue_id UUID REFERENCES venues(id);

-- Create index for better performance
CREATE INDEX idx_events_venue_id ON events(venue_id);
CREATE INDEX idx_venues_name ON venues(name);
CREATE INDEX idx_venues_type ON venues(venue_type);
CREATE INDEX idx_venues_city ON venues(city);

-- Insert sample venues based on existing location data
INSERT INTO venues (id, name, short_name, venue_type, address, city, surface_type, capacity, 
                   facilities, equipment_available, owned_by_team, directions, notes) VALUES

-- Thunder FC venues (team-owned)
('550e8400-e29b-41d4-a716-446655440801', 
 'Thunder FC Training Ground', 'Training Ground', 'field',
 '123 Soccer Way', 'Thunderville', 'grass', 30,
 ARRAY['changing_rooms', 'equipment_storage', 'parking', 'water_fountain'],
 ARRAY['goals', 'cones', 'bibs', 'balls', 'first_aid'],
 true, 
 'Enter through main gate, training fields are behind the clubhouse',
 'Primary training facility with 2 full-size grass fields'),

('550e8400-e29b-41d4-a716-446655440802',
 'Thunder FC Stadium', 'Stadium', 'stadium', 
 '456 Championship Blvd', 'Thunderville', 'grass', 500,
 ARRAY['changing_rooms', 'covered_seating', 'scoreboard', 'floodlights', 'parking', 'concessions'],
 ARRAY['goals', 'corner_flags', 'nets', 'first_aid', 'PA_system'],
 true,
 'Main entrance on Championship Blvd, player entrance on the east side',
 'Home stadium for matches and major events'),

('550e8400-e29b-41d4-a716-446655440803',
 'Thunder FC Clubhouse', 'Clubhouse', 'clubhouse',
 '123 Soccer Way', 'Thunderville', NULL, 50,
 ARRAY['meeting_room', 'kitchen', 'parking', 'wifi', 'projector'],
 ARRAY['tables', 'chairs', 'whiteboard', 'projector_screen'],
 true,
 'Located at the training ground complex, main building',
 'Meeting space, strategy sessions, team meals'),

('550e8400-e29b-41d4-a716-446655440804',
 'Thunder FC Gym', 'Gym', 'gym',
 '789 Fitness Lane', 'Thunderville', 'rubber_flooring', 25,
 ARRAY['changing_rooms', 'showers', 'equipment_storage', 'parking', 'air_conditioning'],
 ARRAY['weights', 'fitness_equipment', 'exercise_mats', 'agility_ladders', 'medicine_balls'],
 true,
 'Located 5 minutes from main training ground, dedicated fitness facility',
 'Indoor fitness and strength training facility'),

-- External venues
('550e8400-e29b-41d4-a716-446655440805',
 'Academy Sports Ground', 'Academy Ground', 'field',
 '321 Youth Development Dr', 'Neighboring City', 'artificial_turf', 40,
 ARRAY['changing_rooms', 'parking', 'spectator_seating'],
 ARRAY['goals', 'corner_flags', 'first_aid'],
 false,
 'Take Highway 101 North, exit at Youth Development Dr, facility is 2 blocks on the right',
 'Partner facility for friendly matches and joint training'),

-- Additional venues found in existing data
('550e8400-e29b-41d4-a716-446655440806',
 'Germantown Sports Complex', 'Germantown', 'field',
 '100 Sports Complex Way', 'Germantown', 'grass', 60,
 ARRAY['changing_rooms', 'parking', 'spectator_seating'],
 ARRAY['goals', 'corner_flags'],
 false,
 'Located in Germantown, follow signs to Sports Complex',
 'External venue used for away games or special events'),

('550e8400-e29b-41d4-a716-446655440807',
 'LH Sports Facility', 'LH', 'field',
 'Local Highway Sports Center', 'Local Area', 'artificial_turf', 35,
 ARRAY['basic_facilities', 'parking'],
 ARRAY['goals', 'basic_equipment'],
 false,
 'Highway location, check with facility manager',
 'Backup or alternative venue');

-- Update existing events to use venues instead of location strings
UPDATE events SET venue_id = '550e8400-e29b-41d4-a716-446655440801' 
WHERE location = 'Thunder FC Training Ground';

UPDATE events SET venue_id = '550e8400-e29b-41d4-a716-446655440802'
WHERE location = 'Thunder FC Stadium';

UPDATE events SET venue_id = '550e8400-e29b-41d4-a716-446655440803'
WHERE location = 'Thunder FC Clubhouse';

UPDATE events SET venue_id = '550e8400-e29b-41d4-a716-446655440804'
WHERE location = 'Thunder FC Gym';

UPDATE events SET venue_id = '550e8400-e29b-41d4-a716-446655440805'
WHERE location = 'Academy Sports Ground';

UPDATE events SET venue_id = '550e8400-e29b-41d4-a716-446655440806'
WHERE location = 'Germantown';

UPDATE events SET venue_id = '550e8400-e29b-41d4-a716-446655440807'
WHERE location = 'LH';

-- Verify all events have been mapped to venues
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM events WHERE location IS NOT NULL AND venue_id IS NULL) THEN
        RAISE EXCEPTION 'Some events still have unmapped locations. Migration cannot proceed.';
    END IF;
END $$;

-- Remove the old location column (after migration is verified successful)
-- ALTER TABLE events DROP COLUMN location;

COMMIT;

-- Create a view for easy venue + event queries
CREATE VIEW events_with_venues AS
SELECT 
    e.*,
    v.name as venue_name,
    v.short_name as venue_short_name,
    v.venue_type,
    v.address,
    v.city,
    v.surface_type,
    v.capacity as venue_capacity,
    v.facilities,
    v.directions,
    v.owned_by_team
FROM events e
LEFT JOIN venues v ON e.venue_id = v.id;