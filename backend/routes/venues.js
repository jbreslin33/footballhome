const express = require('express');
const VenueService = require('../services/VenueService');

const router = express.Router();
const venueService = new VenueService();

// GET /api/venues - Get all venues with pagination and search
router.get('/', async (req, res) => {
    try {
        const { page = 1, limit = 20, search } = req.query;
        
        const result = await venueService.getVenues({
            page: parseInt(page),
            limit: parseInt(limit),
            search: search || null
        });

        res.json({
            success: true,
            data: result.venues,
            pagination: result.pagination
        });
    } catch (error) {
        console.error('Error getting venues:', error.message);
        res.status(500).json({
            success: false,
            error: 'Failed to get venues',
            message: error.message
        });
    }
});

// GET /api/venues/stats - Get venue and geocoding statistics
router.get('/stats', async (req, res) => {
    try {
        const stats = await venueService.getStats();
        
        res.json({
            success: true,
            data: stats,
            alerts: {
                daily_usage_percent: (stats.geocoding.daily_requests / stats.geocoding.daily_limit * 100).toFixed(1),
                minute_usage_percent: (stats.geocoding.minute_requests / stats.geocoding.minute_limit * 100).toFixed(1),
                approaching_daily_limit: stats.geocoding.daily_requests > (stats.geocoding.daily_limit * 0.8),
                approaching_minute_limit: stats.geocoding.minute_requests > (stats.geocoding.minute_limit * 0.8)
            }
        });
    } catch (error) {
        console.error('Error getting venue stats:', error.message);
        res.status(500).json({
            success: false,
            error: 'Failed to get venue statistics',
            message: error.message
        });
    }
});

// GET /api/venues/without-coordinates - Get venues that need geocoding
router.get('/without-coordinates', async (req, res) => {
    try {
        const { limit = 10 } = req.query;
        
        const venues = await venueService.getVenuesWithoutCoordinates(parseInt(limit));
        
        res.json({
            success: true,
            data: venues,
            count: venues.length
        });
    } catch (error) {
        console.error('Error getting venues without coordinates:', error.message);
        res.status(500).json({
            success: false,
            error: 'Failed to get venues without coordinates',
            message: error.message
        });
    }
});

// GET /api/venues/nearby/:lat/:lng - Find nearby venues
router.get('/nearby/:lat/:lng', async (req, res) => {
    try {
        const { lat, lng } = req.params;
        const { radius = 10, limit = 10 } = req.query;

        const latitude = parseFloat(lat);
        const longitude = parseFloat(lng);

        if (isNaN(latitude) || isNaN(longitude)) {
            return res.status(400).json({
                success: false,
                error: 'Invalid coordinates'
            });
        }

        const venues = await venueService.findNearbyVenues(
            latitude,
            longitude,
            parseFloat(radius),
            parseInt(limit)
        );

        res.json({
            success: true,
            data: venues,
            search_params: {
                latitude,
                longitude,
                radius: parseFloat(radius),
                limit: parseInt(limit)
            }
        });
    } catch (error) {
        console.error('Error finding nearby venues:', error.message);
        res.status(500).json({
            success: false,
            error: 'Failed to find nearby venues',
            message: error.message
        });
    }
});

// GET /api/venues/:id - Get venue by ID
router.get('/:id', async (req, res) => {
    try {
        const venue = await venueService.getVenueById(req.params.id);
        
        if (!venue) {
            return res.status(404).json({
                success: false,
                error: 'Venue not found'
            });
        }

        res.json({
            success: true,
            data: venue
        });
    } catch (error) {
        console.error('Error getting venue:', error.message);
        res.status(500).json({
            success: false,
            error: 'Failed to get venue',
            message: error.message
        });
    }
});

// POST /api/venues - Create new venue with duplicate detection
router.post('/', async (req, res) => {
    try {
        const result = await venueService.addVenue(req.body);

        if (result.status === 'duplicate_detected') {
            return res.status(409).json({
                success: false,
                status: 'duplicate_detected',
                message: result.message,
                suggested_venues: result.suggested_venues,
                geocoded_data: result.geocoded_data,
                can_create_anyway: result.can_create_anyway
            });
        }

        res.status(201).json({
            success: true,
            data: result.venue,
            geocoded_data: result.geocoded_data
        });
    } catch (error) {
        console.error('Error creating venue:', error.message);
        
        if (error.message.includes('limit exceeded')) {
            res.status(429).json({ 
                success: false,
                error: 'Rate limit exceeded', 
                retry_after: 60 
            });
        } else {
            res.status(400).json({
                success: false,
                error: 'Failed to create venue',
                message: error.message
            });
        }
    }
});

// POST /api/venues/force - Force create venue (override duplicate detection)
router.post('/force', async (req, res) => {
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
            description
        } = req.body;

        if (!name || !address) {
            return res.status(400).json({
                success: false,
                error: 'Venue name and address are required'
            });
        }

        const fullAddress = `${address}, ${city || ''}, ${state || ''} ${zip_code || ''}, ${country}`.trim();
        const geocodeData = await venueService.geocoding.geocode(fullAddress);

        const venue = await venueService.createVenue({
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
            latitude: geocodeData.latitude,
            longitude: geocodeData.longitude,
            formatted_address: geocodeData.formatted_address,
            place_id: geocodeData.place_id,
            confidence: geocodeData.confidence
        });

        res.status(201).json({
            success: true,
            data: venue,
            geocoded_data: geocodeData
        });
    } catch (error) {
        console.error('Error force creating venue:', error.message);
        res.status(400).json({
            success: false,
            error: 'Failed to create venue',
            message: error.message
        });
    }
});

// PUT /api/venues/:id/geocode - Update venue coordinates
router.put('/:id/geocode', async (req, res) => {
    try {
        const venue = await venueService.updateVenueCoordinates(req.params.id);
        
        res.json({
            success: true,
            data: venue,
            message: 'Venue coordinates updated successfully'
        });
    } catch (error) {
        console.error('Error updating venue coordinates:', error.message);
        res.status(500).json({
            success: false,
            error: 'Failed to update venue coordinates',
            message: error.message
        });
    }
});

// POST /api/venues/batch-geocode - Batch geocode venues without coordinates
router.post('/batch-geocode', async (req, res) => {
    try {
        const { limit = 5 } = req.body;
        
        const results = await venueService.batchGeocodeVenues(parseInt(limit));
        
        const successCount = results.filter(r => r.success).length;
        const failureCount = results.filter(r => !r.success).length;

        res.json({
            success: true,
            data: results,
            summary: {
                processed: results.length,
                successful: successCount,
                failed: failureCount
            }
        });
    } catch (error) {
        console.error('Error batch geocoding venues:', error.message);
        res.status(500).json({
            success: false,
            error: 'Failed to batch geocode venues',
            message: error.message
        });
    }
});

module.exports = router;