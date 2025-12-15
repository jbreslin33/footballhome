const Scraper = require('../base/Scraper');
const ApiClient = require('../fetchers/ApiClient');
const IdGenerator = require('../services/IdGenerator');
const SqlGenerator = require('../services/SqlGenerator');
const Venue = require('../models/Venue');

/**
 * Google Places Venue Scraper
 * Fetches soccer fields and venues from Google Places API
 */
class VenueScraper extends Scraper {
  constructor(mode = 'full', options = {}) {
    super({
      name: 'Google Places Venues',
      mode: mode,
      includeSchedules: false,
      teamFilter: null
    });

    this.searchLocation = options.location || { lat: 39.9526, lng: -75.1652 }; // Philadelphia default
    this.searchRadius = options.radius || 50000; // 50km default
    this.searchType = options.type || 'soccer'; // Can be: soccer, park, stadium
    
    // Google Places API client
    const apiKey = process.env.GOOGLE_PLACES_API_KEY;
    if (!apiKey) {
      throw new Error('GOOGLE_PLACES_API_KEY environment variable not set');
    }
    
    this.apiClient = new ApiClient({
      baseUrl: 'https://maps.googleapis.com/maps/api/place',
      authType: 'query',
      apiKey: apiKey,
      apiKeyName: 'key'
    });
    
    this.sqlGenerator = new SqlGenerator();
    this.existingPlaceIds = new Set();
  }

  async initialize() {
    this.log('Initializing Google Places venue scraper...');
    this.log(`Search location: ${this.searchLocation.lat}, ${this.searchLocation.lng}`);
    this.log(`Search radius: ${this.searchRadius}m`);
    this.log(`Search type: ${this.searchType}`);
    
    // Load existing place_ids to avoid duplicates
    await this.loadExistingPlaceIds();
  }

  async loadExistingPlaceIds() {
    // TODO: Query database for existing place_ids
    // For now, this is a placeholder
    this.log('Loading existing place_ids from database...');
    // const result = await db.query('SELECT place_id FROM venues WHERE place_id IS NOT NULL');
    // result.rows.forEach(row => this.existingPlaceIds.add(row.place_id));
  }

  async fetchData() {
    await this.searchNearbyVenues();
  }

  async searchNearbyVenues() {
    this.log('\n🔍 Searching for nearby venues...');
    
    try {
      // Nearby Search API
      const params = {
        location: `${this.searchLocation.lat},${this.searchLocation.lng}`,
        radius: this.searchRadius,
        type: this.searchType,
        keyword: 'soccer field'
      };
      
      const response = await this.apiClient.fetch('/nearbysearch/json', params);
      
      if (!response.results || response.results.length === 0) {
        this.log('   No venues found');
        return;
      }
      
      this.log(`   Found ${response.results.length} venues`);
      
      // Process each venue
      for (const result of response.results) {
        await this.processVenue(result);
      }
      
      // Handle pagination
      if (response.next_page_token) {
        await this.fetchNextPage(response.next_page_token);
      }
      
    } catch (error) {
      this.logError('Failed to search venues', error);
    }
  }

  async fetchNextPage(pageToken) {
    // Google requires a brief delay before using next_page_token
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    this.log('\n📄 Fetching next page...');
    
    try {
      const response = await this.apiClient.fetch('/nearbysearch/json', {
        pagetoken: pageToken
      });
      
      if (response.results && response.results.length > 0) {
        this.log(`   Found ${response.results.length} more venues`);
        
        for (const result of response.results) {
          await this.processVenue(result);
        }
        
        if (response.next_page_token) {
          await this.fetchNextPage(response.next_page_token);
        }
      }
    } catch (error) {
      this.logError('Failed to fetch next page', error);
    }
  }

  async processVenue(result) {
    const placeId = result.place_id;
    
    // Skip if already exists
    if (this.existingPlaceIds.has(placeId)) {
      this.log(`   ⊘ Skipping ${result.name} (already exists)`);
      return;
    }
    
    // Fetch detailed place information
    try {
      const details = await this.fetchPlaceDetails(placeId);
      const venue = this.createVenueFromDetails(result, details);
      
      this.data.venues.set(venue.id, venue);
      this.existingPlaceIds.add(placeId);
      this.log(`   ✓ ${venue.name}`);
      
    } catch (error) {
      this.logError(`Failed to fetch details for ${result.name}`, error);
    }
  }

  async fetchPlaceDetails(placeId) {
    const response = await this.apiClient.fetch('/details/json', {
      place_id: placeId,
      fields: 'name,formatted_address,address_components,geometry,formatted_phone_number,international_phone_number,website,opening_hours,rating,user_ratings_total,price_level,business_status,types,photos'
    });
    
    return response.result || {};
  }

  createVenueFromDetails(basicInfo, details) {
    const id = IdGenerator.fromComponents('venue', 'google', basicInfo.place_id);
    
    // Parse address components
    const addressComponents = this.parseAddressComponents(details.address_components || []);
    
    // Parse photos
    const photos = details.photos ? details.photos.map(photo => ({
      photo_reference: photo.photo_reference,
      width: photo.width,
      height: photo.height
    })) : null;
    
    return new Venue({
      id: id,
      name: details.name || basicInfo.name,
      venue_type: this.determineVenueType(details.types || basicInfo.types || []),
      formatted_address: details.formatted_address || basicInfo.vicinity,
      city: addressComponents.city,
      state: addressComponents.state,
      postal_code: addressComponents.postal_code,
      country: addressComponents.country || 'United States',
      latitude: details.geometry?.location?.lat || basicInfo.geometry?.location?.lat,
      longitude: details.geometry?.location?.lng || basicInfo.geometry?.location?.lng,
      surface_type: 'grass', // Default - could be enhanced with AI/photos analysis
      phone: details.formatted_phone_number,
      international_phone_number: details.international_phone_number,
      website: details.website,
      place_id: basicInfo.place_id,
      rating: details.rating || basicInfo.rating,
      user_ratings_total: details.user_ratings_total || basicInfo.user_ratings_total,
      price_level: details.price_level,
      business_status: details.business_status || 'OPERATIONAL',
      google_types: details.types || basicInfo.types,
      opening_hours: details.opening_hours ? {
        open_now: details.opening_hours.open_now,
        weekday_text: details.opening_hours.weekday_text
      } : null,
      photos: photos,
      data_source: 'google_places',
      last_google_update: new Date().toISOString()
    });
  }

  parseAddressComponents(components) {
    const result = {
      city: null,
      state: null,
      postal_code: null,
      country: null
    };
    
    for (const component of components) {
      if (component.types.includes('locality')) {
        result.city = component.long_name;
      } else if (component.types.includes('administrative_area_level_1')) {
        result.state = component.short_name;
      } else if (component.types.includes('postal_code')) {
        result.postal_code = component.long_name;
      } else if (component.types.includes('country')) {
        result.country = component.long_name;
      }
    }
    
    return result;
  }

  determineVenueType(types) {
    if (types.includes('stadium')) return 'stadium';
    if (types.includes('park')) return 'park';
    return 'field';
  }

  async transformData() {
    // No transformation needed
  }

  async generateOutput() {
    this.log('\n💾 Generating SQL output...');
    
    const results = await this.sqlGenerator.generateMultiple([
      {
        filename: '02-venues-google.sql',
        data: this.data.venues,
        options: {
          title: 'Google Places Venues',
          useInserts: true
        }
      }
    ]);
    
    for (const result of results) {
      this.logSuccess(`${result.filepath}: ${result.count} records`);
    }
  }

  async cleanup() {
    // No cleanup needed
  }
}

module.exports = VenueScraper;
