require('dotenv').config({ path: '../../.env' });
const axios = require('axios');
const NodeCache = require('node-cache');

class GooglePlacesService {
    constructor() {
        this.apiKey = process.env.GOOGLE_MAPS_API_KEY;
        this.cache = new NodeCache({ stdTTL: 86400 }); // 24 hour cache
        this.requestCount = { daily: 0, minute: 0, lastReset: Date.now() };
        this.limits = {
            daily: parseInt(process.env.PLACES_DAILY_LIMIT) || 1000,
            minute: parseInt(process.env.PLACES_RATE_LIMIT) || 60
        };
        
        if (!this.apiKey) {
            console.error('❌ GOOGLE_MAPS_API_KEY not found');
            throw new Error('Google Maps API key is required');
        }
        
        console.log('✅ GooglePlacesService initialized');
    }

    // Search for soccer venues in a specific area
    async searchSoccerVenues(latitude, longitude, radiusMeters = 50000, type = 'all') {
        try {
            const cacheKey = `soccer_venues:${latitude}:${longitude}:${radiusMeters}:${type}`;
            const cached = this.cache.get(cacheKey);
            if (cached) {
                console.log(`📋 Places cache hit for soccer venues near ${latitude}, ${longitude}`);
                return cached;
            }

            this.checkRateLimit();

            // Different search strategies based on type
            let searchQueries = [];
            
            switch (type) {
                case 'professional':
                    searchQueries = ['soccer stadium', 'football stadium', 'MLS stadium'];
                    break;
                case 'amateur':
                    searchQueries = ['soccer field', 'football pitch', 'soccer complex'];
                    break;
                case 'school':
                    searchQueries = ['school soccer field', 'university soccer field', 'college soccer field'];
                    break;
                case 'park':
                    searchQueries = ['park soccer field', 'recreation soccer field', 'public soccer field'];
                    break;
                default:
                    searchQueries = [
                        'soccer field', 'football pitch', 'soccer stadium', 
                        'soccer complex', 'sports complex soccer'
                    ];
            }

            const allVenues = [];
            
            for (const query of searchQueries) {
                console.log(`🔍 Searching for "${query}" near ${latitude}, ${longitude}`);
                
                const venues = await this.nearbySearch(latitude, longitude, radiusMeters, query);
                allVenues.push(...venues);
                
                // Rate limiting delay
                await new Promise(resolve => setTimeout(resolve, 200));
            }

            // Remove duplicates based on place_id
            const uniqueVenues = this.removeDuplicateVenues(allVenues);
            
            // Cache the results
            this.cache.set(cacheKey, uniqueVenues);
            
            console.log(`✅ Found ${uniqueVenues.length} unique soccer venues`);
            return uniqueVenues;

        } catch (error) {
            console.error('❌ Error searching soccer venues:', error.message);
            throw error;
        }
    }

    // Google Places Nearby Search
    async nearbySearch(latitude, longitude, radius, keyword) {
        const url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
        
        const params = {
            location: `${latitude},${longitude}`,
            radius: radius,
            keyword: keyword,
            type: 'establishment',
            key: this.apiKey
        };

        const response = await axios.get(url, { params });
        
        this.requestCount.daily++;
        this.requestCount.minute++;

        if (response.data.status === 'OK') {
            return this.formatPlacesResults(response.data.results);
        } else if (response.data.status === 'ZERO_RESULTS') {
            return [];
        } else {
            throw new Error(`Places API error: ${response.data.status}`);
        }
    }

    // Text search for specific venues
    async textSearch(query, location = null) {
        try {
            const cacheKey = `text_search:${query}:${location}`;
            const cached = this.cache.get(cacheKey);
            if (cached) {
                console.log(`📋 Text search cache hit for: ${query}`);
                return cached;
            }

            this.checkRateLimit();

            const url = 'https://maps.googleapis.com/maps/api/place/textsearch/json';
            
            const params = {
                query: query,
                key: this.apiKey
            };

            if (location) {
                params.location = location;
                params.radius = 50000; // 50km radius
            }

            console.log(`🔍 Text searching for: ${query}`);
            const response = await axios.get(url, { params });
            
            this.requestCount.daily++;
            this.requestCount.minute++;

            let results = [];
            if (response.data.status === 'OK') {
                results = this.formatPlacesResults(response.data.results);
            } else if (response.data.status !== 'ZERO_RESULTS') {
                throw new Error(`Places API error: ${response.data.status}`);
            }

            this.cache.set(cacheKey, results);
            return results;

        } catch (error) {
            console.error('❌ Error in text search:', error.message);
            throw error;
        }
    }

    // Get detailed information about a specific place
    async getPlaceDetails(placeId) {
        try {
            const cacheKey = `place_details:${placeId}`;
            const cached = this.cache.get(cacheKey);
            if (cached) {
                return cached;
            }

            this.checkRateLimit();

            const url = 'https://maps.googleapis.com/maps/api/place/details/json';
            
            const params = {
                place_id: placeId,
                fields: 'name,formatted_address,geometry,formatted_phone_number,website,rating,user_ratings_total,opening_hours,photos',
                key: this.apiKey
            };

            const response = await axios.get(url, { params });
            
            this.requestCount.daily++;
            this.requestCount.minute++;

            if (response.data.status === 'OK') {
                const details = this.formatPlaceDetails(response.data.result);
                this.cache.set(cacheKey, details);
                return details;
            } else {
                throw new Error(`Place Details API error: ${response.data.status}`);
            }

        } catch (error) {
            console.error('❌ Error getting place details:', error.message);
            throw error;
        }
    }

    // Format Places API results to our venue format
    formatPlacesResults(places) {
        return places.map(place => ({
            place_id: place.place_id,
            name: place.name,
            address: place.vicinity || place.formatted_address,
            latitude: place.geometry.location.lat,
            longitude: place.geometry.location.lng,
            rating: place.rating || null,
            user_ratings_total: place.user_ratings_total || 0,
            price_level: place.price_level || null,
            types: place.types || [],
            business_status: place.business_status || null,
            photos: place.photos ? place.photos.map(photo => photo.photo_reference) : [],
            source: 'google_places'
        }));
    }

    // Format detailed place information
    formatPlaceDetails(place) {
        return {
            place_id: place.place_id,
            name: place.name,
            formatted_address: place.formatted_address,
            latitude: place.geometry.location.lat,
            longitude: place.geometry.location.lng,
            phone: place.formatted_phone_number || null,
            website: place.website || null,
            rating: place.rating || null,
            user_ratings_total: place.user_ratings_total || 0,
            opening_hours: place.opening_hours ? {
                open_now: place.opening_hours.open_now,
                periods: place.opening_hours.periods,
                weekday_text: place.opening_hours.weekday_text
            } : null,
            photos: place.photos ? place.photos.map(photo => photo.photo_reference) : [],
            source: 'google_places_detailed'
        };
    }

    // Remove duplicate venues based on place_id and proximity
    removeDuplicateVenues(venues) {
        const uniqueMap = new Map();
        
        venues.forEach(venue => {
            if (!uniqueMap.has(venue.place_id)) {
                uniqueMap.set(venue.place_id, venue);
            }
        });
        
        return Array.from(uniqueMap.values());
    }

    // Famous soccer stadiums search
    async getFamousSoccerStadiums(country = null) {
        const queries = [
            'major league soccer stadium',
            'MLS stadium',
            'professional soccer stadium',
            'famous soccer stadium',
            'premier league stadium',
            'football stadium'
        ];

        if (country) {
            queries.push(`soccer stadium ${country}`);
        }

        const allStadiums = [];
        
        for (const query of queries) {
            try {
                const stadiums = await this.textSearch(query);
                allStadiums.push(...stadiums);
                await new Promise(resolve => setTimeout(resolve, 300));
            } catch (error) {
                console.warn(`⚠️ Query "${query}" failed:`, error.message);
            }
        }

        return this.removeDuplicateVenues(allStadiums);
    }

    // Rate limiting check
    checkRateLimit() {
        const now = Date.now();
        const oneMinute = 60 * 1000;
        const oneDay = 24 * 60 * 60 * 1000;

        if (now - this.requestCount.lastReset > oneMinute) {
            this.requestCount.minute = 0;
            this.requestCount.lastReset = now;
        }

        if (now - this.requestCount.lastReset > oneDay) {
            this.requestCount.daily = 0;
        }

        if (this.requestCount.daily >= this.limits.daily) {
            throw new Error('Daily Places API limit exceeded');
        }
        if (this.requestCount.minute >= this.limits.minute) {
            throw new Error('Minute Places API limit exceeded');
        }
    }

    // Get usage statistics
    getUsageStats() {
        return {
            daily_requests: this.requestCount.daily,
            minute_requests: this.requestCount.minute,
            daily_limit: this.limits.daily,
            minute_limit: this.limits.minute,
            cache_size: this.cache.keys().length,
            cache_stats: this.cache.getStats()
        };
    }

    // Clear cache
    clearCache() {
        this.cache.flushAll();
        console.log('🗑️ Places cache cleared');
    }
}

module.exports = GooglePlacesService;