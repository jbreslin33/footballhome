-- Field Naming Improvements - Align with Google Places Standards
-- Rename fields to match Google's naming conventions

-- Rename contact_phone to phone (matches Google's detailed response)
ALTER TABLE venues RENAME COLUMN contact_phone TO phone;

-- Rename contact_email to email (consistency with phone)
ALTER TABLE venues RENAME COLUMN contact_email TO email;

-- Add international_phone_number (Google provides this)
ALTER TABLE venues ADD COLUMN IF NOT EXISTS international_phone_number VARCHAR(30);

-- Add index for phone searches
CREATE INDEX IF NOT EXISTS idx_venues_phone ON venues(phone) WHERE phone IS NOT NULL;

-- Update comments to reflect the changes
COMMENT ON COLUMN venues.phone IS 'Primary phone number (Google: formatted_phone_number)';
COMMENT ON COLUMN venues.email IS 'Contact email address';
COMMENT ON COLUMN venues.international_phone_number IS 'International format phone number from Google Places';

-- Optional: Create a view that shows the field mapping
CREATE OR REPLACE VIEW venues_google_mapping AS
SELECT 
    id,
    name,
    place_id,
    -- Google standard names with our field names
    formatted_address,
    latitude as lat,
    longitude as lng,
    phone as formatted_phone_number,
    international_phone_number,
    website,
    rating,
    user_ratings_total,
    price_level,
    business_status,
    google_types as types,
    opening_hours,
    photos,
    -- Additional fields we have that Google doesn't
    venue_type,
    capacity,
    surface_type,
    parking_available,
    wheelchair_accessible,
    data_source
FROM venues
WHERE is_active = true;

COMMENT ON VIEW venues_google_mapping IS 'Venue data with Google Places standard field names for API consistency';

-- Show the changes
SELECT 
    'Field Renaming Complete' as status,
    'contact_phone -> phone' as change1,
    'contact_email -> email' as change2,
    'Added international_phone_number' as change3;