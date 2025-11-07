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

// Get events for a team with RSVP status
router.get('/team/:teamId', authenticateToken, async (req, res) => {
    console.log('🚀 EVENTS ROUTE ACCESSED - Team:', req.params.teamId);
    console.log('📝 Query params:', req.query);
    
    try {
        const teamId = req.params.teamId;
        const userId = req.user.id; // Get current user ID from auth token
        const { start_date, end_date, limit = 50, offset = 0 } = req.query;
        
        // Build comprehensive query with RSVP status and event details
        let query = `
            SELECT 
                e.id, 
                e.title, 
                e.description, 
                e.event_date, 
                e.duration_minutes, 
                e.max_players,
                v.name as venue_name,
                v.address as venue_address,
                et.display_name as event_type_name,
                t.name as team_name,
                -- User's RSVP status
                CASE 
                    WHEN rs.name = 'yes' THEN 'attending'
                    WHEN rs.name = 'no' THEN 'not_attending'
                    WHEN rs.name = 'maybe' THEN 'maybe'
                    ELSE NULL
                END as my_rsvp_status,
                -- RSVP counts
                COUNT(r_all.id) FILTER (WHERE rs_all.name = 'yes') as attending_count,
                COUNT(r_all.id) FILTER (WHERE rs_all.name = 'no') as not_attending_count,
                COUNT(r_all.id) FILTER (WHERE rs_all.name = 'maybe') as maybe_count,
                (SELECT COUNT(*) FROM team_members tm WHERE tm.team_id = e.team_id AND tm.is_active = true) - COUNT(r_all.id) as no_response_count
            FROM events e
            LEFT JOIN venues v ON e.venue_id = v.id
            LEFT JOIN event_types et ON e.event_type_id = et.id
            LEFT JOIN teams t ON e.team_id = t.id
            -- Current user's RSVP
            LEFT JOIN rsvps r ON e.id = r.event_id AND r.user_id = $2
            LEFT JOIN rsvp_statuses rs ON r.rsvp_status_id = rs.id
            -- All RSVPs for counts
            LEFT JOIN rsvps r_all ON e.id = r_all.event_id
            LEFT JOIN rsvp_statuses rs_all ON r_all.rsvp_status_id = rs_all.id
            WHERE e.team_id = $1
        `;
        const queryParams = [teamId, userId];
        let paramCount = 2;
        
        // Add date filters if provided
        if (start_date) {
            query += ` AND e.event_date >= $${++paramCount}`;
            queryParams.push(start_date);
        }
        
        if (end_date) {
            query += ` AND e.event_date <= $${++paramCount}`;
            queryParams.push(end_date);
        }
        
        // Group by all selected columns and add ordering and pagination
        query += ` 
            GROUP BY e.id, e.title, e.description, e.event_date, e.duration_minutes, e.max_players,
                     v.name, v.address, et.display_name, t.name, rs.name
            ORDER BY e.event_date ASC
            LIMIT $${++paramCount} OFFSET $${++paramCount}
        `;
        queryParams.push(parseInt(limit), parseInt(offset));
        
        console.log('📝 Executing enhanced query with RSVP status');
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