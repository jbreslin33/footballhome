const express = require('express');
const Joi = require('joi');
const { Pool } = require('pg');
const { authenticateToken, requireRole, requireTeamMembership } = require('../middleware/auth');

const router = express.Router();

// Database pool will be injected
let dbPool;

const setDbPool = (pool) => {
    dbPool = pool;
};

// Validation schemas
const createEventSchema = Joi.object({
    title: Joi.string().min(1).max(255).required(),
    description: Joi.string().max(2000).optional(),
    event_type: Joi.string().valid('practice', 'game', 'meeting', 'social', 'other').required(),
    start_time: Joi.date().iso().required(),
    end_time: Joi.date().iso().min(Joi.ref('start_time')).required(),
    venue_id: Joi.string().uuid().optional(),
    team_id: Joi.string().uuid().required(),
    is_mandatory: Joi.boolean().default(false),
    max_participants: Joi.number().integer().min(1).optional(),
    notes: Joi.string().max(1000).optional()
});

const updateEventSchema = Joi.object({
    title: Joi.string().min(1).max(255).optional(),
    description: Joi.string().max(2000).optional(),
    event_type: Joi.string().valid('practice', 'game', 'meeting', 'social', 'other').optional(),
    start_time: Joi.date().iso().optional(),
    end_time: Joi.date().iso().optional(),
    venue_id: Joi.string().uuid().allow(null).optional(),
    is_mandatory: Joi.boolean().optional(),
    max_participants: Joi.number().integer().min(1).allow(null).optional(),
    notes: Joi.string().max(1000).allow('').optional()
}).custom((obj, helpers) => {
    if (obj.start_time && obj.end_time && obj.start_time >= obj.end_time) {
        return helpers.error('any.invalid');
    }
    return obj;
});

// Get event types (optionally filtered by category)
router.get('/types', 
    authenticateToken,
    async (req, res) => {
        try {
            const { category } = req.query;
            
            let query = 'SELECT * FROM event_types WHERE 1=1';
            const params = [];
            
            if (category) {
                query += ' AND category = $1';
                params.push(category);
            }
            
            query += ' ORDER BY category, name';
            
            const result = await dbPool.query(query, params);
            
            res.json({
                event_types: result.rows
            });
            
        } catch (error) {
            console.error('Get event types error:', error);
            res.status(500).json({
                error: 'Failed to get event types',
                code: 'GET_EVENT_TYPES_ERROR'
            });
        }
    }
);



// Test simple endpoint
router.get('/test', (req, res) => {
    res.json({ message: 'Events router is working!' });
});

// Get events for a team - COMPLETELY REWRITTEN 
router.get('/team/:teamId', authenticateToken, async (req, res) => {
    console.log('🚀 EVENTS ROUTE ACCESSED - Team:', req.params.teamId);
    
    try {
        const teamId = req.params.teamId;
        
        // Use the absolute simplest query possible
        const query = 'SELECT id, title FROM events WHERE team_id = $1';
        console.log('📝 Query:', query, 'Params:', [teamId]);
        
        const result = await dbPool.query(query, [teamId]);
        console.log('✅ Query successful, rows:', result.rowCount);
        
        res.json({ events: result.rows });
        
    } catch (err) {
        console.error('❌ ERROR:', err.message);
        console.error('❌ ERROR CODE:', err.code);
        console.error('❌ ERROR DETAIL:', err.detail);
        res.status(500).json({ error: 'Database error' });
    }
});

// Get single event details
router.get('/:eventId',
    authenticateToken,
    async (req, res) => {
        try {
            const { eventId } = req.params;

            // Status mappings for queries
            const statusMappings = {
                'attending': '550e8400-e29b-41d4-a716-446655440301',
                'not_attending': '550e8400-e29b-41d4-a716-446655440303',
                'maybe': '550e8400-e29b-41d4-a716-446655440302'
            };

            // Get event with venue and RSVP details
            const result = await dbPool.query(`
                SELECT e.*, et.name as event_type_name, et.color as event_type_color,
                       v.name as venue_name, v.address as venue_address, v.latitude, v.longitude,
                       t.name as team_name,
                       MAX(CASE WHEN r.user_id = $1 THEN 
                           CASE 
                               WHEN r.rsvp_status_id = '${statusMappings.attending}' THEN 'attending'
                               WHEN r.rsvp_status_id = '${statusMappings.not_attending}' THEN 'not_attending'
                               WHEN r.rsvp_status_id = '${statusMappings.maybe}' THEN 'maybe'
                           END
                       END) as my_rsvp_status,
                       MAX(CASE WHEN r.user_id = $1 THEN r.response_date END) as my_rsvp_updated_at
                FROM events e
                LEFT JOIN event_types et ON e.event_type_id = et.id
                LEFT JOIN venues v ON e.venue_id = v.id
                LEFT JOIN teams t ON e.team_id = t.id
                LEFT JOIN rsvps r ON e.id = r.event_id
                WHERE e.id = $2
                GROUP BY e.id, et.name, et.color, v.name, v.address, v.latitude, v.longitude, t.name
            `, [req.user.id, eventId]);

            if (result.rows.length === 0) {
                return res.status(404).json({
                    error: 'Event not found',
                    code: 'EVENT_NOT_FOUND'
                });
            }

            const event = result.rows[0];

            // Check if user has access to this event (team member or admin)
            const accessCheck = await dbPool.query(`
                SELECT tm.team_id, tm.role as team_role, r.name as system_role
                FROM team_members tm
                LEFT JOIN user_roles ur ON ur.user_id = tm.user_id AND ur.is_active = true
                LEFT JOIN roles r ON ur.role_id = r.id
                WHERE tm.user_id = $1 AND tm.team_id = $2 AND tm.is_active = true
                UNION
                SELECT NULL, NULL, r.name
                FROM user_roles ur
                JOIN roles r ON ur.role_id = r.id
                WHERE ur.user_id = $1 AND r.name IN ('admin', 'super_admin') AND ur.is_active = true
            `, [req.user.id, event.team_id]);

            if (accessCheck.rows.length === 0) {
                return res.status(403).json({
                    error: 'Not authorized to view this event',
                    code: 'EVENT_ACCESS_DENIED'
                });
            }

            // Get RSVP summary
            const rsvpSummary = await dbPool.query(`
                SELECT 
                    COUNT(*) as total_rsvps,
                    COUNT(CASE WHEN rsvp_status_id = '550e8400-e29b-41d4-a716-446655440301' THEN 1 END) as attending,
                    COUNT(CASE WHEN rsvp_status_id = '550e8400-e29b-41d4-a716-446655440303' THEN 1 END) as not_attending,
                    COUNT(CASE WHEN rsvp_status_id = '550e8400-e29b-41d4-a716-446655440302' THEN 1 END) as maybe
                FROM rsvps
                WHERE event_id = $1
            `, [eventId]);

            res.json({
                event: {
                    ...event,
                    rsvp_summary: rsvpSummary.rows[0]
                }
            });

        } catch (error) {
            console.error('Get event error:', error);
            res.status(500).json({
                error: 'Failed to get event',
                code: 'GET_EVENT_ERROR'
            });
        }
    }
);

// Create new event (coaches/admins only)
router.post('/',
    authenticateToken,
    async (req, res) => {
        try {
            // Validate input
            const { error, value } = createEventSchema.validate(req.body);
            if (error) {
                return res.status(400).json({
                    error: 'Validation failed',
                    details: error.details.map(d => d.message),
                    code: 'VALIDATION_ERROR'
                });
            }

            // Check if user can create events for this team
            const authCheck = await dbPool.query(`
                SELECT tm.team_id, tm.role as team_role, r.name as system_role
                FROM team_members tm
                LEFT JOIN user_roles ur ON ur.user_id = tm.user_id AND ur.is_active = true
                LEFT JOIN roles r ON ur.role_id = r.id
                WHERE tm.user_id = $1 AND tm.team_id = $2 AND tm.is_active = true
                AND (tm.role IN ('coach', 'manager') OR r.name IN ('admin', 'super_admin'))
                UNION
                SELECT NULL, NULL, r.name
                FROM user_roles ur
                JOIN roles r ON ur.role_id = r.id
                WHERE ur.user_id = $1 AND r.name IN ('admin', 'super_admin') AND ur.is_active = true
            `, [req.user.id, value.team_id]);

            if (authCheck.rows.length === 0) {
                return res.status(403).json({
                    error: 'Not authorized to create events for this team',
                    code: 'CREATE_EVENT_DENIED'
                });
            }

            // Verify venue exists if provided
            if (value.venue_id) {
                const venueCheck = await dbPool.query(
                    'SELECT id FROM venues WHERE id = $1',
                    [value.venue_id]
                );

                if (venueCheck.rows.length === 0) {
                    return res.status(400).json({
                        error: 'Venue not found',
                        code: 'VENUE_NOT_FOUND'
                    });
                }
            }

            // Create event
            const result = await dbPool.query(`
                INSERT INTO events (
                    title, description, event_type, start_time, end_time, 
                    venue_id, team_id, is_mandatory, max_participants, 
                    notes, created_by
                )
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
                RETURNING *
            `, [
                value.title, value.description, value.event_type,
                value.start_time, value.end_time, value.venue_id,
                value.team_id, value.is_mandatory, value.max_participants,
                value.notes, req.user.id
            ]);

            res.status(201).json({
                message: 'Event created successfully',
                event: result.rows[0]
            });

        } catch (error) {
            console.error('Create event error:', error);
            res.status(500).json({
                error: 'Failed to create event',
                code: 'CREATE_EVENT_ERROR'
            });
        }
    }
);

// Update event (coaches/admins only)
router.put('/:eventId',
    authenticateToken,
    async (req, res) => {
        try {
            const { eventId } = req.params;

            // Validate input
            const { error, value } = updateEventSchema.validate(req.body);
            if (error) {
                return res.status(400).json({
                    error: 'Validation failed',
                    details: error.details.map(d => d.message),
                    code: 'VALIDATION_ERROR'
                });
            }

            // Get current event to check permissions
            const eventResult = await dbPool.query(
                'SELECT team_id, created_by FROM events WHERE id = $1',
                [eventId]
            );

            if (eventResult.rows.length === 0) {
                return res.status(404).json({
                    error: 'Event not found',
                    code: 'EVENT_NOT_FOUND'
                });
            }

            const event = eventResult.rows[0];

            // Check permissions (team coach/manager, event creator, or admin)
            const authCheck = await dbPool.query(`
                SELECT tm.team_id, tm.role as team_role, r.name as system_role
                FROM team_members tm
                LEFT JOIN user_roles ur ON ur.user_id = tm.user_id AND ur.is_active = true
                LEFT JOIN roles r ON ur.role_id = r.id
                WHERE tm.user_id = $1 AND tm.team_id = $2 AND tm.is_active = true
                AND (tm.role IN ('coach', 'manager') OR r.name IN ('admin', 'super_admin'))
                UNION
                SELECT NULL, NULL, r.name
                FROM user_roles ur
                JOIN roles r ON ur.role_id = r.id
                WHERE ur.user_id = $1 AND r.name IN ('admin', 'super_admin') AND ur.is_active = true
            `, [req.user.id, event.team_id]);

            const isEventCreator = event.created_by === req.user.id;

            if (authCheck.rows.length === 0 && !isEventCreator) {
                return res.status(403).json({
                    error: 'Not authorized to update this event',
                    code: 'UPDATE_EVENT_DENIED'
                });
            }

            // Verify venue exists if being updated
            if (value.venue_id) {
                const venueCheck = await dbPool.query(
                    'SELECT id FROM venues WHERE id = $1',
                    [value.venue_id]
                );

                if (venueCheck.rows.length === 0) {
                    return res.status(400).json({
                        error: 'Venue not found',
                        code: 'VENUE_NOT_FOUND'
                    });
                }
            }

            // Build update query dynamically
            const updates = [];
            const values = [];
            let paramCount = 0;

            for (const [key, val] of Object.entries(value)) {
                if (val !== undefined) {
                    updates.push(`${key} = $${++paramCount}`);
                    values.push(val);
                }
            }

            if (updates.length === 0) {
                return res.status(400).json({
                    error: 'No fields to update',
                    code: 'NO_UPDATE_FIELDS'
                });
            }

            updates.push(`updated_at = CURRENT_TIMESTAMP`);
            values.push(eventId);

            const query = `
                UPDATE events 
                SET ${updates.join(', ')}
                WHERE id = $${++paramCount}
                RETURNING *
            `;

            const result = await dbPool.query(query, values);

            res.json({
                message: 'Event updated successfully',
                event: result.rows[0]
            });

        } catch (error) {
            console.error('Update event error:', error);
            res.status(500).json({
                error: 'Failed to update event',
                code: 'UPDATE_EVENT_ERROR'
            });
        }
    }
);

// Delete event (coaches/admins only)
router.delete('/:eventId',
    authenticateToken,
    async (req, res) => {
        try {
            const { eventId } = req.params;

            // Get event to check permissions
            const eventResult = await dbPool.query(
                'SELECT team_id, created_by FROM events WHERE id = $1',
                [eventId]
            );

            if (eventResult.rows.length === 0) {
                return res.status(404).json({
                    error: 'Event not found',
                    code: 'EVENT_NOT_FOUND'
                });
            }

            const event = eventResult.rows[0];

            // Check permissions
            const authCheck = await dbPool.query(`
                SELECT tm.team_id, tm.role as team_role, r.name as system_role
                FROM team_members tm
                LEFT JOIN user_roles ur ON ur.user_id = tm.user_id AND ur.is_active = true
                LEFT JOIN roles r ON ur.role_id = r.id
                WHERE tm.user_id = $1 AND tm.team_id = $2 AND tm.is_active = true
                AND (tm.role IN ('coach', 'manager') OR r.name IN ('admin', 'super_admin'))
                UNION
                SELECT NULL, NULL, r.name
                FROM user_roles ur
                JOIN roles r ON ur.role_id = r.id
                WHERE ur.user_id = $1 AND r.name IN ('admin', 'super_admin') AND ur.is_active = true
            `, [req.user.id, event.team_id]);

            const isEventCreator = event.created_by === req.user.id;

            if (authCheck.rows.length === 0 && !isEventCreator) {
                return res.status(403).json({
                    error: 'Not authorized to delete this event',
                    code: 'DELETE_EVENT_DENIED'
                });
            }

            // Delete event (RSVPs will be deleted via CASCADE)
            await dbPool.query('DELETE FROM events WHERE id = $1', [eventId]);

            res.json({
                message: 'Event deleted successfully'
            });

        } catch (error) {
            console.error('Delete event error:', error);
            res.status(500).json({
                error: 'Failed to delete event',
                code: 'DELETE_EVENT_ERROR'
            });
        }
    }
);

module.exports = { router, setDbPool };