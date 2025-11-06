const express = require('express');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Database pool will be injected
let dbPool;

const setDbPool = (pool) => {
    dbPool = pool;
};

// Get all venues
router.get('/', 
    authenticateToken,
    async (req, res) => {
        try {
            const { search, limit = 50, offset = 0 } = req.query;
            
            let query = 'SELECT * FROM venues WHERE 1=1';
            const params = [];
            let paramCount = 0;
            
            if (search) {
                query += ' AND (name ILIKE $' + (++paramCount) + ' OR address ILIKE $' + paramCount + ')';
                params.push(`%${search}%`);
            }
            
            query += ' ORDER BY name LIMIT $' + (++paramCount) + ' OFFSET $' + (++paramCount);
            params.push(parseInt(limit), parseInt(offset));
            
            const result = await dbPool.query(query, params);
            
            res.json({
                venues: result.rows,
                pagination: {
                    limit: parseInt(limit),
                    offset: parseInt(offset),
                    total: result.rows.length
                }
            });
            
        } catch (error) {
            console.error('Get venues error:', error);
            res.status(500).json({
                error: 'Failed to get venues',
                code: 'GET_VENUES_ERROR'
            });
        }
    }
);

// Get venue details
router.get('/:venueId',
    authenticateToken,
    async (req, res) => {
        try {
            const { venueId } = req.params;
            
            const result = await dbPool.query(
                'SELECT * FROM venues WHERE id = $1',
                [venueId]
            );
            
            if (result.rows.length === 0) {
                return res.status(404).json({
                    error: 'Venue not found',
                    code: 'VENUE_NOT_FOUND'
                });
            }
            
            res.json({
                venue: result.rows[0]
            });
            
        } catch (error) {
            console.error('Get venue error:', error);
            res.status(500).json({
                error: 'Failed to get venue',
                code: 'GET_VENUE_ERROR'
            });
        }
    }
);

module.exports = { router, setDbPool };