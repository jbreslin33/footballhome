// Add to your Express routes
const VenueService = require('../services/VenueService');

// Geocoding usage monitoring endpoint
app.get('/api/admin/geocoding-stats', async (req, res) => {
    try {
        const venueService = new VenueService(db);
        const stats = venueService.getGeocodingStats();
        
        res.json({
            usage: stats,
            alerts: {
                daily_usage_percent: (stats.daily_requests / stats.daily_limit * 100).toFixed(1),
                minute_usage_percent: (stats.minute_requests / stats.minute_limit * 100).toFixed(1),
                approaching_daily_limit: stats.daily_requests > (stats.daily_limit * 0.8),
                approaching_minute_limit: stats.minute_requests > (stats.minute_limit * 0.8)
            }
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Venue creation with deduplication
app.post('/api/venues', async (req, res) => {
    try {
        const venueService = new VenueService(db);
        const result = await venueService.addVenue(req.body);
        
        if (result.status === 'duplicate_detected') {
            res.status(409).json(result); // Conflict status
        } else {
            res.status(201).json(result); // Created
        }
    } catch (error) {
        if (error.message.includes('limit exceeded')) {
            res.status(429).json({ error: 'Rate limit exceeded', retry_after: 60 });
        } else {
            res.status(500).json({ error: error.message });
        }
    }
});

// Force create venue (override duplicate detection)
app.post('/api/venues/force', async (req, res) => {
    try {
        const venueService = new VenueService(db);
        const geocodeData = await venueService.geocoding.geocode(req.body.address);
        
        const venue = await venueService.forceCreateVenue({
            ...req.body,
            formatted_address: geocodeData.formatted_address,
            latitude: geocodeData.latitude,
            longitude: geocodeData.longitude,
            place_id: geocodeData.place_id,
            confidence: geocodeData.confidence,
            geocoding_provider: 'google'
        });
        
        res.status(201).json({ status: 'created', venue });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});