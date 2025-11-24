# Google Places Venues - Implementation Guide

## Overview

This system fetches soccer venues from Google Places API once and saves them as SQL INSERT statements. This avoids API costs on every database rebuild and ensures consistent venue data.

## Venue Files

The venue system now supports two loading modes:

### 1. **01-venues.sql** (Full Dataset - ~11,585 lines)
Complete venue data for all regional cities:
- Philadelphia, PA
- Allentown, PA
- Atlantic City, NJ
- Harrisburg, PA
- Lancaster, PA
- Reading, PA
- Scranton, PA
- Trenton, NJ
- Wilmington, DE

### 2. **01-venues-minimum.sql** (Development Dataset - ~1,507 lines)
Philadelphia venues only for faster development and testing.

## Usage

### Loading with start.sh

```bash
# Load all regional venues
./start.sh --venues

# Load only Philadelphia venues (minimum dataset)
./start.sh --venues --minimum

# Load everything with minimum venues
./start.sh --all --minimum
```

### Manual Loading

```bash
# Load all venues
docker compose exec -T db psql -U footballhome_user -d footballhome < database/venues/01-venues.sql

# Load minimum venues
docker compose exec -T db psql -U footballhome_user -d footballhome < database/venues/01-venues-minimum.sql
```

### 3. Rebuild Database (Includes Venues)

The venues are automatically included when you rebuild:

```bash
# Full rebuild with venues
docker compose down -v
docker compose up -d db
# Wait for database to be healthy
~/load-venues.sh
```

## Adding More Areas

### Lancaster, PA Example

```bash
# Fetch Lancaster venues (25km radius)
node ~/fetch-google-venues.js --location "Lancaster, PA" --radius 25000 > database/venues-google-lancaster.sql 2>/dev/null

# Load into database
docker exec -i footballhome_db psql -U footballhome_user -d footballhome < database/venues-google-lancaster.sql
```

### Other Areas

You can fetch venues for any location:

```bash
# By city
node ~/fetch-google-venues.js --location "Camden, NJ" --radius 20000 > database/venues-google-camden.sql 2>/dev/null

# By zip code
node ~/fetch-google-venues.js --location "19102" --radius 15000 > database/venues-google-19102.sql 2>/dev/null

# Specific address
node ~/fetch-google-venues.js --location "1600 Vine St, Philadelphia" --radius 10000 > database/venues-google-vine.sql 2>/dev/null
```

## Venue Data Structure

Each venue includes:

```sql
INSERT INTO venues (
    name,                           -- Venue name
    venue_type,                     -- 'field', 'stadium', 'indoor'
    formatted_address,              -- Full address
    city, state, postal_code,       -- Address components
    latitude, longitude,            -- GPS coordinates
    surface_type,                   -- 'grass', 'artificial_turf'
    phone,                          -- Phone number
    international_phone_number,     -- +1 format
    website,                        -- Venue website
    place_id,                       -- Google Places unique ID
    rating,                         -- 1.0-5.0
    user_ratings_total,             -- Number of reviews
    price_level,                    -- 0-4 (if available)
    business_status,                -- 'OPERATIONAL', etc.
    google_types,                   -- JSON array of types
    opening_hours,                  -- JSON object with hours
    photos,                         -- JSON array of photo references
    data_source,                    -- 'google_places'
    last_google_update,             -- Timestamp
    is_active                       -- true
);
```

## Querying Venues

### View All Google Venues

```sql
SELECT name, city, state, rating, user_ratings_total
FROM venues
WHERE data_source = 'google_places'
ORDER BY rating DESC NULLS LAST;
```

### Top Rated Venues

```sql
SELECT name, city, rating, user_ratings_total
FROM venues
WHERE data_source = 'google_places'
  AND rating >= 4.5
ORDER BY rating DESC, user_ratings_total DESC;
```

### Venues by Type

```sql
SELECT venue_type, COUNT(*), AVG(rating)::numeric(3,1) as avg_rating
FROM venues
WHERE data_source = 'google_places'
GROUP BY venue_type;
```

### Find Nearby Venues

```sql
-- Venues within bounding box of Philadelphia
SELECT name, city, rating,
       latitude, longitude
FROM venues
WHERE data_source = 'google_places'
  AND latitude BETWEEN 39.8 AND 40.1
  AND longitude BETWEEN -75.3 AND -75.0
ORDER BY rating DESC;
```

## Cost Analysis

### One-Time Fetch (Per Area)

Google Places API pricing:
- **Geocoding:** $5 per 1,000 requests = $0.005 per search
- **Nearby Search:** $32 per 1,000 requests = ~$0.13 (4 queries)
- **Place Details:** $17 per 1,000 requests = ~$1.15 (68 venues)

**Total per area:** ~$1.30 for 68 venues

### Benefits of SQL Storage

- **No recurring costs** - Pay once, use forever
- **Fast rebuilds** - No API calls during development
- **Consistent data** - Same venues every time
- **Offline development** - No internet needed for rebuilds
- **Version control** - Commit SQL files to git

## Maintenance

### Updating Venue Data

To refresh venue data (ratings, hours, etc.):

```bash
# Re-fetch from Google (costs ~$1.30)
node ~/fetch-google-venues.js --location "Philadelphia, PA" --radius 50000 > database/venues-google-philadelphia.sql 2>/dev/null

# Reload into database
docker exec -i footballhome_db psql -U footballhome_user -d footballhome < database/venues-google-philadelphia.sql
```

The `ON CONFLICT (place_id) DO NOTHING` ensures no duplicates.

### Adding Manual Venues

You can still add venues manually:

```sql
INSERT INTO venues (
    name, venue_type, formatted_address,
    city, state, postal_code, country,
    surface_type, data_source, is_active
) VALUES (
    'Custom Training Field', 'field', '123 Main St',
    'Philadelphia', 'PA', '19102', 'USA',
    'grass', 'user_added', true
);
```

## Integration with init.sql

The `database/schema/init.sql` file includes documentation about loading venues:

```sql
-- ========================================
-- GOOGLE PLACES VENUES DATA
-- ========================================
-- Venues fetched from Google Places API and saved as static SQL inserts
-- This avoids API costs on every rebuild
-- 
-- Files:
--   - venues-google-philadelphia.sql: Philadelphia area (50km, 68 venues)
--
-- To load: docker exec -i footballhome_db psql -U footballhome_user -d footballhome < database/venues-google-philadelphia.sql
```

## Troubleshooting

### "INSERT 0 0" Messages

This is normal - means venues already exist (ON CONFLICT handling).

### No Venues Found

```bash
# Check if venues loaded
docker exec footballhome_db psql -U footballhome_user -d footballhome -c "SELECT COUNT(*) FROM venues WHERE data_source='google_places';"
```

### API Errors

- Check API key is valid
- Ensure Places API is enabled in Google Cloud Console
- Verify billing is set up
- Check daily quota limits

### Container Not Running

```bash
# Check container status
docker compose ps

# Start database if needed
docker compose up -d db
```

## Summary

✅ **68 venues** loaded from Google Places  
✅ **$1.30 one-time cost** (no recurring fees)  
✅ **Fast rebuilds** (no API calls)  
✅ **Production-ready** data with ratings, hours, photos  
✅ **Expandable** to other geographic areas  
✅ **Version controlled** SQL files  

You now have a complete, cost-effective venue management system that integrates seamlessly with your database rebuild process!
