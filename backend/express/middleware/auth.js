const jwt = require('jsonwebtoken');
const redis = require('redis');
const bcrypt = require('bcryptjs');

const JWT_SECRET = process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-in-production';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '24h';

// Redis client for token blacklisting
let redisClient = null;

async function initRedis() {
  try {
    redisClient = redis.createClient({
      host: process.env.REDIS_HOST || 'redis',
      port: process.env.REDIS_PORT || 6379,
      retry_strategy: (options) => {
        if (options.error && options.error.code === 'ECONNREFUSED') {
          console.log('Redis server connection refused');
        }
        if (options.total_retry_time > 1000 * 60 * 60) {
          return new Error('Retry time exhausted');
        }
        if (options.attempt > 10) {
          return undefined;
        }
        return Math.min(options.attempt * 100, 3000);
      }
    });

    redisClient.on('error', (err) => {
      console.error('Redis error:', err);
    });

    redisClient.on('connect', () => {
      console.log('✅ Redis connected for JWT blacklisting');
    });

    await redisClient.connect();
  } catch (error) {
    console.error('⚠️  Redis initialization failed:', error.message);
    console.log('JWT tokens will work but logout blacklisting will be disabled');
  }
}

// Initialize Redis connection
initRedis();

/**
 * Generate JWT token for user
 */
function generateToken(user) {
  const payload = {
    id: user.id,
    email: user.email,
    roles: user.roles || [],
    iat: Math.floor(Date.now() / 1000)
  };

  return jwt.sign(payload, JWT_SECRET, { 
    expiresIn: JWT_EXPIRES_IN,
    issuer: 'footballhome-api',
    audience: 'footballhome-app'
  });
}

/**
 * Verify JWT token
 */
function verifyToken(token) {
  try {
    return jwt.verify(token, JWT_SECRET, {
      issuer: 'footballhome-api',
      audience: 'footballhome-app'
    });
  } catch (error) {
    throw new Error('Invalid token');
  }
}

/**
 * Hash password using bcrypt
 */
async function hashPassword(password) {
  const saltRounds = 12;
  return await bcrypt.hash(password, saltRounds);
}

/**
 * Compare password with hash
 */
async function comparePassword(password, hash) {
  return await bcrypt.compare(password, hash);
}

/**
 * Add token to blacklist (for logout)
 */
async function blacklistToken(token) {
  if (!redisClient) {
    console.log('Redis not available - token blacklisting skipped');
    return;
  }

  try {
    const decoded = jwt.decode(token);
    if (decoded && decoded.exp) {
      // Set expiry to match token expiry
      const ttl = decoded.exp - Math.floor(Date.now() / 1000);
      if (ttl > 0) {
        await redisClient.setEx(`blacklist:${token}`, ttl, 'true');
      }
    }
  } catch (error) {
    console.error('Error blacklisting token:', error);
  }
}

/**
 * Check if token is blacklisted
 */
async function isTokenBlacklisted(token) {
  if (!redisClient) {
    return false; // If Redis is not available, don't block tokens
  }

  try {
    const result = await redisClient.get(`blacklist:${token}`);
    return result === 'true';
  } catch (error) {
    console.error('Error checking token blacklist:', error);
    return false; // On error, don't block the token
  }
}

/**
 * JWT Authentication middleware
 */
const requireJWTAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: 'Authentication required - No token provided'
      });
    }

    const token = authHeader.substring(7); // Remove 'Bearer ' prefix

    // Check if token is blacklisted
    if (await isTokenBlacklisted(token)) {
      return res.status(401).json({
        success: false,
        error: 'Token has been invalidated'
      });
    }

    // Verify token
    const decoded = verifyToken(token);
    
    // Add user info to request
    req.user = {
      id: decoded.id,
      email: decoded.email,
      roles: decoded.roles || []
    };

    req.token = token; // Store token for potential blacklisting

    next();
  } catch (error) {
    console.error('JWT Auth error:', error.message);
    return res.status(401).json({
      success: false,
      error: 'Invalid or expired token'
    });
  }
};

/**
 * Optional JWT Authentication middleware (doesn't fail if no token)
 */
const optionalJWTAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      
      // Check if token is blacklisted
      if (!(await isTokenBlacklisted(token))) {
        try {
          const decoded = verifyToken(token);
          req.user = {
            id: decoded.id,
            email: decoded.email,
            roles: decoded.roles || []
          };
          req.token = token;
        } catch (error) {
          // Token invalid, but that's ok for optional auth
          console.log('Invalid token in optional auth:', error.message);
        }
      }
    }
    
    next();
  } catch (error) {
    // Don't fail on optional auth errors
    next();
  }
};

/**
 * Role-based authorization middleware
 */
const requireRole = (requiredRoles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: 'Authentication required'
      });
    }

    const userRoles = req.user.roles || [];
    const hasRequiredRole = requiredRoles.some(role => userRoles.includes(role));

    if (!hasRequiredRole) {
      return res.status(403).json({
        success: false,
        error: `Access denied - requires one of: ${requiredRoles.join(', ')}`
      });
    }

    next();
  };
};

/**
 * Admin role check
 */
const requireAdmin = requireRole(['admin']);

/**
 * Coach or Admin role check
 */
const requireCoachOrAdmin = requireRole(['coach', 'admin']);

module.exports = {
  generateToken,
  verifyToken,
  hashPassword,
  comparePassword,
  blacklistToken,
  isTokenBlacklisted,
  requireJWTAuth,
  optionalJWTAuth,
  requireRole,
  requireAdmin,
  requireCoachOrAdmin,
  initRedis
};