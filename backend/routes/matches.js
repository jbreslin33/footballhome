const express = require('express');
const router = express.Router();
const { authenticateToken, requireRole } = require('../middleware/auth');

// Database connection - will be injected from server.js
let dbPool;

// Get all opponent teams (for dropdown population)
router.get('/opponents', authenticateToken, async (req, res) => {
    try {
        const result = await dbPool.query(`
            SELECT id, name, age_group, skill_level
            FROM teams 
            WHERE is_active = true
            ORDER BY name
        `);

        res.json({
            opponents: result.rows
        });
    } catch (error) {
        console.error('Error fetching opponent teams:', error);
        res.status(500).json({
            error: 'Internal server error',
            code: 'DATABASE_ERROR'
        });
    }
});

// Get home/away status options
router.get('/home-away-statuses', authenticateToken, async (req, res) => {
    try {
        const result = await dbPool.query(`
            SELECT id, name, display_name, description
            FROM home_away_statuses
            ORDER BY sort_order
        `);

        res.json({
            statuses: result.rows
        });
    } catch (error) {
        console.error('Error fetching home/away statuses:', error);
        res.status(500).json({
            error: 'Internal server error',
            code: 'DATABASE_ERROR'
        });
    }
});

// Create a new match
router.post('/', authenticateToken, requireRole(['coach', 'admin']), async (req, res) => {
    const client = await dbPool.connect();
    
    try {
        await client.query('BEGIN');
        
        const {
            // Event fields
            team_id,
            event_type_id,
            title,
            description,
            event_date,
            venue_id,
            duration_minutes,
            max_players,
            
            // Match-specific fields
            opponent_team_id,
            home_away_status_id,
            competition_name,
            season,
            round,
            expected_attendance,
            referee_assigned,
            referee_contact,
            kickoff_time,
            pre_match_meeting_time,
            arrival_time,
            warm_up_duration,
            notes
        } = req.body;

        // Validate required fields
        if (!team_id || !event_type_id || !title || !opponent_team_id || !home_away_status_id) {
            return res.status(400).json({
                error: 'Missing required fields',
                code: 'VALIDATION_ERROR'
            });
        }

        // Check if user can create matches for this team (member or admin)
        const authCheck = await client.query(`
            SELECT tm.team_id, tm.user_id, r.name as system_role
            FROM team_members tm
            LEFT JOIN user_roles ur ON ur.user_id = tm.user_id AND ur.is_active = true
            LEFT JOIN roles r ON ur.role_id = r.id
            WHERE tm.user_id = $1 AND tm.team_id = $2 AND tm.is_active = true
            UNION
            SELECT NULL, NULL, r.name
            FROM user_roles ur
            JOIN roles r ON ur.role_id = r.id
            WHERE ur.user_id = $1 AND r.name IN ('admin', 'super_admin') AND ur.is_active = true
        `, [req.user.id, team_id]);

        if (authCheck.rows.length === 0) {
            return res.status(403).json({
                error: 'Not authorized to create matches for this team',
                code: 'CREATE_MATCH_DENIED'
            });
        }

        // Insert into events table first
        const eventResult = await client.query(`
            INSERT INTO events (
                team_id, event_type_id, title, description, event_date, 
                venue_id, duration_minutes, max_players, created_by
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
            RETURNING id
        `, [
            team_id,
            event_type_id,
            title,
            description || null,
            event_date,
            venue_id || null,
            duration_minutes || 90, // Default match duration
            max_players || null,
            req.user.id
        ]);

        const eventId = eventResult.rows[0].id;

        // Insert into matches table
        await client.query(`
            INSERT INTO matches (
                id, opponent_team_id, home_away_status_id, competition_name,
                competition_round, referee_name, referee_phone, kick_off_time,
                attendance
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
        `, [
            eventId,
            opponent_team_id,
            home_away_status_id,
            competition_name || null,
            round || null, // MatchForm sends 'round', DB expects 'competition_round'
            referee_assigned ? referee_contact : null, // MatchForm sends 'referee_contact', DB expects 'referee_name'
            null, // referee_phone - not provided by MatchForm separately
            kickoff_time || null, // MatchForm sends 'kickoff_time', DB expects 'kick_off_time'
            expected_attendance || null // MatchForm sends 'expected_attendance', DB expects 'attendance'
        ]);

        await client.query('COMMIT');

        res.status(201).json({
            message: 'Match created successfully',
            match: {
                id: eventId,
                title,
                event_date,
                opponent_team_id,
                home_away_status_id,
                competition_name
            }
        });

    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Error creating match:', error);
        
        if (error.code === '23503') {
            return res.status(400).json({
                error: 'Invalid reference - team, opponent, or venue not found',
                code: 'FOREIGN_KEY_ERROR'
            });
        }
        
        res.status(500).json({
            error: 'Failed to create match',
            code: 'DATABASE_ERROR'
        });
    } finally {
        client.release();
    }
});

// Get matches for a team
router.get('/', authenticateToken, async (req, res) => {
    try {
        const { team_id } = req.query;
        
        let query = `
            SELECT 
                e.id, e.title, e.description, e.event_date, e.duration_minutes,
                e.max_players, e.cancelled, e.created_at,
                v.name as venue_name, v.address as venue_address,
                ot.name as opponent_name, ot.short_name as opponent_short_name,
                has.name as location_type, has.display_name as location_display,
                m.competition_name, m.competition_round, m.referee_name,
                m.home_team_score, m.away_team_score, m.match_status,
                et.display_name as event_type_name
            FROM events e
            JOIN matches m ON e.id = m.id
            JOIN teams ot ON m.opponent_team_id = ot.id
            JOIN home_away_statuses has ON m.home_away_status_id = has.id
            LEFT JOIN venues v ON e.venue_id = v.id
            LEFT JOIN event_types et ON e.event_type_id = et.id
            WHERE e.cancelled = false
        `;
        
        const params = [];
        
        if (team_id) {
            query += ' AND e.team_id = $1';
            params.push(team_id);
        }
        
        query += ' ORDER BY e.event_date DESC';
        
        const result = await dbPool.query(query, params);
        
        res.json({
            matches: result.rows
        });
        
    } catch (error) {
        console.error('Error fetching matches:', error);
        res.status(500).json({
            error: 'Internal server error',
            code: 'DATABASE_ERROR'
        });
    }
});

// Set database pool
const setDbPool = (pool) => {
    dbPool = pool;
};

module.exports = { router, setDbPool };