const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Joi = require('joi');
const crypto = require('crypto');
const { Pool } = require('pg');
const { authLimiter, passwordResetLimiter } = require('../middleware/rateLimit');

const router = express.Router();

// Database pool will be injected
let dbPool;

const setDbPool = (pool) => {
    dbPool = pool;
};

// Validation schemas
const registerSchema = Joi.object({
    email: Joi.string().email().required().max(255),
    password: Joi.string().min(8).max(100).required(),
    name: Joi.string().min(1).max(100).required(),
    phone: Joi.string().pattern(/^[\+]?[1-9][\d]{0,15}$/).optional()
});

const loginSchema = Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().required()
});

const changePasswordSchema = Joi.object({
    current_password: Joi.string().required(),
    new_password: Joi.string().min(8).max(100).required()
});

// Helper function to generate JWT token
const generateToken = (userId, sessionId) => {
    return jwt.sign(
        { userId, sessionId },
        process.env.JWT_SECRET || 'fallback-secret-key',
        { expiresIn: '24h' }
    );
};

// Helper function to create user session
const createUserSession = async (userId, userAgent, ipAddress) => {
    const sessionToken = crypto.randomBytes(32).toString('hex');
    const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours
    
    const result = await dbPool.query(`
        INSERT INTO user_sessions (user_id, session_token, user_agent, ip_address, expires_at)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING id
    `, [userId, sessionToken, userAgent, ipAddress, expiresAt]);
    
    return { sessionId: result.rows[0].id, token: sessionToken };
};

// Register new user
router.post('/register', authLimiter, async (req, res) => {
    try {
        // Validate input
        const { error, value } = registerSchema.validate(req.body);
        if (error) {
            return res.status(400).json({
                error: 'Validation failed',
                details: error.details.map(d => d.message),
                code: 'VALIDATION_ERROR'
            });
        }

        const { email, password, name, phone } = value;

        // Check if user already exists
        const existingUser = await dbPool.query(
            'SELECT id FROM users WHERE email = $1',
            [email.toLowerCase()]
        );

        if (existingUser.rows.length > 0) {
            return res.status(409).json({
                error: 'User already exists with this email',
                code: 'USER_EXISTS'
            });
        }

        // Hash password
        const saltRounds = 12;
        const hashedPassword = await bcrypt.hash(password, saltRounds);

        // Create user
        const result = await dbPool.query(`
            INSERT INTO users (email, password_hash, name, phone, is_active)
            VALUES ($1, $2, $3, $4, true)
            RETURNING id, email, name, created_at
        `, [email.toLowerCase(), hashedPassword, name, phone]);

        const user = result.rows[0];

        // Assign default player role
        const roleResult = await dbPool.query(
            'SELECT id FROM roles WHERE name = $1',
            ['player']
        );

        if (roleResult.rows.length > 0) {
            await dbPool.query(`
                INSERT INTO user_roles (user_id, role_id, is_active)
                VALUES ($1, $2, true)
            `, [user.id, roleResult.rows[0].id]);
        }

        // Create session
        const userAgent = req.get('User-Agent') || '';
        const ipAddress = req.ip || req.connection.remoteAddress;
        const { sessionId, token } = await createUserSession(user.id, userAgent, ipAddress);

        // Generate JWT
        const jwtToken = generateToken(user.id, sessionId);

        res.status(201).json({
            message: 'User registered successfully',
            user: {
                id: user.id,
                email: user.email,
                name: user.name,
                created_at: user.created_at
            },
            token: jwtToken,
            expires_in: 86400 // 24 hours in seconds
        });

    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({
            error: 'Registration failed',
            code: 'REGISTRATION_ERROR'
        });
    }
});

// Login user
router.post('/login', authLimiter, async (req, res) => {
    try {
        // Validate input
        const { error, value } = loginSchema.validate(req.body);
        if (error) {
            return res.status(400).json({
                error: 'Validation failed',
                details: error.details.map(d => d.message),
                code: 'VALIDATION_ERROR'
            });
        }

        const { email, password } = value;

        // Get user
        const result = await dbPool.query(`
            SELECT id, email, password_hash, name, is_active
            FROM users 
            WHERE email = $1
        `, [email.toLowerCase()]);

        if (result.rows.length === 0) {
            return res.status(401).json({
                error: 'Invalid email or password',
                code: 'INVALID_CREDENTIALS'
            });
        }

        const user = result.rows[0];

        if (!user.is_active) {
            return res.status(401).json({
                error: 'Account is deactivated',
                code: 'ACCOUNT_DEACTIVATED'
            });
        }

        // Verify password
        const passwordMatch = await bcrypt.compare(password, user.password_hash);
        if (!passwordMatch) {
            return res.status(401).json({
                error: 'Invalid email or password',
                code: 'INVALID_CREDENTIALS'
            });
        }

        // Create session
        const userAgent = req.get('User-Agent') || '';
        const ipAddress = req.ip || req.connection.remoteAddress;
        const { sessionId, token } = await createUserSession(user.id, userAgent, ipAddress);

        // Get user roles
        const rolesResult = await dbPool.query(`
            SELECT COALESCE(json_agg(r.name) FILTER (WHERE r.name IS NOT NULL), '[]') as roles
            FROM user_roles ur
            LEFT JOIN roles r ON ur.role_id = r.id
            WHERE ur.user_id = $1 AND ur.is_active = true
        `, [user.id]);

        const userRoles = rolesResult.rows[0]?.roles || [];
        console.log('🔍 LOGIN DEBUG - Roles result:', JSON.stringify(rolesResult.rows[0]));
        console.log('🔍 LOGIN DEBUG - User roles array:', JSON.stringify(userRoles));

        // Generate JWT
        const jwtToken = generateToken(user.id, sessionId);

        res.json({
            message: 'Login successful',
            user: {
                id: user.id,
                email: user.email,
                name: user.name,
                roles: userRoles
            },
            token: jwtToken,
            expires_in: 86400 // 24 hours in seconds
        });

    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({
            error: 'Login failed',
            code: 'LOGIN_ERROR'
        });
    }
});

// Logout user (invalidate session)
router.post('/logout', async (req, res) => {
    try {
        const authHeader = req.headers['authorization'];
        const token = authHeader && authHeader.split(' ')[1];

        if (token) {
            try {
                const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback-secret-key');
                
                // Invalidate session
                await dbPool.query(`
                    UPDATE user_sessions 
                    SET expires_at = CURRENT_TIMESTAMP 
                    WHERE id = $1
                `, [decoded.sessionId]);
            } catch (error) {
                // Token might be invalid, but we'll still return success
                console.log('Invalid token during logout:', error.message);
            }
        }

        res.json({
            message: 'Logout successful'
        });

    } catch (error) {
        console.error('Logout error:', error);
        res.status(500).json({
            error: 'Logout failed',
            code: 'LOGOUT_ERROR'
        });
    }
});

// Get current user profile
router.get('/me', require('../middleware/auth').authenticateToken, async (req, res) => {
    try {
        // Get user with roles
        const result = await dbPool.query(`
            SELECT u.id, u.email, u.name, u.phone, 
                   u.created_at,
                   COALESCE(json_agg(r.name) FILTER (WHERE r.name IS NOT NULL), '[]') as roles
            FROM users u
            LEFT JOIN user_roles ur ON u.id = ur.user_id AND ur.is_active = true
            LEFT JOIN roles r ON ur.role_id = r.id
            WHERE u.id = $1
            GROUP BY u.id
        `, [req.user.id]);

        if (result.rows.length === 0) {
            return res.status(404).json({
                error: 'User not found',
                code: 'USER_NOT_FOUND'
            });
        }

        res.json({
            user: result.rows[0]
        });

    } catch (error) {
        console.error('Get profile error:', error);
        res.status(500).json({
            error: 'Failed to get profile',
            code: 'PROFILE_ERROR'
        });
    }
});

// Update user profile
const updateProfileSchema = Joi.object({
    name: Joi.string().min(1).max(100).required(),
    phone: Joi.string().pattern(/^[\+]?[1-9][\d]{0,15}$/).allow('').optional(),
    emergency_contact: Joi.string().max(100).allow('').optional(),
    emergency_phone: Joi.string().pattern(/^[\+]?[1-9][\d]{0,15}$/).allow('').optional(),
    date_of_birth: Joi.date().iso().allow('').optional(),
    address: Joi.string().max(500).allow('').optional()
});

router.put('/profile', require('../middleware/auth').authenticateToken, async (req, res) => {
    try {
        // Validate input
        const { error, value } = updateProfileSchema.validate(req.body);
        if (error) {
            return res.status(400).json({
                error: 'Validation failed',
                details: error.details.map(d => d.message),
                code: 'VALIDATION_ERROR'
            });
        }

        const { name, phone, emergency_contact, emergency_phone, date_of_birth, address } = value;

        // Update user profile
        const result = await dbPool.query(`
            UPDATE users 
            SET name = $1, 
                phone = $2, 
                emergency_contact = $3,
                emergency_phone = $4,
                date_of_birth = $5,
                address = $6,
                updated_at = CURRENT_TIMESTAMP 
            WHERE id = $7
            RETURNING id, email, name, phone, emergency_contact, emergency_phone, date_of_birth, address, created_at
        `, [name, phone || null, emergency_contact || null, emergency_phone || null, date_of_birth || null, address || null, req.user.id]);

        if (result.rows.length === 0) {
            return res.status(404).json({
                error: 'User not found',
                code: 'USER_NOT_FOUND'
            });
        }

        // Get updated user with roles
        const userWithRoles = await dbPool.query(`
            SELECT u.id, u.email, u.name, u.phone, u.emergency_contact, u.emergency_phone, 
                   u.date_of_birth, u.address, u.created_at,
                   COALESCE(json_agg(r.name) FILTER (WHERE r.name IS NOT NULL), '[]') as roles
            FROM users u
            LEFT JOIN user_roles ur ON u.id = ur.user_id AND ur.is_active = true
            LEFT JOIN roles r ON ur.role_id = r.id
            WHERE u.id = $1
            GROUP BY u.id
        `, [req.user.id]);

        res.json({
            message: 'Profile updated successfully',
            user: userWithRoles.rows[0]
        });

    } catch (error) {
        console.error('Update profile error:', error);
        res.status(500).json({
            error: 'Failed to update profile',
            code: 'PROFILE_UPDATE_ERROR'
        });
    }
});

// Change password
router.post('/change-password', 
    require('../middleware/auth').authenticateToken,
    authLimiter,
    async (req, res) => {
        try {
            // Validate input
            const { error, value } = changePasswordSchema.validate(req.body);
            if (error) {
                return res.status(400).json({
                    error: 'Validation failed',
                    details: error.details.map(d => d.message),
                    code: 'VALIDATION_ERROR'
                });
            }

            const { current_password, new_password } = value;

            // Get current password hash
            const result = await dbPool.query(
                'SELECT password_hash FROM users WHERE id = $1',
                [req.user.id]
            );

            if (result.rows.length === 0) {
                return res.status(404).json({
                    error: 'User not found',
                    code: 'USER_NOT_FOUND'
                });
            }

            // Verify current password
            const passwordMatch = await bcrypt.compare(current_password, result.rows[0].password_hash);
            if (!passwordMatch) {
                return res.status(401).json({
                    error: 'Current password is incorrect',
                    code: 'INVALID_CURRENT_PASSWORD'
                });
            }

            // Hash new password
            const saltRounds = 12;
            const hashedPassword = await bcrypt.hash(new_password, saltRounds);

            // Update password
            await dbPool.query(`
                UPDATE users 
                SET password_hash = $1, updated_at = CURRENT_TIMESTAMP 
                WHERE id = $2
            `, [hashedPassword, req.user.id]);

            // Invalidate all other sessions except current one
            await dbPool.query(`
                UPDATE user_sessions 
                SET expires_at = CURRENT_TIMESTAMP 
                WHERE user_id = $1 AND id != $2
            `, [req.user.id, req.user.session_id]);

            res.json({
                message: 'Password changed successfully'
            });

        } catch (error) {
            console.error('Change password error:', error);
            res.status(500).json({
                error: 'Failed to change password',
                code: 'PASSWORD_CHANGE_ERROR'
            });
        }
    }
);

module.exports = { router, setDbPool };