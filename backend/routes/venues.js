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

// POST /api/venues/import/area - Import soccer venues from Google Places in specific area
router.post('/import/area', async (req, res) => {
    try {
        const { latitude, longitude, radius = 25, venue_type = 'all' } = req.body;
        
        if (!latitude || !longitude) {
            return res.status(400).json({
                success: false,
                error: 'Latitude and longitude are required'
            });
        }

        console.log(`🔍 Starting venue import for area: ${latitude}, ${longitude} (${radius}km)`);
        
        const results = await venueService.importSoccerVenuesFromArea(
            parseFloat(latitude),
            parseFloat(longitude),
            parseInt(radius),
            venue_type
        );

        res.json({
            success: true,
            data: results,
            message: `Import completed: ${results.imported} venues imported, ${results.skipped} skipped`
        });
    } catch (error) {
        console.error('Error importing venues from area:', error.message);
        res.status(500).json({
            success: false,
            error: 'Failed to import venues from area',
            message: error.message
        });
    }
});

// POST /api/venues/import/stadiums - Import famous soccer stadiums
router.post('/import/stadiums', async (req, res) => {
    try {
        const { country = 'US' } = req.body;
        
        console.log(`🏟️ Starting famous stadiums import for ${country}`);
        
        const results = await venueService.importFamousSoccerStadiums(country);

        res.json({
            success: true,
            data: results,
            message: `Stadium import completed: ${results.imported} stadiums imported`
        });
    } catch (error) {
        console.error('Error importing famous stadiums:', error.message);
        res.status(500).json({
            success: false,
            error: 'Failed to import famous stadiums',
            message: error.message
        });
    }
});

// GET /api/venues/search/google/:query - Search Google Places for venues
router.get('/search/google/:query', async (req, res) => {
    try {
        const { query } = req.params;
        const { location } = req.query;
        
        const venues = await venueService.searchVenuesByName(query, location);
        
        res.json({
            success: true,
            data: venues,
            count: venues.length,
            query: query,
            location: location || 'global'
        });
    } catch (error) {
        console.error('Error searching Google Places:', error.message);
        res.status(500).json({
            success: false,
            error: 'Failed to search Google Places',
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

// POST /api/venues - DISABLED: User venue creation removed in v2.1 (Google-only)
// router.post('/', async (req, res) => {
//     // User venue creation is no longer supported
//     res.status(410).json({
//         success: false,
//         error: 'User venue creation is no longer supported',
//         message: 'Only Google Places venues are supported. Use /api/venues/import/area to import venues.'
//     });
// });

// POST /api/venues/force - DISABLED: User venue creation removed in v2.1 (Google-only)
// router.post('/force', async (req, res) => {
//     // Force venue creation is no longer supported
//     res.status(410).json({
//         success: false,
//         error: 'Force venue creation is no longer supported',
//         message: 'Only Google Places venues are supported. Use /api/venues/import/area to import venues.'
//     });
// });

// Remaining code from force create endpoint commented out - v2.1 cleanup

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