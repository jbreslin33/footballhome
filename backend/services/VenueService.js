const GeocodingService = require('./GeocodingService');

class VenueService {
    constructor(db) {
        this.db = db;
        this.geocoding = new GeocodingService();
    }

    // Add venue with deduplication check
    async addVenue(venueData) {
        try {
            const { name, address, team_id, user_id } = venueData;

            // Step 1: Geocode the address
            console.log(`Processing venue: ${name} at ${address}`);
            const geocodeData = await this.geocoding.geocode(address);

            // Step 2: Check for nearby existing venues
            const nearbyVenues = await this.findNearbyVenues(
                geocodeData.latitude, 
                geocodeData.longitude, 
                0.1 // 0.1 miles radius
            );

            // Step 3: If similar venues exist, return suggestions
            if (nearbyVenues.length > 0) {
                return {
                    status: 'duplicate_detected',
                    message: 'Similar venues found nearby',
                    suggested_venues: nearbyVenues,
                    geocoded_data: geocodeData,
                    can_create_anyway: true
                };
            }

            // Step 4: Create new venue
            const venue = await this.createVenue({
                name,
                address,
                formatted_address: geocodeData.formatted_address,
                latitude: geocodeData.latitude,
                longitude: geocodeData.longitude,
                place_id: geocodeData.place_id,
                confidence: geocodeData.confidence,
                geocoding_provider: 'google',
                created_by_team_id: team_id,
                created_by_user_id: user_id
            });

            return {
                status: 'created',
                venue: venue,
                geocoded_data: geocodeData
            };

        } catch (error) {
            console.error('Error adding venue:', error);
            throw error;
        }
    }

    // Find venues within specified distance
    async findNearbyVenues(latitude, longitude, radiusMiles = 0.1) {
        const query = `
            SELECT 
                venue_id,
                name,
                address,
                formatted_address,
                latitude,
                longitude,
                (
                    3959 * acos(
                        cos(radians($1)) * cos(radians(latitude)) *
                        cos(radians(longitude) - radians($2)) +
                        sin(radians($1)) * sin(radians(latitude))
                    )
                ) AS distance_miles
            FROM venues
            WHERE (
                3959 * acos(
                    cos(radians($1)) * cos(radians(latitude)) *
                    cos(radians(longitude) - radians($2)) +
                    sin(radians($1)) * sin(radians(latitude))
                )
            ) <= $3
            ORDER BY distance_miles
            LIMIT 5;
        `;
        
        const result = await this.db.query(query, [latitude, longitude, radiusMiles]);
        return result.rows;
    }

    // Create new venue in database
    async createVenue(venueData) {
        const query = `
            INSERT INTO venues (
                venue_id, name, address, formatted_address, 
                latitude, longitude, place_id, confidence,
                geocoding_provider, created_by_team_id, created_by_user_id,
                created_at
            ) VALUES (
                gen_random_uuid(), $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW()
            ) RETURNING *;
        `;

        const values = [
            venueData.name,
            venueData.address,
            venueData.formatted_address,
            venueData.latitude,
            venueData.longitude,
            venueData.place_id,
            venueData.confidence,
            venueData.geocoding_provider,
            venueData.created_by_team_id,
            venueData.created_by_user_id
        ];

        const result = await this.db.query(query, values);
        return result.rows[0];
    }

    // Force create venue even if duplicates exist
    async forceCreateVenue(venueData) {
        return await this.createVenue(venueData);
    }

    // Get geocoding service usage stats
    getGeocodingStats() {
        return this.geocoding.getUsageStats();
    }
}

module.exports = VenueService;