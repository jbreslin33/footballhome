-- Google Places Integration - Venue Table Enhancement
-- Add columns to capture Google Places data

-- Add Google Places specific columns
ALTER TABLE venues ADD COLUMN IF NOT EXISTS place_id VARCHAR(255) UNIQUE;
ALTER TABLE venues ADD COLUMN IF NOT EXISTS rating DECIMAL(2,1);
ALTER TABLE venues ADD COLUMN IF NOT EXISTS user_ratings_total INTEGER DEFAULT 0;
ALTER TABLE venues ADD COLUMN IF NOT EXISTS price_level INTEGER;
ALTER TABLE venues ADD COLUMN IF NOT EXISTS business_status VARCHAR(50);
ALTER TABLE venues ADD COLUMN IF NOT EXISTS google_types JSONB;
ALTER TABLE venues ADD COLUMN IF NOT EXISTS opening_hours JSONB;
ALTER TABLE venues ADD COLUMN IF NOT EXISTS photos JSONB;
ALTER TABLE venues ADD COLUMN IF NOT EXISTS data_source VARCHAR(50) DEFAULT 'user_added';
ALTER TABLE venues ADD COLUMN IF NOT EXISTS last_google_update TIMESTAMP;

-- Add formatted address (Google's full formatted address)
ALTER TABLE venues ADD COLUMN IF NOT EXISTS formatted_address TEXT;

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_venues_place_id ON venues(place_id);
CREATE INDEX IF NOT EXISTS idx_venues_rating ON venues(rating) WHERE rating IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_venues_data_source ON venues(data_source);
CREATE INDEX IF NOT EXISTS idx_venues_business_status ON venues(business_status);

-- Add constraint to ensure rating is between 1-5
ALTER TABLE venues ADD CONSTRAINT IF NOT EXISTS valid_rating 
    CHECK (rating IS NULL OR (rating >= 1.0 AND rating <= 5.0));

-- Add constraint to ensure price_level is 0-4 (Google's scale)
ALTER TABLE venues ADD CONSTRAINT IF NOT EXISTS valid_price_level 
    CHECK (price_level IS NULL OR (price_level >= 0 AND price_level <= 4));

-- Update existing venues to have user_added source
UPDATE venues SET data_source = 'user_added' WHERE data_source IS NULL;

-- Comments for documentation
COMMENT ON COLUMN venues.place_id IS 'Google Places unique identifier';
COMMENT ON COLUMN venues.rating IS 'Google Places rating (1.0-5.0)';
COMMENT ON COLUMN venues.user_ratings_total IS 'Number of Google reviews';
COMMENT ON COLUMN venues.price_level IS 'Google price level (0-4, 0=free, 4=very expensive)';
COMMENT ON COLUMN venues.business_status IS 'Google business status (OPERATIONAL, CLOSED_TEMPORARILY, etc.)';
COMMENT ON COLUMN venues.google_types IS 'Array of Google Place types (stadium, park, etc.)';
COMMENT ON COLUMN venues.opening_hours IS 'Google opening hours data (JSON)';
COMMENT ON COLUMN venues.photos IS 'Array of Google photo references';
COMMENT ON COLUMN venues.data_source IS 'Source of venue data (google_places, user_added, imported)';
COMMENT ON COLUMN venues.last_google_update IS 'Last time venue was synced with Google Places';
COMMENT ON COLUMN venues.formatted_address IS 'Google formatted address';

-- Create a view for venues with Google data
CREATE OR REPLACE VIEW venues_with_google_data AS
SELECT 
    id,
    name,
    venue_type,
    address,
    formatted_address,
    city,
    state,
    postal_code,
    country,
    latitude,
    longitude,
    place_id,
    rating,
    user_ratings_total,
    price_level,
    business_status,
    google_types,
    opening_hours,
    photos,
    data_source,
    contact_phone,
    website,
    capacity,
    surface_type,
    parking_available,
    wheelchair_accessible,
    notes,
    is_active,
    created_at,
    updated_at,
    last_google_update,
    -- Calculated fields
    CASE 
        WHEN rating IS NOT NULL AND rating >= 4.5 THEN 'Excellent'
        WHEN rating IS NOT NULL AND rating >= 4.0 THEN 'Very Good'
        WHEN rating IS NOT NULL AND rating >= 3.5 THEN 'Good'
        WHEN rating IS NOT NULL AND rating >= 3.0 THEN 'Average'
        WHEN rating IS NOT NULL THEN 'Below Average'
        ELSE 'No Rating'
    END as rating_category,
    
    CASE 
        WHEN data_source = 'google_places' THEN true
        ELSE false
    END as is_google_venue,
    
    CASE
        WHEN place_id IS NOT NULL THEN true
        ELSE false
    END as has_google_data

FROM venues
WHERE is_active = true;

COMMENT ON VIEW venues_with_google_data IS 'Enhanced venue view with Google Places data and calculated fields';