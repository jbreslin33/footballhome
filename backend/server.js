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
const { router: eventsRoutes, setDbPool: setEventsDbPool } = require('./routes/events-simple');
const { router: rsvpsRoutes, setDbPool: setRsvpsDbPool } = require('./routes/rsvps');
const { router: practicesRoutes, setDbPool: setPracticesDbPool } = require('./routes/practices');
const { router: teamsRoutes, setDbPool: setTeamsDbPool } = require('./routes/teams');
const { router: matchesRoutes, setDbPool: setMatchesDbPool } = require('./routes/matches');
const { router: leagueGamesRoutes, setDbPool: setLeagueGamesDbPool } = require('./routes/league-games');

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

// Middleware (set up before routes)
app.use(helmet()); // Security headers
app.use(cors({
    origin: [
        process.env.FRONTEND_URL || 'http://localhost:3000',
        'https://footballhome.org',
        'http://footballhome.org'
    ],
    credentials: true
})); // Enable CORS with credentials
app.use(morgan('combined')); // Logging
app.use(express.json({ limit: '10mb' })); // Parse JSON bodies
app.use(generalLimiter); // Rate limiting

// Health check endpoint (always available)
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        service: 'footballhome-backend',
        version: '1.0.0'
    });
});

console.log('🚀 ABOUT TO SETUP DATABASE AND ROUTES');

// Setup database and routes immediately
console.log('🔄 Setting up database connection and routes...');

// Inject database pool into middleware and routes
setAuthDbPool(pool);
setAuthRoutesDbPool(pool);
setEventsDbPool(pool);
setRsvpsDbPool(pool);
setPracticesDbPool(pool);
setTeamsDbPool(pool);
setVenuesDbPool(pool);
setMatchesDbPool(pool);
setLeagueGamesDbPool(pool);

// Mount API routes
console.log('🔧 Mounting API routes...');
app.use('/api/auth', authRoutes);
app.use('/api/events', eventsRoutes);
app.use('/api/events-simple', eventsRoutes); // Add alias for frontend compatibility
app.use('/api/rsvps', rsvpsRoutes);
app.use('/api/practices', practicesRoutes);
app.use('/api/teams', teamsRoutes);
app.use('/api/venues', venueRoutes);
app.use('/api/matches', matchesRoutes);
app.use('/api/league-games', leagueGamesRoutes);
console.log('✅ API routes mounted successfully');

// Test database connection asynchronously but don't block route mounting
pool.query('SELECT 1')
    .then(() => console.log('✅ Connected to PostgreSQL database - ROUTE SETUP SHOULD HAPPEN BEFORE THIS'))
    .catch(err => console.error('❌ Database connection error:', err.message));

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
            matches: '/api/matches',
            'league-games': '/api/league-games'
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