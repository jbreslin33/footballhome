const express = require('express');
const Joi = require('joi');
const { Pool } = require('pg');
const { authenticateToken, requireTeamMembership } = require('../middleware/auth');

const router = express.Router();

// Database pool will be injected
let dbPool;

const setDbPool = (pool) => {
    dbPool = pool;
};

// Status mappings to database UUIDs - using actual database names
const statusMappings = {
    'attending': '550e8400-e29b-41d4-a716-446655440301',     // yes
    'not_attending': '550e8400-e29b-41d4-a716-446655440303', // no  
    'maybe': '550e8400-e29b-41d4-a716-446655440302'          // maybe
};

// Database name to API name mapping
const dbToApiStatusMappings = {
    'yes': 'attending',
    'no': 'not_attending',
    'maybe': 'maybe'
};

// Reverse mapping for responses
const reverseStatusMappings = {
    '550e8400-e29b-41d4-a716-446655440301': 'attending',
    '550e8400-e29b-41d4-a716-446655440303': 'not_attending', 
    '550e8400-e29b-41d4-a716-446655440302': 'maybe'
};

// Validation schemas
const rsvpSchema = Joi.object({
    event_id: Joi.string().uuid().required(),
    status: Joi.string().valid('attending', 'not_attending', 'maybe').required(),
    notes: Joi.string().max(500).allow('').optional()
});

const updateRsvpSchema = Joi.object({
    status: Joi.string().valid('attending', 'not_attending', 'maybe').required(),
    notes: Joi.string().max(500).allow('').optional()
});

// Create or update RSVP
router.post('/',
    authenticateToken,
    async (req, res) => {
        try {
            // Validate input
            const { error, value } = rsvpSchema.validate(req.body);
            if (error) {
                return res.status(400).json({
                    error: 'Validation failed',
                    details: error.details.map(d => d.message),
                    code: 'VALIDATION_ERROR'
                });
            }

            const { event_id, status, notes } = value;

            // Get event and check if user has access
            const eventResult = await dbPool.query(`
                SELECT e.id, e.team_id, e.title, e.event_date, e.max_players,
                       COUNT(r.id) FILTER (WHERE r.rsvp_status_id = $2) as current_attending
                FROM events e
                LEFT JOIN rsvps r ON e.id = r.event_id
                WHERE e.id = $1
                GROUP BY e.id
            `, [event_id, statusMappings['attending']]);

            if (eventResult.rows.length === 0) {
                return res.status(404).json({
                    error: 'Event not found',
                    code: 'EVENT_NOT_FOUND'
                });
            }

            const event = eventResult.rows[0];

            // Check if user is member of the team
            const teamCheck = await dbPool.query(`
                SELECT tm.team_id, p.name as position_name
                FROM team_members tm
                LEFT JOIN positions p ON tm.position_id = p.id
                WHERE tm.user_id = $1 AND tm.team_id = $2 AND tm.is_active = true
            `, [req.user.id, event.team_id]);

            if (teamCheck.rows.length === 0) {
                return res.status(403).json({
                    error: 'Not authorized to RSVP to this event',
                    code: 'RSVP_ACCESS_DENIED'
                });
            }

            // Check if event has capacity if user is trying to attend
            if (status === 'attending' && event.max_players) {
                const currentAttending = parseInt(event.current_attending) || 0;
                
                // Get current user's RSVP status
                const currentRsvp = await dbPool.query(
                    'SELECT rsvp_status_id FROM rsvps WHERE event_id = $1 AND user_id = $2',
                    [event_id, req.user.id]
                );

                // If changing from non-attending to attending, check capacity
                if (currentRsvp.rows.length === 0 || currentRsvp.rows[0].rsvp_status_id !== statusMappings['attending']) {
                    if (currentAttending >= event.max_players) {
                        return res.status(409).json({
                            error: 'Event is at maximum capacity',
                            code: 'EVENT_FULL',
                            details: {
                                max_players: event.max_players,
                                current_attending: currentAttending
                            }
                        });
                    }
                }
            }

            // Upsert RSVP
            const statusId = statusMappings[status];
            const result = await dbPool.query(`
                INSERT INTO rsvps (event_id, user_id, rsvp_status_id, notes)
                VALUES ($1, $2, $3, $4)
                ON CONFLICT (event_id, user_id)
                DO UPDATE SET 
                    rsvp_status_id = EXCLUDED.rsvp_status_id,
                    notes = EXCLUDED.notes,
                    response_date = CURRENT_TIMESTAMP
                RETURNING id, event_id, user_id, rsvp_status_id, notes, response_date
            `, [event_id, req.user.id, statusId, notes]);

            const rsvp = result.rows[0];
            rsvp.status = status; // Add the string status for response

            res.json({
                message: 'RSVP saved successfully',
                rsvp: rsvp
            });

        } catch (error) {
            console.error('RSVP error:', error);
            res.status(500).json({
                error: 'Failed to save RSVP',
                code: 'RSVP_ERROR'
            });
        }
    }
);

// Update existing RSVP
router.put('/:eventId',
    authenticateToken,
    async (req, res) => {
        try {
            const { eventId } = req.params;

            // Validate input
            const { error, value } = updateRsvpSchema.validate(req.body);
            if (error) {
                return res.status(400).json({
                    error: 'Validation failed',
                    details: error.details.map(d => d.message),
                    code: 'VALIDATION_ERROR'
                });
            }

            const { status, notes } = value;

            // Check if RSVP exists
            const rsvpResult = await dbPool.query(
                'SELECT id FROM rsvps WHERE event_id = $1 AND user_id = $2',
                [eventId, req.user.id]
            );

            if (rsvpResult.rows.length === 0) {
                return res.status(404).json({
                    error: 'RSVP not found',
                    code: 'RSVP_NOT_FOUND'
                });
            }

            // Get event for capacity check
            const eventResult = await dbPool.query(`
                SELECT e.max_players,
                       COUNT(r.id) FILTER (WHERE r.rsvp_status_id = $3 AND r.user_id != $2) as other_attending
                FROM events e
                LEFT JOIN rsvps r ON e.id = r.event_id
                WHERE e.id = $1
                GROUP BY e.id
            `, [eventId, req.user.id, statusMappings['attending']]);

            const event = eventResult.rows[0];

            // Check capacity if changing to attending
            if (status === 'attending' && event.max_players) {
                const otherAttending = parseInt(event.other_attending) || 0;
                if (otherAttending >= event.max_players) {
                    return res.status(409).json({
                        error: 'Event is at maximum capacity',
                        code: 'EVENT_FULL',
                        details: {
                            max_players: event.max_players,
                            current_attending: otherAttending
                        }
                    });
                }
            }

            // Update RSVP
            const statusId = statusMappings[status];
            const result = await dbPool.query(`
                UPDATE rsvps 
                SET rsvp_status_id = $1, notes = $2, response_date = CURRENT_TIMESTAMP
                WHERE event_id = $3 AND user_id = $4
                RETURNING id, event_id, user_id, rsvp_status_id, notes, response_date
            `, [statusId, notes, eventId, req.user.id]);

            const rsvp = result.rows[0];
            rsvp.status = status; // Add the string status for response

            res.json({
                message: 'RSVP updated successfully',
                rsvp: rsvp
            });

        } catch (error) {
            console.error('Update RSVP error:', error);
            res.status(500).json({
                error: 'Failed to update RSVP',
                code: 'UPDATE_RSVP_ERROR'
            });
        }
    }
);

// Get RSVP for specific event
router.get('/event/:eventId',
    authenticateToken,
    async (req, res) => {
        try {
            const { eventId } = req.params;

            // Get user's RSVP for this event
            const result = await dbPool.query(`
                SELECT r.id, r.event_id, r.user_id, r.notes, r.response_date,
                       rs.name as status_name, rs.display_name,
                       e.title as event_title, e.event_date
                FROM rsvps r
                JOIN rsvp_statuses rs ON r.rsvp_status_id = rs.id
                JOIN events e ON r.event_id = e.id
                WHERE r.event_id = $1 AND r.user_id = $2
            `, [eventId, req.user.id]);

            if (result.rows.length === 0) {
                return res.status(404).json({
                    error: 'RSVP not found',
                    code: 'RSVP_NOT_FOUND'
                });
            }

            const rsvp = result.rows[0];
            // Convert status to expected format
            rsvp.status = dbToApiStatusMappings[rsvp.status_name] || rsvp.status_name;

            res.json({
                rsvp: rsvp
            });

        } catch (error) {
            console.error('Get RSVP error:', error);
            res.status(500).json({
                error: 'Failed to get RSVP',
                code: 'GET_RSVP_ERROR'
            });
        }
    }
);

// Get all RSVPs for a user
router.get('/my-rsvps',
    authenticateToken,
    async (req, res) => {
        try {
            const { 
                team_id, 
                status, 
                start_date, 
                end_date, 
                limit = 50, 
                offset = 0 
            } = req.query;

            let query = `
                SELECT r.id, r.event_id, r.notes, r.response_date,
                       rs.name as status_name, rs.display_name, rs.color,
                       e.title as event_title, e.description, e.event_date,
                       e.duration_minutes, t.name as team_name,
                       v.name as venue_name, v.address as venue_address,
                       et.name as event_type_name, et.display_name as event_type_display
                FROM rsvps r
                JOIN rsvp_statuses rs ON r.rsvp_status_id = rs.id
                JOIN events e ON r.event_id = e.id
                JOIN teams t ON e.team_id = t.id
                LEFT JOIN venues v ON e.venue_id = v.id
                LEFT JOIN event_types et ON e.event_type_id = et.id
                WHERE r.user_id = $1
            `;

            const queryParams = [req.user.id];
            let paramCount = 1;

            if (team_id) {
                query += ` AND e.team_id = $${++paramCount}`;
                queryParams.push(team_id);
            }

            if (status) {
                const statusId = statusMappings[status];
                if (statusId) {
                    query += ` AND r.rsvp_status_id = $${++paramCount}`;
                    queryParams.push(statusId);
                }
            }

            if (start_date) {
                query += ` AND e.event_date >= $${++paramCount}`;
                queryParams.push(start_date);
            }

            if (end_date) {
                query += ` AND e.event_date <= $${++paramCount}`;
                queryParams.push(end_date);
            }

            query += `
                ORDER BY e.event_date DESC
                LIMIT $${++paramCount} OFFSET $${++paramCount}
            `;
            queryParams.push(parseInt(limit), parseInt(offset));

            const result = await dbPool.query(query, queryParams);

            // Convert status to expected format
            const rsvps = result.rows.map(rsvp => ({
                ...rsvp,
                status: dbToApiStatusMappings[rsvp.status_name] || rsvp.status_name
            }));

            res.json({
                rsvps: rsvps,
                pagination: {
                    limit: parseInt(limit),
                    offset: parseInt(offset),
                    total: result.rows.length
                }
            });

        } catch (error) {
            console.error('Get my RSVPs error:', error);
            res.status(500).json({
                error: 'Failed to get RSVPs',
                code: 'GET_MY_RSVPS_ERROR'
            });
        }
    }
);

// Get RSVP list for event (coaches/managers only)
router.get('/event/:eventId/attendees',
    authenticateToken,
    async (req, res) => {
        try {
            const { eventId } = req.params;

            // Get event and check permissions
            const eventCheck = await dbPool.query(
                'SELECT team_id FROM events WHERE id = $1',
                [eventId]
            );

            if (eventCheck.rows.length === 0) {
                return res.status(404).json({
                    error: 'Event not found',
                    code: 'EVENT_NOT_FOUND'
                });
            }

            const teamId = eventCheck.rows[0].team_id;

            // Check authorization (team member or admin)
            const authCheck = await dbPool.query(`
                SELECT tm.team_id, 'member' as membership_type, r.name as system_role
                FROM team_members tm
                LEFT JOIN user_roles ur ON ur.user_id = tm.user_id AND ur.is_active = true
                LEFT JOIN roles r ON ur.role_id = r.id
                WHERE tm.user_id = $1 AND tm.team_id = $2 AND tm.is_active = true
                UNION
                SELECT NULL, NULL, r.name
                FROM user_roles ur
                JOIN roles r ON ur.role_id = r.id
                WHERE ur.user_id = $1 AND r.name IN ('admin', 'super_admin') AND ur.is_active = true
            `, [req.user.id, teamId]);

            if (authCheck.rows.length === 0) {
                return res.status(403).json({
                    error: 'Not authorized to view attendee list',
                    code: 'VIEW_ATTENDEES_DENIED'
                });
            }

            // Get RSVP details with user information
            const result = await dbPool.query(`
                SELECT rs.name as status_name, rs.display_name as status_display, 
                       rs.color as status_color, r.notes, r.response_date,
                       u.id as user_id, u.name as full_name, u.email,
                       p.name as position_name
                FROM rsvps r
                JOIN rsvp_statuses rs ON r.rsvp_status_id = rs.id
                JOIN users u ON r.user_id = u.id
                LEFT JOIN team_members tm ON u.id = tm.user_id AND tm.team_id = $2
                LEFT JOIN positions p ON tm.position_id = p.id
                WHERE r.event_id = $1
                ORDER BY rs.sort_order, u.name
            `, [eventId, teamId]);

            // Group by status
            const attendees = {
                attending: [],
                not_attending: [],
                maybe: [],
                no_response: []
            };

            // Get all team members for no_response list
            const allMembers = await dbPool.query(`
                SELECT u.id, u.name as full_name, u.email,
                       p.name as position_name
                FROM team_members tm
                JOIN users u ON tm.user_id = u.id
                LEFT JOIN positions p ON tm.position_id = p.id
                WHERE tm.team_id = $1 AND tm.is_active = true
                ORDER BY u.name
            `, [teamId]);

            const rsvpUserIds = new Set(result.rows.map(row => row.user_id));

            // Add members who haven't responded
            allMembers.rows.forEach(member => {
                if (!rsvpUserIds.has(member.id)) {
                    attendees.no_response.push({
                        user_id: member.id,
                        full_name: member.full_name,
                        email: member.email,
                        position_name: member.position_name,
                        status: null,
                        notes: null,
                        response_date: null
                    });
                }
            });

            // Group RSVPs by status
            result.rows.forEach(row => {
                const statusKey = dbToApiStatusMappings[row.status_name] || 'no_response';
                if (attendees[statusKey]) {
                    attendees[statusKey].push({
                        ...row,
                        status: statusKey
                    });
                }
            });

            res.json({
                attendees,
                summary: {
                    attending: attendees.attending.length,
                    not_attending: attendees.not_attending.length,
                    maybe: attendees.maybe.length,
                    no_response: attendees.no_response.length,
                    total: allMembers.rows.length
                }
            });

        } catch (error) {
            console.error('Get attendees error:', error);
            res.status(500).json({
                error: 'Failed to get attendees',
                code: 'GET_ATTENDEES_ERROR'
            });
        }
    }
);

// Delete RSVP
router.delete('/event/:eventId',
    authenticateToken,
    async (req, res) => {
        try {
            const { eventId } = req.params;

            const result = await dbPool.query(
                'DELETE FROM rsvps WHERE event_id = $1 AND user_id = $2 RETURNING *',
                [eventId, req.user.id]
            );

            if (result.rows.length === 0) {
                return res.status(404).json({
                    error: 'RSVP not found',
                    code: 'RSVP_NOT_FOUND'
                });
            }

            res.json({
                message: 'RSVP deleted successfully'
            });

        } catch (error) {
            console.error('Delete RSVP error:', error);
            res.status(500).json({
                error: 'Failed to delete RSVP',
                code: 'DELETE_RSVP_ERROR'
            });
        }
    }
);

module.exports = { router, setDbPool };