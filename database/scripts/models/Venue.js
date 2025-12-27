const SqlGenerator = require('../services/SqlGenerator');

/**
 * Venue Model
 * Represents a sports venue
 */
class Venue {
  constructor(data) {
    this.id = data.id;
    this.name = data.name;
    this.venue_type = data.venue_type || 'field';
    this.formatted_address = data.formatted_address || null;
    this.city = data.city || null;
    this.state = data.state || null;
    this.postal_code = data.postal_code || null;
    this.country = data.country || 'United States';
    this.latitude = data.latitude || null;
    this.longitude = data.longitude || null;
    this.surface_type = data.surface_type || null;
    this.phone = data.phone || null;
    this.international_phone_number = data.international_phone_number || null;
    this.website = data.website || null;
    
    // Google Places data
    this.place_id = data.place_id || null;
    this.google_maps_url = data.google_maps_url || null;
    this.rating = data.rating || null;
    this.user_ratings_total = data.user_ratings_total || null;
    this.price_level = data.price_level || null;
    this.business_status = data.business_status || null;
    this.google_types = data.google_types || null;
    this.opening_hours = data.opening_hours || null;
    this.photos = data.photos || null;
    
    this.data_source = data.data_source || 'google_places';
    this.last_google_update = data.last_google_update || null;
    this.is_active = data.is_active !== false;
  }

  toSQL() {
    return `INSERT INTO venues (id, name, venue_type, formatted_address, city, state, postal_code, country, latitude, longitude, surface_type, phone, international_phone_number, website, place_id, google_maps_url, rating, user_ratings_total, price_level, business_status, google_types, opening_hours, photos, data_source, last_google_update, is_active)
VALUES (
  ${SqlGenerator.escape(this.id)},
  ${SqlGenerator.escape(this.name)},
  ${SqlGenerator.escape(this.venue_type)},
  ${SqlGenerator.escape(this.formatted_address)},
  ${SqlGenerator.escape(this.city)},
  ${SqlGenerator.escape(this.state)},
  ${SqlGenerator.escape(this.postal_code)},
  ${SqlGenerator.escape(this.country)},
  ${SqlGenerator.escape(this.latitude)},
  ${SqlGenerator.escape(this.longitude)},
  ${SqlGenerator.escape(this.surface_type)},
  ${SqlGenerator.escape(this.phone)},
  ${SqlGenerator.escape(this.international_phone_number)},
  ${SqlGenerator.escape(this.website)},
  ${SqlGenerator.escape(this.place_id)},
  ${SqlGenerator.escape(this.google_maps_url)},
  ${SqlGenerator.escape(this.rating)},
  ${SqlGenerator.escape(this.user_ratings_total)},
  ${SqlGenerator.escape(this.price_level)},
  ${SqlGenerator.escape(this.business_status)},
  ${SqlGenerator.escape(this.google_types)},
  ${SqlGenerator.escape(this.opening_hours)},
  ${SqlGenerator.escape(this.photos)},
  ${SqlGenerator.escape(this.data_source)},
  ${SqlGenerator.escape(this.last_google_update)},
  ${SqlGenerator.escape(this.is_active)}
)
ON CONFLICT (place_id) DO UPDATE SET
  name = EXCLUDED.name,
  formatted_address = EXCLUDED.formatted_address,
  rating = EXCLUDED.rating,
  user_ratings_total = EXCLUDED.user_ratings_total,
  last_google_update = EXCLUDED.last_google_update,
  updated_at = EXCLUDED.updated_at;`;
  }
}

module.exports = Venue;
