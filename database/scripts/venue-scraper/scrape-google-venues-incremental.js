#!/usr/bin/env node
/**
 * Google Places Venue Scraper - Incremental Mode
 * 
 * Usage:
 *   node scrape-google-venues-incremental.js <existing_place_ids_file>
 * 
 * This script:
 * 1. Reads existing place_ids from stdin or file
 * 2. Fetches venues from Google Places API
 * 3. Filters out duplicates (by place_id)
 * 4. Outputs NEW venues only in COPY format (tab-separated)
 * 
 * Output format (COPY): One row per line, tab-separated values
 * id\tname\tvenue_type\tformatted_address\t...
 */

const fs = require('fs');
const { v4: uuidv4 } = require('uuid');

// Read existing place_ids to skip
const existingPlaceIds = new Set();

if (process.argv[2]) {
  // Read from file
  const lines = fs.readFileSync(process.argv[2], 'utf8').split('\n');
  lines.forEach(line => {
    const placeId = line.trim();
    if (placeId) existingPlaceIds.add(placeId);
  });
} else {
  // Read from stdin
  const stdin = fs.readFileSync(0, 'utf-8');
  stdin.split('\n').forEach(line => {
    const placeId = line.trim();
    if (placeId) existingPlaceIds.add(placeId);
  });
}

console.error(`Loaded ${existingPlaceIds.size} existing place_ids to skip`);

/**
 * Fetch venues from Google Places API
 * TODO: Implement actual API calls
 * For now, this is a placeholder
 */
async function fetchNewVenues() {
  const newVenues = [];
  
  // TODO: Replace with actual Google Places API calls
  // Example:
  // const apiKey = process.env.GOOGLE_PLACES_API_KEY;
  // const response = await fetch(`https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=39.9526,-75.1652&radius=50000&type=soccer&key=${apiKey}`);
  // const data = await response.json();
  
  // For now, simulate finding new venues
  console.error('⚠️  Using mock data - implement actual Google Places API calls');
  
  // Mock venue data
  const mockVenues = [
    {
      place_id: 'ChIJEXAMPLE001',
      name: 'New Soccer Field 1',
      formatted_address: '123 New St, Philadelphia, PA 19103, USA',
      rating: 4.5,
      user_ratings_total: 100,
    },
    {
      place_id: 'ChIJEXAMPLE002',
      name: 'New Soccer Field 2',
      formatted_address: '456 New Ave, Philadelphia, PA 19104, USA',
      rating: 4.7,
      user_ratings_total: 85,
    },
  ];
  
  // Filter out existing venues
  for (const venue of mockVenues) {
    if (!existingPlaceIds.has(venue.place_id)) {
      newVenues.push(venue);
    } else {
      console.error(`Skipping duplicate: ${venue.name} (${venue.place_id})`);
    }
  }
  
  return newVenues;
}

/**
 * Convert venue to COPY format (tab-separated)
 */
function venueToCopyFormat(venue) {
  const id = uuidv4();
  const now = new Date().toISOString();
  
  // Escape special characters for PostgreSQL COPY format
  const escape = (val) => {
    if (val === null || val === undefined) return '\\N'; // NULL
    if (typeof val === 'object') return JSON.stringify(val).replace(/\\/g, '\\\\').replace(/\t/g, '\\t').replace(/\n/g, '\\n');
    return String(val).replace(/\\/g, '\\\\').replace(/\t/g, '\\t').replace(/\n/g, '\\n');
  };
  
  // COPY format: all columns tab-separated
  // Order must match: id, name, venue_type, formatted_address, city, state, postal_code, country,
  //                   latitude, longitude, surface_type, phone, international_phone_number, website,
  //                   place_id, rating, user_ratings_total, price_level, business_status,
  //                   google_types, opening_hours, photos, data_source, last_google_update, is_active,
  //                   created_at, updated_at
  
  return [
    id,
    escape(venue.name),
    escape(venue.venue_type || 'field'),
    escape(venue.formatted_address),
    escape(venue.city),
    escape(venue.state),
    escape(venue.postal_code),
    escape(venue.country || 'United States'),
    escape(venue.latitude),
    escape(venue.longitude),
    escape(venue.surface_type || 'grass'),
    escape(venue.phone),
    escape(venue.international_phone_number),
    escape(venue.website),
    escape(venue.place_id),
    escape(venue.rating),
    escape(venue.user_ratings_total),
    escape(venue.price_level),
    escape(venue.business_status || 'OPERATIONAL'),
    escape(venue.google_types),
    escape(venue.opening_hours),
    escape(venue.photos),
    escape('google_places'),
    escape(now),
    escape('true'),
    escape(now),
    escape(now),
  ].join('\t');
}

/**
 * Main execution
 */
async function main() {
  try {
    const newVenues = await fetchNewVenues();
    
    if (newVenues.length === 0) {
      console.error('No new venues found');
      process.exit(0);
    }
    
    console.error(`Found ${newVenues.length} new venues`);
    console.error('');
    
    // Output in COPY format (to stdout)
    for (const venue of newVenues) {
      console.log(venueToCopyFormat(venue));
    }
    
    console.error('');
    console.error(`✓ Output ${newVenues.length} new venues in COPY format`);
    
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

main();
