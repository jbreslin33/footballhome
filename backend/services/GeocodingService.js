require('dotenv').config({ path: '../../.env' });
const axios = require('axios');
const NodeCache = require('node-cache');

class GeocodingService {
    constructor() {
        this.apiKey = process.env.GOOGLE_MAPS_API_KEY;
        this.cache = new NodeCache({ stdTTL: process.env.GEOCODING_CACHE_TTL || 86400 });
        this.requestCount = { daily: 0, minute: 0, lastReset: Date.now() };
        this.limits = {
            daily: parseInt(process.env.GEOCODING_DAILY_LIMIT) || 1000,
            minute: parseInt(process.env.GEOCODING_RATE_LIMIT) || 50
        };
        
        if (!this.apiKey) {
            console.error('❌ GOOGLE_MAPS_API_KEY not found in environment variables');
            throw new Error('Google Maps API key is required');
        }
        
        console.log('✅ GeocodingService initialized with rate limits:', this.limits);
    }

    // Rate limiting check
    checkRateLimit() {
        const now = Date.now();
        const oneMinute = 60 * 1000;
        const oneDay = 24 * 60 * 60 * 1000;

        // Reset minute counter
        if (now - this.requestCount.lastReset > oneMinute) {
            this.requestCount.minute = 0;
            this.requestCount.lastReset = now;
        }

        // Reset daily counter
        if (now - this.requestCount.lastReset > oneDay) {
            this.requestCount.daily = 0;
        }

        // Check limits
        if (this.requestCount.daily >= this.limits.daily) {
            throw new Error('Daily geocoding limit exceeded');
        }
        if (this.requestCount.minute >= this.limits.minute) {
            throw new Error('Minute geocoding limit exceeded');
        }
    }

    // Generate cache key
    getCacheKey(address) {
        return `geocode:${address.toLowerCase().trim()}`;
    }

    // Main geocoding function
    async geocode(address) {
        try {
            // Check cache first
            const cacheKey = this.getCacheKey(address);
            const cached = this.cache.get(cacheKey);
            if (cached) {
                console.log(`📋 Geocode cache hit for: ${address}`);
                return cached;
            }

            // Check rate limits
            this.checkRateLimit();

            // Make API request
            const url = `https://maps.googleapis.com/maps/api/geocode/json`;
            const params = {
                address: address,
                key: this.apiKey
            };

            console.log(`🗺️  Geocoding address: ${address}`);
            const response = await axios.get(url, { params });

            // Update request counters
            this.requestCount.daily++;
            this.requestCount.minute++;

            // Process response
            if (response.data.status === 'OK' && response.data.results.length > 0) {
                const result = response.data.results[0];
                const geocodeData = {
                    latitude: result.geometry.location.lat,
                    longitude: result.geometry.location.lng,
                    formatted_address: result.formatted_address,
                    place_id: result.place_id,
                    confidence: this.calculateConfidence(result),
                    components: this.extractComponents(result.address_components)
                };

                // Cache the result
                this.cache.set(cacheKey, geocodeData);
                
                console.log(`✅ Geocoded successfully: ${geocodeData.formatted_address}`);
                return geocodeData;
            } else {
                throw new Error(`Geocoding failed: ${response.data.status}`);
            }

        } catch (error) {
            console.error(`❌ Geocoding error for "${address}":`, error.message);
            throw error;
        }
    }

    // Calculate confidence based on Google's location_type
    calculateConfidence(result) {
        const locationType = result.geometry.location_type;
        switch (locationType) {
            case 'ROOFTOP': return 1.0;
            case 'RANGE_INTERPOLATED': return 0.8;
            case 'GEOMETRIC_CENTER': return 0.6;
            case 'APPROXIMATE': return 0.4;
            default: return 0.2;
        }
    }

    // Extract useful address components
    extractComponents(components) {
        const extracted = {};
        components.forEach(component => {
            const types = component.types;
            if (types.includes('locality')) extracted.city = component.long_name;
            if (types.includes('administrative_area_level_1')) extracted.state = component.short_name;
            if (types.includes('postal_code')) extracted.zip = component.long_name;
            if (types.includes('country')) extracted.country = component.short_name;
        });
        return extracted;
    }

    // Calculate distance between coordinates using Haversine formula
    calculateDistance(lat1, lon1, lat2, lon2) {
        const R = 3959; // Earth's radius in miles
        const dLat = this.toRadians(lat2 - lat1);
        const dLon = this.toRadians(lon2 - lon1);
        const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                Math.cos(this.toRadians(lat1)) * Math.cos(this.toRadians(lat2)) *
                Math.sin(dLon/2) * Math.sin(dLon/2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        return R * c; // Distance in miles
    }

    toRadians(degrees) {
        return degrees * (Math.PI / 180);
    }

    // Usage statistics
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
        console.log('🗑️  Geocoding cache cleared');
    }
}

module.exports = GeocodingService;