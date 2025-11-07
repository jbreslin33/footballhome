const express = require('express');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Database pool will be injected
let dbPool;

const setDbPool = (pool) => {
    dbPool = pool;
};

// Simple test endpoint (no auth required)
router.get('/test', (req, res) => {
    console.log('🚀 Events test endpoint called');
    res.json({ message: 'Events router is working!', timestamp: new Date().toISOString() });
});

// Get events for a team
router.get('/team/:teamId', authenticateToken, async (req, res) => {
    console.log('🚀 EVENTS ROUTE ACCESSED - Team:', req.params.teamId);
    
    try {
        const teamId = req.params.teamId;
        
        // Simple query to get events
        const query = 'SELECT id, title, event_date FROM events WHERE team_id = $1 ORDER BY event_date ASC';
        console.log('📝 Executing query:', query);
        
        const result = await dbPool.query(query, [teamId]);
        console.log('✅ Query successful, rows:', result.rowCount);
        
        res.json({ 
            events: result.rows,
            total: result.rowCount
        });
        
    } catch (err) {
        console.error('❌ Events query error:', err);
        res.status(500).json({ 
            error: 'Failed to get events',
            message: err.message,
            code: err.code
        });
    }
});

module.exports = { router, setDbPool };