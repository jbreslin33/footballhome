const jwt = require('jsonwebtoken');
const { Pool } = require('pg');

// Database pool - we'll inject this from the main server
let dbPool;

const setDbPool = (pool) => {
    dbPool = pool;
};

// Middleware to verify JWT tokens
const authenticateToken = async (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
        return res.status(401).json({ 
            error: 'Access token required',
            code: 'TOKEN_REQUIRED'
        });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback-secret-key');
        
        // Verify user still exists and session is valid
        const result = await dbPool.query(`
            SELECT u.id, u.email, u.name, u.is_active,
                   us.id as session_id, us.expires_at
            FROM users u
            JOIN user_sessions us ON u.id = us.user_id AND us.id = $1 AND us.expires_at > NOW() AND us.is_active = true
            WHERE u.id = $2 AND u.is_active = true
        `, [decoded.sessionId, decoded.userId]);

        if (result.rows.length === 0) {
            return res.status(401).json({ 
                error: 'Invalid or expired token',
                code: 'TOKEN_INVALID'
            });
        }

        req.user = result.rows[0];
        next();
    } catch (error) {
        console.error('Token verification error:', error);
        return res.status(403).json({ 
            error: 'Invalid token',
            code: 'TOKEN_MALFORMED'
        });
    }
};

// Middleware to check if user has specific role
const requireRole = (roles) => {
    return async (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({ 
                error: 'Authentication required',
                code: 'AUTH_REQUIRED'
            });
        }

        try {
            // Get user roles
            const result = await dbPool.query(`
                SELECT r.name as role_name, r.permissions
                FROM user_roles ur
                JOIN roles r ON ur.role_id = r.id
                WHERE ur.user_id = $1 AND ur.is_active = true
            `, [req.user.id]);

            const userRoles = result.rows.map(row => row.role_name);
            
            // Check if user has any of the required roles
            const hasRole = roles.some(role => userRoles.includes(role));
            
            if (!hasRole) {
                return res.status(403).json({ 
                    error: 'Insufficient permissions',
                    code: 'INSUFFICIENT_PERMISSIONS',
                    required: roles,
                    current: userRoles
                });
            }

            req.userRoles = userRoles;
            next();
        } catch (error) {
            console.error('Role check error:', error);
            return res.status(500).json({ 
                error: 'Permission check failed',
                code: 'PERMISSION_CHECK_ERROR'
            });
        }
    };
};

// Middleware to check if user belongs to specific team
const requireTeamMembership = (teamIdParam = 'teamId') => {
    return async (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({ 
                error: 'Authentication required',
                code: 'AUTH_REQUIRED'
            });
        }

        const teamId = req.params[teamIdParam] || req.body.team_id || req.query.team_id;
        
        if (!teamId) {
            return res.status(400).json({ 
                error: 'Team ID required',
                code: 'TEAM_ID_REQUIRED'
            });
        }

        try {
            // Check if user is member of the team or has admin role
            const result = await dbPool.query(`
                SELECT tm.team_id, tm.role as team_role, r.name as system_role
                FROM team_members tm
                LEFT JOIN user_roles ur ON ur.user_id = tm.user_id AND ur.is_active = true
                LEFT JOIN roles r ON ur.role_id = r.id
                WHERE tm.user_id = $1 AND tm.team_id = $2 AND tm.is_active = true
            `, [req.user.id, teamId]);

            if (result.rows.length === 0) {
                // Check if user has admin role (can access any team)
                const adminCheck = await dbPool.query(`
                    SELECT r.name
                    FROM user_roles ur
                    JOIN roles r ON ur.role_id = r.id
                    WHERE ur.user_id = $1 AND r.name IN ('admin', 'super_admin') AND ur.is_active = true
                `, [req.user.id]);

                if (adminCheck.rows.length === 0) {
                    return res.status(403).json({ 
                        error: 'Not authorized for this team',
                        code: 'TEAM_ACCESS_DENIED'
                    });
                }
            }

            req.teamMembership = result.rows[0] || { system_role: 'admin' };
            next();
        } catch (error) {
            console.error('Team membership check error:', error);
            return res.status(500).json({ 
                error: 'Team access check failed',
                code: 'TEAM_CHECK_ERROR'
            });
        }
    };
};

// Optional authentication - sets req.user if token is valid but doesn't require it
const optionalAuth = async (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        return next();
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback-secret-key');
        
        const result = await dbPool.query(`
            SELECT u.id, u.email, u.name, u.is_active
            FROM users u
            WHERE u.id = $1 AND u.is_active = true
        `, [decoded.userId]);

        if (result.rows.length > 0) {
            req.user = result.rows[0];
        }
    } catch (error) {
        // Ignore token errors for optional auth
        console.log('Optional auth token invalid:', error.message);
    }

    next();
};

module.exports = {
    setDbPool,
    authenticateToken,
    requireRole,
    requireTeamMembership,
    optionalAuth
};