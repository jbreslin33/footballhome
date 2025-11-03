require('dotenv').config({ path: '../../.env' });
const { Pool } = require('pg');
const GeocodingService = require('./GeocodingService');
const GooglePlacesService = require('./GooglePlacesService');

class VenueService {
    constructor(db = null) {
        // Use provided db connection or create new pool
        this.db = db || new Pool({
            user: process.env.POSTGRES_USER || 'postgres',
            host: process.env.POSTGRES_HOST || 'localhost',
            database: process.env.POSTGRES_DB || 'footballhome',
            password: process.env.POSTGRES_PASSWORD || 'password',
            port: process.env.POSTGRES_PORT || 5432,
        });
        
        this.geocoding = new GeocodingService();
        this.places = new GooglePlacesService();
        console.log('✅ VenueService initialized with Google Places integration');
    }

    // Add venue with deduplication check
    async addVenue(venueData) {
        try {
            const { 
                name, 
                address, 
                city,
                state,
                zip_code,
                country = 'US',
                phone,
                email,
                website,
                capacity,
                field_type,
                surface_type,
                has_lights,
                has_parking,
                description,
                team_id, 
                user_id 
            } = venueData;

            // Validate required fields
            if (!name || !address) {
                throw new Error('Venue name and address are required');
            }

            // Build full address for geocoding
            const fullAddress = `${address}, ${city || ''}, ${state || ''} ${zip_code || ''}, ${country}`.trim();

            // Step 1: Geocode the address
            console.log(`🏟️  Processing venue: ${name} at ${fullAddress}`);
            const geocodeData = await this.geocoding.geocode(fullAddress);

            // Step 2: Check for nearby existing venues
            const nearbyVenues = await this.findNearbyVenues(
                geocodeData.latitude, 
                geocodeData.longitude, 
                0.1 // 0.1 miles radius
            );

            // Step 3: If similar venues exist, return suggestions
            if (nearbyVenues.length > 0) {
                console.log(`⚠️  Found ${nearbyVenues.length} similar venues nearby`);
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
                city,
                state,
                zip_code,
                country,
                phone,
                email,
                website,
                capacity,
                field_type,
                surface_type,
                has_lights,
                has_parking,
                description,
                formatted_address: geocodeData.formatted_address,
                latitude: geocodeData.latitude,
                longitude: geocodeData.longitude,
                place_id: geocodeData.place_id,
                confidence: geocodeData.confidence,
                geocoding_provider: 'google',
                created_by_team_id: team_id,
                created_by_user_id: user_id
            });

            console.log(`✅ Venue created: ${venue.name} (ID: ${venue.venue_id})`);

            return {
                status: 'created',
                venue: venue,
                geocoded_data: geocodeData
            };

        } catch (error) {
            console.error('❌ Error adding venue:', error.message);
            throw error;
        }
    }

    // Find venues within specified distance
    async findNearbyVenues(latitude, longitude, radiusMiles = 0.1) {
        const query = `
            SELECT 
                id,
                name,
                address,
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
            WHERE is_active = TRUE 
              AND latitude IS NOT NULL 
              AND longitude IS NOT NULL
              AND (
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

    // Create new venue in database with Google Places data
    async createVenue(venueData) {
        const query = `
            INSERT INTO venues (
                name, venue_type, address, city, state, postal_code, country,
                phone, email, website, capacity, surface_type,
                parking_available, notes,
                latitude, longitude,
                place_id, rating, user_ratings_total, price_level, business_status,
                google_types, opening_hours, photos, formatted_address, 
                international_phone_number, data_source, last_google_update,
                created_at, updated_at
            ) VALUES (
                $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16,
                $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, NOW(), NOW()
            ) RETURNING id, name, venue_type, address, city, state, latitude, longitude, 
                       place_id, rating, data_source, created_at;
        `;

        const values = [
            venueData.name,
            venueData.venue_type || 'stadium', // Default to stadium
            venueData.address,
            venueData.city,
            venueData.state,
            venueData.zip_code,
            venueData.country,
            venueData.phone,
            venueData.email,
            venueData.website,
            venueData.capacity,
            venueData.surface_type,
            venueData.has_parking,
            venueData.description,
            venueData.latitude,
            venueData.longitude,
            // Google Places specific fields
            venueData.place_id || null,
            venueData.rating || null,
            venueData.user_ratings_total || 0,
            venueData.price_level || null,
            venueData.business_status || null,
            venueData.google_types ? JSON.stringify(venueData.google_types) : null,
            venueData.opening_hours ? JSON.stringify(venueData.opening_hours) : null,
            venueData.photos ? JSON.stringify(venueData.photos) : null,
            venueData.formatted_address || null,
            venueData.international_phone_number || null,
            venueData.data_source || 'google_places',
            venueData.data_source === 'google_places' ? new Date() : null
        ];

        const result = await this.db.query(query, values);
        return result.rows[0];
    }

    // Force create venue even if duplicates exist
    async forceCreateVenue(venueData) {
        return await this.createVenue(venueData);
    }

    // Get venue by ID
    async getVenueById(venueId) {
        try {
            const query = `
                SELECT id, name, address, city, state, postal_code, country,
                       phone, email, website, capacity, surface_type,
                       parking_available, notes,
                       latitude, longitude, rating, data_source, place_id,
                       created_at, updated_at
                FROM venues 
                WHERE id = $1 AND is_active = TRUE
            `;
            
            const result = await this.db.query(query, [venueId]);
            return result.rows.length > 0 ? result.rows[0] : null;
        } catch (error) {
            console.error('❌ Error getting venue:', error.message);
            throw error;
        }
    }

    // Get all venues with pagination and search
    async getVenues({ page = 1, limit = 20, search = null } = {}) {
        try {
            const offset = (page - 1) * limit;
            let query = `
                SELECT id, name, venue_type, address, city, state, postal_code, country,
                       phone, email, website, capacity, surface_type,
                       parking_available, notes,
                       latitude, longitude, rating, data_source, place_id,
                       created_at, updated_at
                FROM venues 
                WHERE is_active = TRUE
            `;
            
            const queryParams = [];
            let paramIndex = 1;

            if (search) {
                query += ` AND (
                    name ILIKE $${paramIndex} OR 
                    address ILIKE $${paramIndex} OR 
                    city ILIKE $${paramIndex} OR
                    notes ILIKE $${paramIndex}
                )`;
                queryParams.push(`%${search}%`);
                paramIndex++;
            }

            query += ` ORDER BY name ASC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
            queryParams.push(limit, offset);

            const result = await this.db.query(query, queryParams);

            // Get total count
            let countQuery = 'SELECT COUNT(*) FROM venues WHERE is_active = TRUE';
            const countParams = [];
            if (search) {
                countQuery += ` AND (
                    name ILIKE $1 OR 
                    address ILIKE $1 OR 
                    city ILIKE $1 OR
                    notes ILIKE $1
                )`;
                countParams.push(`%${search}%`);
            }

            const countResult = await this.db.query(countQuery, countParams);
            const totalCount = parseInt(countResult.rows[0].count);

            return {
                venues: result.rows,
                pagination: {
                    page,
                    limit,
                    total: totalCount,
                    pages: Math.ceil(totalCount / limit)
                }
            };
        } catch (error) {
            console.error('❌ Error getting venues:', error.message);
            throw error;
        }
    }

    // Update venue coordinates by geocoding
    async updateVenueCoordinates(venueId) {
        try {
            // Get venue address
            const venueResult = await this.db.query(
                'SELECT name, address, city, state, zip_code, country FROM venues WHERE venue_id = $1',
                [venueId]
            );

            if (venueResult.rows.length === 0) {
                throw new Error('Venue not found');
            }

            const venue = venueResult.rows[0];
            const fullAddress = `${venue.address}, ${venue.city || ''}, ${venue.state || ''} ${venue.zip_code || ''}, ${venue.country}`.trim();

            console.log(`🔄 Updating coordinates for venue: ${venue.name}`);

            // Geocode the address
            const geocodeData = await this.geocoding.geocode(fullAddress);

            // Update venue with coordinates
            const updateQuery = `
                UPDATE venues 
                SET latitude = $1, longitude = $2, geocoded_address = $3, 
                    place_id = $4, geocode_confidence = $5, updated_at = NOW()
                WHERE venue_id = $6
                RETURNING venue_id, name, latitude, longitude
            `;

            const updateResult = await this.db.query(updateQuery, [
                geocodeData.latitude,
                geocodeData.longitude,
                geocodeData.formatted_address,
                geocodeData.place_id,
                geocodeData.confidence,
                venueId
            ]);

            const updatedVenue = updateResult.rows[0];
            console.log(`✅ Updated coordinates for ${updatedVenue.name}: ${updatedVenue.latitude}, ${updatedVenue.longitude}`);

            return updatedVenue;
        } catch (error) {
            console.error('❌ Error updating venue coordinates:', error.message);
            throw error;
        }
    }

    // Get venues without coordinates
    async getVenuesWithoutCoordinates(limit = 10) {
        try {
            const query = `
                SELECT venue_id, name, address, city, state, zip_code, country
                FROM venues 
                WHERE deleted = FALSE 
                  AND (latitude IS NULL OR longitude IS NULL)
                ORDER BY created_at ASC
                LIMIT $1
            `;

            const result = await this.db.query(query, [limit]);
            return result.rows;
        } catch (error) {
            console.error('❌ Error getting venues without coordinates:', error.message);
            throw error;
        }
    }

    // Batch geocode venues
    async batchGeocodeVenues(limit = 5) {
        try {
            const venues = await this.getVenuesWithoutCoordinates(limit);
            
            if (venues.length === 0) {
                console.log('✅ All venues have coordinates');
                return [];
            }

            console.log(`🔄 Batch geocoding ${venues.length} venues...`);
            
            const results = [];
            for (const venue of venues) {
                try {
                    const result = await this.updateVenueCoordinates(venue.venue_id);
                    results.push({ success: true, venue: result });
                    
                    // Add delay to respect rate limits
                    await new Promise(resolve => setTimeout(resolve, 200));
                } catch (error) {
                    console.error(`❌ Failed to geocode venue ${venue.name}:`, error.message);
                    results.push({ success: false, venue, error: error.message });
                }
            }

            return results;
        } catch (error) {
            console.error('❌ Error in batch geocoding:', error.message);
            throw error;
        }
    }

    // Get service statistics
    async getStats() {
        try {
            const stats = await this.db.query(`
                SELECT 
                    COUNT(*) as total_venues,
                    COUNT(*) FILTER (WHERE latitude IS NOT NULL AND longitude IS NOT NULL) as geocoded_venues,
                    COUNT(*) FILTER (WHERE latitude IS NULL OR longitude IS NULL) as pending_geocoding
                FROM venues 
                WHERE deleted = FALSE
            `);

            const geocodingStats = this.geocoding.getUsageStats();

            return {
                venues: stats.rows[0],
                geocoding: geocodingStats
            };
        } catch (error) {
            console.error('❌ Error getting venue statistics:', error.message);
            throw error;
        }
    }

    // Get geocoding service usage stats
    getGeocodingStats() {
        return this.geocoding.getUsageStats();
    }

    // Import soccer venues from Google Places in a specific area
    async importSoccerVenuesFromArea(latitude, longitude, radiusKm = 50, venueType = 'all') {
        try {
            const radiusMeters = radiusKm * 1000;
            console.log(`🔍 Searching for soccer venues within ${radiusKm}km of ${latitude}, ${longitude}`);
            
            // Search Google Places for soccer venues
            const googleVenues = await this.places.searchSoccerVenues(latitude, longitude, radiusMeters, venueType);
            
            if (googleVenues.length === 0) {
                console.log('ℹ️ No soccer venues found in this area');
                return { imported: 0, skipped: 0, errors: 0, venues: [] };
            }

            const results = {
                imported: 0,
                skipped: 0,
                errors: 0,
                venues: []
            };

            for (const googleVenue of googleVenues) {
                try {
                    // Check if venue already exists by place_id
                    const existingVenue = await this.db.query(
                        'SELECT id, name FROM venues WHERE place_id = $1 AND is_active = TRUE',
                        [googleVenue.place_id]
                    );

                    if (existingVenue.rows.length > 0) {
                        console.log(`⚠️ Skipping ${googleVenue.name} - already exists`);
                        results.skipped++;
                        continue;
                    }

                    // Get detailed information from Google Places
                    const detailedVenue = await this.places.getPlaceDetails(googleVenue.place_id);
                    
                    // Determine venue type based on Google Places types
                    const venueTypeMapped = this.mapGoogleTypesToVenueType(googleVenue.types);

                    // Create venue record with full Google Places data
                    const addressComponents = this.extractAddressComponents(detailedVenue.formatted_address);
                    const venueData = {
                        name: detailedVenue.name,
                        venue_type: venueTypeMapped,
                        address: addressComponents.address,
                        city: addressComponents.city,
                        state: addressComponents.state,
                        zip_code: addressComponents.zip,
                        country: 'US', // Default, could be enhanced
                        phone: detailedVenue.phone,
                        email: null,
                        website: detailedVenue.website,
                        capacity: null, // Not available from Places API
                        surface_type: null, // Could be inferred from name/description
                        has_parking: null, // Not directly available
                        description: `Imported from Google Places. Rating: ${detailedVenue.rating || 'N/A'}/5 (${detailedVenue.user_ratings_total || 0} reviews)`,
                        latitude: detailedVenue.latitude,
                        longitude: detailedVenue.longitude,
                        // Google Places specific data
                        place_id: detailedVenue.place_id,
                        rating: detailedVenue.rating,
                        user_ratings_total: detailedVenue.user_ratings_total,
                        price_level: null, // Basic search doesn't include price_level
                        business_status: 'OPERATIONAL', // Assume operational if found
                        google_types: googleVenue.types,
                        opening_hours: detailedVenue.opening_hours,
                        photos: detailedVenue.photos,
                        formatted_address: detailedVenue.formatted_address,
                        data_source: 'google_places'
                    };

                    const createdVenue = await this.createVenue(venueData);
                    
                    console.log(`✅ Imported: ${createdVenue.name} (${createdVenue.id})`);
                    results.imported++;
                    results.venues.push(createdVenue);

                    // Rate limiting delay
                    await new Promise(resolve => setTimeout(resolve, 100));

                } catch (error) {
                    console.error(`❌ Error importing ${googleVenue.name}:`, error.message);
                    results.errors++;
                }
            }

            console.log(`📊 Import completed: ${results.imported} imported, ${results.skipped} skipped, ${results.errors} errors`);
            return results;

        } catch (error) {
            console.error('❌ Error importing soccer venues:', error.message);
            throw error;
        }
    }

    // Import famous soccer stadiums
    async importFamousSoccerStadiums(country = 'US') {
        try {
            console.log(`🏟️ Importing famous soccer stadiums for ${country}...`);
            
            const stadiums = await this.places.getFamousSoccerStadiums(country);
            
            const results = {
                imported: 0,
                skipped: 0,
                errors: 0,
                venues: []
            };

            for (const stadium of stadiums) {
                try {
                    // Check if already exists
                    const existing = await this.db.query(
                        'SELECT id FROM venues WHERE place_id = $1 AND is_active = TRUE',
                        [stadium.place_id]
                    );

                    if (existing.rows.length > 0) {
                        results.skipped++;
                        continue;
                    }

                    // Get detailed info
                    const detailed = await this.places.getPlaceDetails(stadium.place_id);
                    
                    const venueData = {
                        name: detailed.name,
                        venue_type: 'stadium',
                        address: this.extractAddressComponents(detailed.formatted_address).address,
                        city: this.extractAddressComponents(detailed.formatted_address).city,
                        state: this.extractAddressComponents(detailed.formatted_address).state,
                        zip_code: this.extractAddressComponents(detailed.formatted_address).zip,
                        country: country,
                        phone: detailed.phone,
                        website: detailed.website,
                        capacity: null,
                        surface_type: 'grass', // Most stadiums
                        has_parking: true, // Most stadiums have parking
                        description: `Professional soccer stadium. Rating: ${detailed.rating || 'N/A'}/5`,
                        latitude: detailed.latitude,
                        longitude: detailed.longitude,
                        place_id: detailed.place_id
                    };

                    const created = await this.createVenue(venueData);
                    results.imported++;
                    results.venues.push(created);

                    await new Promise(resolve => setTimeout(resolve, 200));

                } catch (error) {
                    results.errors++;
                    console.error(`❌ Error importing stadium:`, error.message);
                }
            }

            return results;

        } catch (error) {
            console.error('❌ Error importing famous stadiums:', error.message);
            throw error;
        }
    }

    // Map Google Places types to our venue types
    mapGoogleTypesToVenueType(types) {
        if (types.includes('stadium')) return 'stadium';
        if (types.includes('school') || types.includes('university')) return 'field';
        if (types.includes('park')) return 'field';
        if (types.includes('gym')) return 'gym';
        return 'field'; // Default
    }

    // Extract address components from formatted address
    extractAddressComponents(formattedAddress) {
        if (!formattedAddress) return { address: '', city: '', state: '', zip: '' };
        
        const parts = formattedAddress.split(', ');
        return {
            address: parts[0] || '',
            city: parts[1] || '',
            state: parts[2] ? parts[2].split(' ')[0] : '',
            zip: parts[2] ? parts[2].split(' ')[1] : ''
        };
    }

    // Search for venues by name/location using Google Places
    async searchVenuesByName(query, location = null) {
        try {
            console.log(`🔍 Searching for venues: ${query}`);
            
            const results = await this.places.textSearch(query, location);
            
            // Filter to likely soccer venues
            const soccerVenues = results.filter(venue => {
                const name = venue.name.toLowerCase();
                const types = venue.types.join(' ').toLowerCase();
                
                return name.includes('soccer') || 
                       name.includes('football') || 
                       name.includes('stadium') ||
                       name.includes('field') ||
                       name.includes('pitch') ||
                       types.includes('stadium') ||
                       types.includes('park');
            });

            return soccerVenues;

        } catch (error) {
            console.error('❌ Error searching venues by name:', error.message);
            throw error;
        }
    }

    // Close database connection (if we created our own pool)
    async close() {
        if (this.db && this.db.end) {
            await this.db.end();
            console.log('📊 VenueService database connection closed');
        }
    }
}

module.exports = VenueService;