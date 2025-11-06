require('dotenv').config({ path: '../.env' });
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { Pool } = require('pg');

// Import middleware
const { generalLimiter } = require('./middleware/rateLimit');
const { setDbPool: setAuthDbPool } = require('./middleware/auth');

// Import routes
const { router: venueRoutes, setDbPool: setVenuesDbPool } = require('./routes/venues-simple');
const { router: authRoutes, setDbPool: setAuthRoutesDbPool } = require('./routes/auth');
const { router: eventsRoutes, setDbPool: setEventsDbPool } = require('./routes/events');
const { router: rsvpsRoutes, setDbPool: setRsvpsDbPool } = require('./routes/rsvps');
const { router: practicesRoutes, setDbPool: setPracticesDbPool } = require('./routes/practices');
const { router: teamsRoutes, setDbPool: setTeamsDbPool } = require('./routes/teams');
const { router: matchesRoutes, setDbPool: setMatchesDbPool } = require('./routes/matches');

const app = express();
const PORT = process.env.PORT || 3001;

// Database connection - using environment variables from .env
const pool = new Pool({
    user: process.env.POSTGRES_USER || 'postgres',
    host: process.env.POSTGRES_HOST || 'localhost',
    database: process.env.POSTGRES_DB || 'footballhome',
    password: process.env.POSTGRES_PASSWORD || 'password',
    port: process.env.POSTGRES_PORT || 5432,
});

// Test database connection and inject into routes
pool.connect((err, client, release) => {
    if (err) {
        console.error('❌ Error connecting to database:', err.message);
        process.exit(1);
    }
    console.log('✅ Connected to PostgreSQL database');
    
    // Inject database pool into middleware and routes
    setAuthDbPool(pool);
    setAuthRoutesDbPool(pool);
    setEventsDbPool(pool);
    setRsvpsDbPool(pool);
    setPracticesDbPool(pool);
    setTeamsDbPool(pool);
    setVenuesDbPool(pool);
    setMatchesDbPool(pool);
    
    release();
});

// Middleware
app.use(helmet()); // Security headers
app.use(cors({
    origin: process.env.FRONTEND_URL || 'http://localhost:3000',
    credentials: true
})); // Enable CORS with credentials
app.use(morgan('combined')); // Logging
app.use(express.json({ limit: '10mb' })); // Parse JSON bodies
app.use(generalLimiter); // Rate limiting

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        service: 'footballhome-backend',
        version: '1.0.0'
    });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/events', eventsRoutes);
app.use('/api/rsvps', rsvpsRoutes);
app.use('/api/practices', practicesRoutes);
app.use('/api/teams', teamsRoutes);
app.use('/api/venues', venueRoutes);
app.use('/api/matches', matchesRoutes);

// Root endpoint
app.get('/', (req, res) => {
    res.json({
        message: 'Football Home Backend API',
        version: '1.0.0',
        endpoints: {
            health: '/health',
            auth: '/api/auth',
            events: '/api/events',
            rsvps: '/api/rsvps',
            practices: '/api/practices',
            teams: '/api/teams',
            venues: '/api/venues',
            matches: '/api/matches'
        },
        documentation: 'https://github.com/your-repo/footballhome'
    });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('❌ Unhandled error:', err.stack);
    res.status(500).json({
        success: false,
        error: 'Internal server error',
        message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
    });
});

// 404 handler
app.use('*', (req, res) => {
    res.status(404).json({
        success: false,
        error: 'Not found',
        message: `Route ${req.originalUrl} not found`
    });
});

// Graceful shutdown
process.on('SIGINT', async () => {
    console.log('\n🛑 Shutting down server...');
    
    try {
        await pool.end();
        console.log('✅ Database connections closed');
        process.exit(0);
    } catch (error) {
        console.error('❌ Error during shutdown:', error.message);
        process.exit(1);
    }
});

// Start server
app.listen(PORT, () => {
    console.log(`🚀 Football Home Backend Server running on port ${PORT}`);
    console.log(`📡 Health check: http://localhost:${PORT}/health`);
    console.log(`🏟️  Venues API: http://localhost:${PORT}/api/venues`);
    console.log(`📊 Stats API: http://localhost:${PORT}/api/venues/stats`);
    
    if (process.env.GOOGLE_MAPS_API_KEY) {
        console.log('✅ Google Maps API key configured');
    } else {
        console.warn('⚠️  Google Maps API key not found');
    }
});

module.exports = app;