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
    console.log('📝 Query params:', req.query);
    
    try {
        const teamId = req.params.teamId;
        const { start_date, end_date, limit = 50, offset = 0 } = req.query;
        
        // Build query with optional filters
        let query = 'SELECT id, title, event_date FROM events WHERE team_id = $1';
        const queryParams = [teamId];
        let paramCount = 1;
        
        // Add date filters if provided
        if (start_date) {
            query += ` AND event_date >= $${++paramCount}`;
            queryParams.push(start_date);
        }
        
        if (end_date) {
            query += ` AND event_date <= $${++paramCount}`;
            queryParams.push(end_date);
        }
        
        // Add ordering and pagination
        query += ' ORDER BY event_date ASC';
        query += ` LIMIT $${++paramCount} OFFSET $${++paramCount}`;
        queryParams.push(parseInt(limit), parseInt(offset));
        
        console.log('📝 Executing query:', query);
        console.log('📝 Query params:', queryParams);
        
        const result = await dbPool.query(query, queryParams);
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