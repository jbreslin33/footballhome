const express = require('express');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Database pool will be injected
let dbPool;

const setDbPool = (pool) => {
    dbPool = pool;
};

// Get teams that the user has access to
router.get('/', 
    authenticateToken,
    async (req, res) => {
        try {
            // Get teams where user is a member or user is admin
            const result = await dbPool.query(`
                SELECT DISTINCT t.id, t.name, t.description, t.created_at,
                       CASE 
                         WHEN tm.is_captain = true THEN 'captain'
                         ELSE 'member'
                       END as user_role
                FROM teams t
                JOIN team_members tm ON t.id = tm.team_id
                WHERE tm.user_id = $1 AND tm.is_active = true
                UNION
                SELECT t.id, t.name, t.description, t.created_at, 'admin' as user_role
                FROM teams t, user_roles ur, roles r
                WHERE ur.user_id = $1 AND ur.role_id = r.id 
                AND r.name IN ('admin', 'super_admin') AND ur.is_active = true
                ORDER BY name
            `, [req.user.id]);
            
            res.json({
                teams: result.rows
            });
            
        } catch (error) {
            console.error('Get teams error:', error);
            res.status(500).json({
                error: 'Failed to get teams',
                code: 'GET_TEAMS_ERROR'
            });
        }
    }
);

// Get team details
router.get('/:teamId',
    authenticateToken,
    async (req, res) => {
        try {
            const { teamId } = req.params;
            
            // Check if user has access to this team
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
            `, [req.user.id, teamId]);
            
            if (accessCheck.rows.length === 0) {
                return res.status(403).json({
                    error: 'Not authorized to view this team',
                    code: 'TEAM_ACCESS_DENIED'
                });
            }
            
            // Get team details with member count
            const result = await dbPool.query(`
                SELECT t.*, 
                       COUNT(tm.id) as member_count,
                       COUNT(CASE WHEN tm.role = 'coach' THEN 1 END) as coach_count,
                       COUNT(CASE WHEN tm.role = 'player' THEN 1 END) as player_count
                FROM teams t
                LEFT JOIN team_members tm ON t.id = tm.team_id AND tm.is_active = true
                WHERE t.id = $1
                GROUP BY t.id
            `, [teamId]);
            
            if (result.rows.length === 0) {
                return res.status(404).json({
                    error: 'Team not found',
                    code: 'TEAM_NOT_FOUND'
                });
            }
            
            res.json({
                team: result.rows[0]
            });
            
        } catch (error) {
            console.error('Get team error:', error);
            res.status(500).json({
                error: 'Failed to get team',
                code: 'GET_TEAM_ERROR'
            });
        }
    }
);

module.exports = { router, setDbPool };