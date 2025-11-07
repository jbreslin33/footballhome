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

// Validation schema for creating practices
const createPracticeSchema = Joi.object({
    // Event fields
    team_id: Joi.string().uuid().required(),
    event_type_id: Joi.string().uuid().required(),
    title: Joi.string().min(1).max(200).required(),
    description: Joi.string().max(2000).optional().allow(''),
    event_date: Joi.date().iso().required(),
    venue_id: Joi.string().uuid().optional().allow(null),
    duration_minutes: Joi.number().integer().min(15).max(300).default(90),
    max_players: Joi.number().integer().min(1).optional().allow(null),
    
    // Practice-specific fields
    focus_areas: Joi.array().items(Joi.string().max(50)).optional().default([]),
    drill_plan: Joi.string().max(5000).optional().allow(''),
    equipment_needed: Joi.array().items(Joi.string().max(50)).optional().default([]),
    fitness_focus: Joi.string().valid('endurance', 'strength', 'agility', 'speed', 'flexibility').optional().allow(''),
    skill_level: Joi.string().valid('beginner', 'intermediate', 'advanced').default('intermediate'),
    weather_dependent: Joi.boolean().default(true),
    indoor_alternative_location: Joi.string().max(255).optional().allow(''),
    notes: Joi.string().max(2000).optional().allow('')
});

// Get practices for a team
router.get('/team/:teamId', 
    authenticateToken,
    requireTeamMembership('teamId'),
    async (req, res) => {
        try {
            const { teamId } = req.params;
            const { 
                start_date, 
                end_date, 
                limit = 50, 
                offset = 0 
            } = req.query;

            let query = `
                SELECT e.*, et.name as event_type_name, et.display_name as event_type_display,
                       v.name as venue_name, v.address as venue_address,
                       p.focus_areas, p.drill_plan, p.equipment_needed, p.fitness_focus,
                       p.skill_level, p.weather_dependent, p.indoor_alternative_location,
                       p.notes as practice_notes,
                       COUNT(r.id) as rsvp_count,
                       COUNT(CASE WHEN r.rsvp_status_id = '550e8400-e29b-41d4-a716-446655440301' THEN 1 END) as attending_count,
                       MAX(CASE WHEN r.user_id = $1 THEN 
                           CASE 
                               WHEN r.rsvp_status_id = '550e8400-e29b-41d4-a716-446655440301' THEN 'attending'
                               WHEN r.rsvp_status_id = '550e8400-e29b-41d4-a716-446655440303' THEN 'not_attending'
                               WHEN r.rsvp_status_id = '550e8400-e29b-41d4-a716-446655440302' THEN 'maybe'
                           END
                       END) as my_rsvp_status
                FROM events e
                JOIN practices p ON e.id = p.id
                JOIN event_types et ON e.event_type_id = et.id
                LEFT JOIN venues v ON e.venue_id = v.id
                LEFT JOIN rsvps r ON e.id = r.event_id
                WHERE e.team_id = $2 AND e.cancelled = false
            `;

            const queryParams = [req.user.id, teamId];
            let paramCount = 2;

            if (start_date) {
                query += ` AND e.event_date >= $${++paramCount}`;
                queryParams.push(start_date);
            }

            if (end_date) {
                query += ` AND e.event_date <= $${++paramCount}`;
                queryParams.push(end_date);
            }

            query += `
                GROUP BY e.id, et.name, et.display_name, v.name, v.address,
                         p.focus_areas, p.drill_plan, p.equipment_needed, p.fitness_focus,
                         p.skill_level, p.weather_dependent, p.indoor_alternative_location, p.notes
                ORDER BY e.event_date ASC
                LIMIT $${++paramCount} OFFSET $${++paramCount}
            `;
            queryParams.push(parseInt(limit), parseInt(offset));

            const result = await dbPool.query(query, queryParams);

            res.json({
                practices: result.rows,
                pagination: {
                    limit: parseInt(limit),
                    offset: parseInt(offset),
                    total: result.rows.length
                }
            });

        } catch (error) {
            console.error('Get practices error:', error);
            res.status(500).json({
                error: 'Failed to get practices',
                code: 'GET_PRACTICES_ERROR'
            });
        }
    }
);

// Get single practice details
router.get('/:practiceId',
    authenticateToken,
    async (req, res) => {
        try {
            const { practiceId } = req.params;

            // Get practice with all details
            const result = await dbPool.query(`
                SELECT e.*, et.name as event_type_name, et.display_name as event_type_display,
                       v.name as venue_name, v.address as venue_address, v.latitude, v.longitude,
                       t.name as team_name,
                       p.focus_areas, p.drill_plan, p.equipment_needed, p.fitness_focus,
                       p.skill_level, p.weather_dependent, p.indoor_alternative_location,
                       p.notes as practice_notes,
                       MAX(CASE WHEN r.user_id = $1 THEN 
                         CASE r.rsvp_status_id
                           WHEN '550e8400-e29b-41d4-a716-446655440301' THEN 'attending'
                           WHEN '550e8400-e29b-41d4-a716-446655440302' THEN 'maybe'
                           WHEN '550e8400-e29b-41d4-a716-446655440303' THEN 'not_attending'
                         END
                       END) as my_rsvp_status,
                       MAX(CASE WHEN r.user_id = $1 THEN r.updated_at END) as my_rsvp_updated_at
                FROM events e
                JOIN practices p ON e.id = p.id
                JOIN event_types et ON e.event_type_id = et.id
                LEFT JOIN venues v ON e.venue_id = v.id
                LEFT JOIN teams t ON e.team_id = t.id
                LEFT JOIN rsvps r ON e.id = r.event_id
                WHERE e.id = $2
                GROUP BY e.id, et.name, et.display_name, v.name, v.address, v.latitude, v.longitude, 
                         t.name, p.focus_areas, p.drill_plan, p.equipment_needed, p.fitness_focus,
                         p.skill_level, p.weather_dependent, p.indoor_alternative_location, p.notes
            `, [req.user.id, practiceId]);

            if (result.rows.length === 0) {
                return res.status(404).json({
                    error: 'Practice not found',
                    code: 'PRACTICE_NOT_FOUND'
                });
            }

            const practice = result.rows[0];

            // Check if user has access to this practice (team member or admin)
            const accessCheck = await dbPool.query(`
                SELECT tm.team_id, 'member' as team_role, r.name as system_role
                FROM team_members tm
                LEFT JOIN user_roles ur ON ur.user_id = tm.user_id AND ur.is_active = true
                LEFT JOIN roles r ON ur.role_id = r.id
                WHERE tm.user_id = $1 AND tm.team_id = $2 AND tm.is_active = true
                UNION
                SELECT NULL, NULL, r.name
                FROM user_roles ur
                JOIN roles r ON ur.role_id = r.id
                WHERE ur.user_id = $1 AND r.name IN ('admin', 'super_admin') AND ur.is_active = true
            `, [req.user.id, practice.team_id]);

            if (accessCheck.rows.length === 0) {
                return res.status(403).json({
                    error: 'Not authorized to view this practice',
                    code: 'PRACTICE_ACCESS_DENIED'
                });
            }

            // Get RSVP summary
            const rsvpSummary = await dbPool.query(`
                SELECT 
                    COUNT(*) as total_rsvps,
                    COUNT(CASE WHEN status = 'attending' THEN 1 END) as attending,
                    COUNT(CASE WHEN status = 'not_attending' THEN 1 END) as not_attending,
                    COUNT(CASE WHEN status = 'maybe' THEN 1 END) as maybe
                FROM rsvps
                WHERE event_id = $1
            `, [practiceId]);

            res.json({
                practice: {
                    ...practice,
                    rsvp_summary: rsvpSummary.rows[0]
                }
            });

        } catch (error) {
            console.error('Get practice error:', error);
            res.status(500).json({
                error: 'Failed to get practice',
                code: 'GET_PRACTICE_ERROR'
            });
        }
    }
);

// Create new practice (coaches/admins only)
router.post('/',
    authenticateToken,
    async (req, res) => {
        try {
            // Validate input
            const { error, value } = createPracticeSchema.validate(req.body);
            if (error) {
                return res.status(400).json({
                    error: 'Validation failed',
                    details: error.details.map(d => d.message),
                    code: 'VALIDATION_ERROR'
                });
            }

            // Check if user can create practices for this team (member or admin)
            const authCheck = await dbPool.query(`
                SELECT tm.team_id, 'member' as team_role, r.name as system_role
                FROM team_members tm
                LEFT JOIN user_roles ur ON ur.user_id = tm.user_id AND ur.is_active = true
                LEFT JOIN roles r ON ur.role_id = r.id
                WHERE tm.user_id = $1 AND tm.team_id = $2 AND tm.is_active = true
                UNION
                SELECT NULL, NULL, r.name
                FROM user_roles ur
                JOIN roles r ON ur.role_id = r.id
                WHERE ur.user_id = $1 AND r.name IN ('admin', 'super_admin') AND ur.is_active = true
            `, [req.user.id, value.team_id]);

            if (authCheck.rows.length === 0) {
                return res.status(403).json({
                    error: 'Not authorized to create practices for this team',
                    code: 'CREATE_PRACTICE_DENIED'
                });
            }

            // Verify event type exists and is a practice type
            const eventTypeCheck = await dbPool.query(
                'SELECT id, category FROM event_types WHERE id = $1 AND category = $2',
                [value.event_type_id, 'practice']
            );

            if (eventTypeCheck.rows.length === 0) {
                return res.status(400).json({
                    error: 'Invalid event type for practice',
                    code: 'INVALID_EVENT_TYPE'
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

            // Start transaction
            const client = await dbPool.connect();
            try {
                await client.query('BEGIN');

                // Create event
                const eventResult = await client.query(`
                    INSERT INTO events (
                        team_id, created_by, event_type_id, title, description, 
                        event_date, venue_id, duration_minutes, max_players
                    )
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
                    RETURNING *
                `, [
                    value.team_id, req.user.id, value.event_type_id,
                    value.title, value.description, value.event_date,
                    value.venue_id, value.duration_minutes, value.max_players
                ]);

                const event = eventResult.rows[0];

                // Create practice record
                await client.query(`
                    INSERT INTO practices (
                        id, focus_areas, drill_plan, equipment_needed, fitness_focus,
                        skill_level, weather_dependent, indoor_alternative_location, notes
                    )
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
                `, [
                    event.id, value.focus_areas, value.drill_plan, value.equipment_needed,
                    value.fitness_focus, value.skill_level, value.weather_dependent,
                    value.indoor_alternative_location, value.notes
                ]);

                await client.query('COMMIT');

                res.status(201).json({
                    message: 'Practice session created successfully',
                    practice: {
                        ...event,
                        focus_areas: value.focus_areas,
                        drill_plan: value.drill_plan,
                        equipment_needed: value.equipment_needed,
                        fitness_focus: value.fitness_focus,
                        skill_level: value.skill_level,
                        weather_dependent: value.weather_dependent,
                        indoor_alternative_location: value.indoor_alternative_location,
                        notes: value.notes
                    }
                });

            } catch (error) {
                await client.query('ROLLBACK');
                throw error;
            } finally {
                client.release();
            }

        } catch (error) {
            console.error('Create practice error:', error);
            res.status(500).json({
                error: 'Failed to create practice session',
                code: 'CREATE_PRACTICE_ERROR'
            });
        }
    }
);

// Update practice (coaches/admins only)
router.put('/:practiceId',
    authenticateToken,
    async (req, res) => {
        try {
            const { practiceId } = req.params;

            // Validate input (allow partial updates)
            const updateSchema = createPracticeSchema.fork(
                ['team_id', 'event_type_id', 'title', 'event_date'], 
                schema => schema.optional()
            );
            
            const { error, value } = updateSchema.validate(req.body);
            if (error) {
                return res.status(400).json({
                    error: 'Validation failed',
                    details: error.details.map(d => d.message),
                    code: 'VALIDATION_ERROR'
                });
            }

            // Get current practice to check permissions
            const practiceResult = await dbPool.query(
                'SELECT e.team_id, e.created_by FROM events e WHERE e.id = $1',
                [practiceId]
            );

            if (practiceResult.rows.length === 0) {
                return res.status(404).json({
                    error: 'Practice not found',
                    code: 'PRACTICE_NOT_FOUND'
                });
            }

            const practice = practiceResult.rows[0];

            // Check permissions
            const authCheck = await dbPool.query(`
                SELECT tm.team_id, 'member' as team_role, r.name as system_role
                FROM team_members tm
                LEFT JOIN user_roles ur ON ur.user_id = tm.user_id AND ur.is_active = true
                LEFT JOIN roles r ON ur.role_id = r.id
                WHERE tm.user_id = $1 AND tm.team_id = $2 AND tm.is_active = true
                UNION
                SELECT NULL, NULL, r.name
                FROM user_roles ur
                JOIN roles r ON ur.role_id = r.id
                WHERE ur.user_id = $1 AND r.name IN ('admin', 'super_admin') AND ur.is_active = true
            `, [req.user.id, practice.team_id]);

            const isEventCreator = practice.created_by === req.user.id;

            if (authCheck.rows.length === 0 && !isEventCreator) {
                return res.status(403).json({
                    error: 'Not authorized to update this practice',
                    code: 'UPDATE_PRACTICE_DENIED'
                });
            }

            // Start transaction for update
            const client = await dbPool.connect();
            try {
                await client.query('BEGIN');

                // Update events table if needed
                const eventUpdates = {};
                const practiceUpdates = {};

                // Separate event and practice fields
                const eventFields = ['title', 'description', 'event_date', 'venue_id', 'duration_minutes', 'max_players'];
                const practiceFields = ['focus_areas', 'drill_plan', 'equipment_needed', 'fitness_focus', 
                                      'skill_level', 'weather_dependent', 'indoor_alternative_location', 'notes'];

                for (const [key, val] of Object.entries(value)) {
                    if (val !== undefined) {
                        if (eventFields.includes(key)) {
                            eventUpdates[key] = val;
                        } else if (practiceFields.includes(key)) {
                            practiceUpdates[key] = val;
                        }
                    }
                }

                // Update events table
                if (Object.keys(eventUpdates).length > 0) {
                    const eventUpdateFields = [];
                    const eventUpdateValues = [];
                    let eventParamCount = 0;

                    for (const [key, val] of Object.entries(eventUpdates)) {
                        eventUpdateFields.push(`${key} = $${++eventParamCount}`);
                        eventUpdateValues.push(val);
                    }

                    eventUpdateFields.push('updated_at = CURRENT_TIMESTAMP');
                    eventUpdateValues.push(practiceId);

                    const eventQuery = `
                        UPDATE events 
                        SET ${eventUpdateFields.join(', ')}
                        WHERE id = $${++eventParamCount}
                    `;

                    await client.query(eventQuery, eventUpdateValues);
                }

                // Update practices table
                if (Object.keys(practiceUpdates).length > 0) {
                    const practiceUpdateFields = [];
                    const practiceUpdateValues = [];
                    let practiceParamCount = 0;

                    for (const [key, val] of Object.entries(practiceUpdates)) {
                        practiceUpdateFields.push(`${key} = $${++practiceParamCount}`);
                        practiceUpdateValues.push(val);
                    }

                    practiceUpdateValues.push(practiceId);

                    const practiceQuery = `
                        UPDATE practices 
                        SET ${practiceUpdateFields.join(', ')}
                        WHERE id = $${++practiceParamCount}
                    `;

                    await client.query(practiceQuery, practiceUpdateValues);
                }

                await client.query('COMMIT');

                // Get updated practice
                const updatedResult = await dbPool.query(`
                    SELECT e.*, p.focus_areas, p.drill_plan, p.equipment_needed, p.fitness_focus,
                           p.skill_level, p.weather_dependent, p.indoor_alternative_location, p.notes
                    FROM events e
                    JOIN practices p ON e.id = p.id
                    WHERE e.id = $1
                `, [practiceId]);

                res.json({
                    message: 'Practice updated successfully',
                    practice: updatedResult.rows[0]
                });

            } catch (error) {
                await client.query('ROLLBACK');
                throw error;
            } finally {
                client.release();
            }

        } catch (error) {
            console.error('Update practice error:', error);
            res.status(500).json({
                error: 'Failed to update practice',
                code: 'UPDATE_PRACTICE_ERROR'
            });
        }
    }
);

// Delete practice (coaches/admins only)
router.delete('/:practiceId',
    authenticateToken,
    async (req, res) => {
        try {
            const { practiceId } = req.params;

            // Get practice to check permissions
            const practiceResult = await dbPool.query(
                'SELECT e.team_id, e.created_by FROM events e WHERE e.id = $1',
                [practiceId]
            );

            if (practiceResult.rows.length === 0) {
                return res.status(404).json({
                    error: 'Practice not found',
                    code: 'PRACTICE_NOT_FOUND'
                });
            }

            const practice = practiceResult.rows[0];

            // Check permissions
            const authCheck = await dbPool.query(`
                SELECT tm.team_id, 'member' as team_role, r.name as system_role
                FROM team_members tm
                LEFT JOIN user_roles ur ON ur.user_id = tm.user_id AND ur.is_active = true
                LEFT JOIN roles r ON ur.role_id = r.id
                WHERE tm.user_id = $1 AND tm.team_id = $2 AND tm.is_active = true
                UNION
                SELECT NULL, NULL, r.name
                FROM user_roles ur
                JOIN roles r ON ur.role_id = r.id
                WHERE ur.user_id = $1 AND r.name IN ('admin', 'super_admin') AND ur.is_active = true
            `, [req.user.id, practice.team_id]);

            const isEventCreator = practice.created_by === req.user.id;

            if (authCheck.rows.length === 0 && !isEventCreator) {
                return res.status(403).json({
                    error: 'Not authorized to delete this practice',
                    code: 'DELETE_PRACTICE_DENIED'
                });
            }

            // Delete practice (will cascade to practices table and RSVPs)
            await dbPool.query('DELETE FROM events WHERE id = $1', [practiceId]);

            res.json({
                message: 'Practice deleted successfully'
            });

        } catch (error) {
            console.error('Delete practice error:', error);
            res.status(500).json({
                error: 'Failed to delete practice',
                code: 'DELETE_PRACTICE_ERROR'
            });
        }
    }
);

module.exports = { router, setDbPool };