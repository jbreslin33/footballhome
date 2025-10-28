const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { Pool } = require('pg');
const twilio = require('twilio');
const sgMail = require('@sendgrid/mail');
const session = require('express-session');
const path = require('path');

const app = express();
const port = process.env.PORT || 3000;

// Database connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://footballapp:footballpass123@db:5432/footballhome',
});

// Twilio configuration (only initialize if credentials are provided)
let twilioClient = null;
const TWILIO_ACCOUNT_SID = process.env.TWILIO_ACCOUNT_SID;
const TWILIO_AUTH_TOKEN = process.env.TWILIO_AUTH_TOKEN;
const TWILIO_PHONE_NUMBER = process.env.TWILIO_PHONE_NUMBER || '+1234567890';

if (TWILIO_ACCOUNT_SID && TWILIO_AUTH_TOKEN && 
    TWILIO_ACCOUNT_SID !== 'your-account-sid' && 
    TWILIO_AUTH_TOKEN !== 'your-auth-token') {
  try {
    twilioClient = twilio(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN);
    console.log('✅ Twilio client initialized');
  } catch (error) {
    console.log('⚠️  Twilio initialization failed:', error.message);
  }
} else {
  console.log('ℹ️  Twilio not configured - SMS will be logged instead of sent');
}

// SMS helper function
async function sendSMS(to, message) {
  try {
    // For development, log instead of actually sending if Twilio not configured
    if (!twilioClient) {
      console.log(`📱 SMS to ${to}: ${message}`);
      return { success: true, mock: true, message: 'SMS logged (Twilio not configured)' };
    }

    const result = await twilioClient.messages.create({
      body: message,
      from: TWILIO_PHONE_NUMBER,
      to: to
    });

    console.log(`✅ SMS sent to ${to}: ${result.sid}`);
    return { success: true, sid: result.sid };
  } catch (error) {
    console.error(`❌ SMS failed to ${to}:`, error.message);
    return { success: false, error: error.message };
  }
}

// Middleware
app.use(helmet());
app.use(cors({
  origin: ['http://localhost', 'http://localhost:80', 'https://footballhome.org'],
  credentials: true
}));
app.use(morgan('combined'));
app.use(express.json());

// Session middleware
app.use(session({
  secret: 'your-secret-key-here', 
  resave: false,
  saveUninitialized: false,
  cookie: { secure: false } // Set to true in production with HTTPS
}));

// Authentication middleware
const requireAuth = (req, res, next) => {
  if (!req.session || !req.session.user) {
    return res.status(401).json({
      success: false,
      error: 'Authentication required'
    });
  }
  next();
};

// Serve static files from frontend directory
app.use(express.static(path.join(__dirname, '../../frontend')));

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'footballhome-api',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// Authentication endpoints
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  
  try {
    // Look up user in database
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    
    if (result.rows.length === 0) {
      return res.status(401).json({
        success: false,
        error: 'Invalid email or password'
      });
    }
    
    const user = result.rows[0];
    
    // For demo purposes, we'll check against simple password mapping
    // In production, you would hash and compare passwords properly
    const passwordMap = {
      'coach@thunderfc.com': 'coach123',
      'player@thunderfc.com': 'player123', 
      'keeper@thunderfc.com': 'keeper123',
      'striker@thunderfc.com': 'striker123',
      'defender@thunderfc.com': 'defender123',
      'demo@footballhome.org': 'demo'
    };
    
    if (passwordMap[email] !== password) {
      return res.status(401).json({
        success: false,
        error: 'Invalid email or password'
      });
    }
    
    // Store minimal session data (database is source of truth for profile data)
    if (req.session) {
      req.session.user = {
        id: user.id,
        email: user.email,
        role: user.role
      };
    }
    
    res.json({
      success: true,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        position: user.position,
        jersey_number: user.jersey_number
      },
      token: 'mock_jwt_token_here'
    });
    
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      error: 'Login failed'
    });
  }
});

app.post('/api/auth/logout', (req, res) => {
  if (req.session) {
    req.session.destroy();
  }
  res.json({ success: true, message: 'Logged out successfully' });
});

// Update user profile
app.post('/api/auth/update-profile', async (req, res) => {
    if (!req.session.user) {
        return res.status(401).json({ success: false, message: 'Not authenticated' });
    }

    const { name, phone, position, jersey_number } = req.body;
    
    try {
        // Update user in database
        const result = await pool.query(
            'UPDATE users SET name = $1, phone = $2, position = $3, jersey_number = $4, updated_at = NOW() WHERE id = $5 RETURNING *',
            [name, phone, position, jersey_number, req.session.user.id]
        );
        
        if (result.rows.length === 0) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }
        
        const updatedUser = result.rows[0];
        
        // Only update minimal session data (just id and email for auth)
        req.session.user = {
            id: updatedUser.id,
            email: updatedUser.email,
            role: updatedUser.role
        };
        
        res.json({
            success: true,
            message: 'Profile updated successfully'
        });
    } catch (error) {
        console.error('Error updating profile:', error);
        res.status(500).json({ success: false, message: 'Database error' });
    }
});// Get current user
app.get('/api/auth/me', async (req, res) => {
    if (!req.session.user) {
        return res.status(401).json({ success: false, message: 'Not authenticated' });
    }
    
    try {
        // Always fetch fresh data from database
        const result = await pool.query(
            'SELECT id, email, name, phone, role, position, jersey_number FROM users WHERE id = $1',
            [req.session.user.id]
        );
        
        if (result.rows.length === 0) {
            // User no longer exists in database, clear session
            req.session.destroy();
            return res.status(401).json({ success: false, message: 'User not found' });
        }
        
        const user = result.rows[0];
        res.json({ success: true, user: user });
    } catch (error) {
        console.error('Error fetching user data:', error);
        res.status(500).json({ success: false, message: 'Database error' });
    }
});

// Get all events (for coach dashboard)
app.get('/api/events', requireAuth, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        e.id,
        e.title,
        e.description,
        e.event_type,
        e.event_date,
        e.location,
        e.duration_minutes,
        e.max_players,
        e.created_at,
        u.name as created_by_name
      FROM events e
      JOIN users u ON e.created_by = u.id
      ORDER BY e.event_date DESC
    `);

    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching events:', error);
    res.status(500).json({ error: 'Failed to fetch events' });
  }
});

// Get all events for a team
app.get('/api/teams/:teamId/events', requireAuth, async (req, res) => {
  try {
    const { teamId } = req.params;
    
    const result = await pool.query(`
      SELECT 
        e.id,
        e.title,
        e.description,
        e.event_type,
        e.event_date,
        e.location,
        e.duration_minutes,
        e.max_players,
        e.created_at,
        u.name as created_by_name
      FROM events e
      JOIN users u ON e.created_by = u.id
      WHERE e.team_id = $1
      ORDER BY e.event_date DESC
    `, [teamId]);

    res.json({
      team_id: teamId,
      events: result.rows
    });
  } catch (error) {
    console.error('Error fetching events:', error);
    res.status(500).json({ error: 'Failed to fetch events' });
  }
});

// Create new event
app.post('/api/events', async (req, res) => {
  try {
    const {
      team_id,
      title,
      description,
      event_type,
      event_date,
      location,
      duration_minutes,
      max_players
    } = req.body;

    // For now, use a sample user ID (in real app, get from auth token)
    const created_by = '550e8400-e29b-41d4-a716-446655440010';

    const result = await pool.query(`
      INSERT INTO events (
        team_id, created_by, title, description, event_type,
        event_date, location, duration_minutes, max_players
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING *
    `, [team_id, created_by, title, description, event_type, event_date, location, duration_minutes, max_players]);

    res.status(201).json({
      status: 'created',
      message: 'Event created successfully',
      event: result.rows[0]
    });
  } catch (error) {
    console.error('Error creating event:', error);
    res.status(500).json({ error: 'Failed to create event' });
  }
});

// RSVP to event
app.post('/api/events/:eventId/rsvp', async (req, res) => {
  try {
    const { eventId } = req.params;
    const { user_id, status, notes } = req.body;

    // Use UPSERT to handle existing RSVPs
    const result = await pool.query(`
      INSERT INTO rsvps (event_id, user_id, status, notes)
      VALUES ($1, $2, $3, $4)
      ON CONFLICT (event_id, user_id)
      DO UPDATE SET 
        status = EXCLUDED.status,
        notes = EXCLUDED.notes,
        response_date = CURRENT_TIMESTAMP
      RETURNING *
    `, [eventId, user_id, status, notes]);

    res.json({
      status: 'rsvp_updated',
      message: 'RSVP submitted successfully',
      rsvp: result.rows[0]
    });
  } catch (error) {
    console.error('Error updating RSVP:', error);
    res.status(500).json({ error: 'Failed to update RSVP' });
  }
});

// Get RSVPs for an event
app.get('/api/events/:eventId/rsvps', async (req, res) => {
  try {
    const { eventId } = req.params;

    const result = await pool.query(`
      SELECT 
        r.id,
        r.status,
        r.notes,
        r.response_date,
        u.name as user_name,
        u.email as user_email
      FROM rsvps r
      JOIN users u ON r.user_id = u.id
      WHERE r.event_id = $1
      ORDER BY r.response_date DESC
    `, [eventId]);

    const summary = await pool.query(`
      SELECT 
        status,
        COUNT(*) as count
      FROM rsvps
      WHERE event_id = $1
      GROUP BY status
    `, [eventId]);

    res.json({
      event_id: eventId,
      rsvps: result.rows,
      summary: summary.rows
    });
  } catch (error) {
    console.error('Error fetching RSVPs:', error);
    res.status(500).json({ error: 'Failed to fetch RSVPs' });
  }
});

// Magic Link Routes
const jwt = require('jsonwebtoken');
const crypto = require('crypto');

const JWT_SECRET = process.env.JWT_SECRET || 'your-super-secret-key-change-in-production';

// Generate magic link for RSVP
app.post('/api/events/:eventId/magic-link', async (req, res) => {
  try {
    const { eventId } = req.params;
    const { userId } = req.body;

    // Generate unique token
    const token = crypto.randomBytes(32).toString('hex');
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days from now

    // Store token in database
    await pool.query(`
      INSERT INTO magic_tokens (token, event_id, user_id, expires_at)
      VALUES ($1, $2, $3, $4)
      ON CONFLICT (event_id, user_id) 
      DO UPDATE SET 
        token = EXCLUDED.token,
        expires_at = EXCLUDED.expires_at,
        used_at = NULL,
        created_at = CURRENT_TIMESTAMP
    `, [token, eventId, userId, expiresAt]);

    const magicLink = `${req.protocol}://${req.get('host')}/rsvp/${token}`;
    
    res.json({
      success: true,
      magicLink,
      expiresAt
    });
  } catch (error) {
    console.error('Error generating magic link:', error);
    res.status(500).json({ error: 'Failed to generate magic link' });
  }
});

// Validate and get RSVP info from magic link
app.get('/api/rsvp/:token', async (req, res) => {
  try {
    const { token } = req.params;

    const result = await pool.query(`
      SELECT 
        mt.id,
        mt.event_id,
        mt.user_id,
        mt.expires_at,
        mt.used_at,
        e.title,
        e.event_date,
        e.location,
        e.event_type,
        u.name as player_name,
        r.status as current_rsvp
      FROM magic_tokens mt
      JOIN events e ON mt.event_id = e.id
      JOIN users u ON mt.user_id = u.id
      LEFT JOIN rsvps r ON r.event_id = mt.event_id AND r.user_id = mt.user_id
      WHERE mt.token = $1
    `, [token]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Invalid or expired link' });
    }

    const tokenData = result.rows[0];
    
    // Check if token is expired
    if (new Date() > new Date(tokenData.expires_at)) {
      return res.status(410).json({ error: 'This RSVP link has expired' });
    }

    res.json({
      success: true,
      event: {
        id: tokenData.event_id,
        title: tokenData.title,
        date: tokenData.event_date,
        location: tokenData.location,
        type: tokenData.event_type
      },
      player: {
        id: tokenData.user_id,
        name: tokenData.player_name
      },
      currentRsvp: tokenData.current_rsvp,
      alreadyUsed: !!tokenData.used_at
    });
  } catch (error) {
    console.error('Error validating magic link:', error);
    res.status(500).json({ error: 'Failed to validate link' });
  }
});

// Submit RSVP via magic link
app.post('/api/rsvp/:token', async (req, res) => {
  try {
    const { token } = req.params;
    const { status, notes } = req.body;

    if (!['yes', 'no', 'maybe'].includes(status)) {
      return res.status(400).json({ error: 'Invalid RSVP status' });
    }

    // Get token info
    const tokenResult = await pool.query(`
      SELECT event_id, user_id, expires_at, used_at
      FROM magic_tokens 
      WHERE token = $1
    `, [token]);

    if (tokenResult.rows.length === 0) {
      return res.status(404).json({ error: 'Invalid link' });
    }

    const tokenData = tokenResult.rows[0];
    
    // Check if expired
    if (new Date() > new Date(tokenData.expires_at)) {
      return res.status(410).json({ error: 'Link has expired' });
    }

    // Submit RSVP
    await pool.query(`
      INSERT INTO rsvps (event_id, user_id, status, notes)
      VALUES ($1, $2, $3, $4)
      ON CONFLICT (event_id, user_id)
      DO UPDATE SET 
        status = EXCLUDED.status,
        notes = EXCLUDED.notes,
        response_date = CURRENT_TIMESTAMP
    `, [tokenData.event_id, tokenData.user_id, status, notes || null]);

    // Mark token as used
    await pool.query(`
      UPDATE magic_tokens 
      SET used_at = CURRENT_TIMESTAMP 
      WHERE token = $1
    `, [token]);

    res.json({
      success: true,
      message: 'RSVP submitted successfully',
      status
    });
  } catch (error) {
    console.error('Error submitting RSVP:', error);
    res.status(500).json({ error: 'Failed to submit RSVP' });
  }
});

// SMS Notification Routes

// Send RSVP reminder to specific player
app.post('/api/events/:eventId/notify-player', async (req, res) => {
  try {
    const { eventId } = req.params;
    const { userId } = req.body;

    // Get event and user info
    const eventResult = await pool.query(`
      SELECT e.title, e.event_date, e.location, e.event_type, u.name as player_name, u.phone
      FROM events e, users u
      WHERE e.id = $1 AND u.id = $2
    `, [eventId, userId]);

    if (eventResult.rows.length === 0) {
      return res.status(404).json({ error: 'Event or player not found' });
    }

    const { title, event_date, location, event_type, player_name, phone } = eventResult.rows[0];

    if (!phone) {
      return res.status(400).json({ error: 'Player has no phone number' });
    }

    // Generate magic link
    const token = require('crypto').randomBytes(32).toString('hex');
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days

    await pool.query(`
      INSERT INTO magic_tokens (token, event_id, user_id, expires_at)
      VALUES ($1, $2, $3, $4)
      ON CONFLICT (event_id, user_id) 
      DO UPDATE SET 
        token = EXCLUDED.token,
        expires_at = EXCLUDED.expires_at,
        used_at = NULL,
        created_at = CURRENT_TIMESTAMP
    `, [token, eventId, userId, expiresAt]);

    // Format event date
    const eventDate = new Date(event_date).toLocaleDateString('en-US', {
      weekday: 'short',
      month: 'short',
      day: 'numeric',
      hour: 'numeric',
      minute: '2-digit'
    });

    // Send SMS
    const magicLink = `https://footballhome.org/rsvp/${token}`;
    const message = `⚽ Hi ${player_name}! ${title} on ${eventDate} at ${location}. Click to RSVP: ${magicLink}`;

    const smsResult = await sendSMS(phone, message);
    
    res.json({
      success: true,
      player: player_name,
      phone: phone,
      message: message,
      magicLink: magicLink,
      smsResult: smsResult
    });

  } catch (error) {
    console.error('Error sending notification:', error);
    res.status(500).json({ error: 'Failed to send notification' });
  }
});

// Send RSVP reminders to entire team
app.post('/api/events/:eventId/notify-team', async (req, res) => {
  try {
    const { eventId } = req.params;

    // Get event info and all team members
    const result = await pool.query(`
      SELECT 
        e.title, e.event_date, e.location, e.event_type, e.team_id,
        u.id as user_id, u.name as player_name, u.phone
      FROM events e
      JOIN team_members tm ON e.team_id = tm.team_id
      JOIN users u ON tm.user_id = u.id
      WHERE e.id = $1 AND u.role = 'player' AND u.phone IS NOT NULL
    `, [eventId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Event not found or no players with phone numbers' });
    }

    const event = result.rows[0];
    const players = result.rows;
    
    const eventDate = new Date(event.event_date).toLocaleDateString('en-US', {
      weekday: 'short',
      month: 'short', 
      day: 'numeric',
      hour: 'numeric',
      minute: '2-digit'
    });

    const notifications = [];

    // Send SMS to each player
    for (const player of players) {
      try {
        // Generate unique magic link for this player
        const token = require('crypto').randomBytes(32).toString('hex');
        const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);

        await pool.query(`
          INSERT INTO magic_tokens (token, event_id, user_id, expires_at)
          VALUES ($1, $2, $3, $4)
          ON CONFLICT (event_id, user_id) 
          DO UPDATE SET 
            token = EXCLUDED.token,
            expires_at = EXCLUDED.expires_at,
            used_at = NULL,
            created_at = CURRENT_TIMESTAMP
        `, [token, eventId, player.user_id, expiresAt]);

        const magicLink = `https://footballhome.org/rsvp/${token}`;
        const message = `⚽ Hi ${player.player_name}! ${event.title} on ${eventDate} at ${event.location}. Click to RSVP: ${magicLink}`;

        const smsResult = await sendSMS(player.phone, message);
        
        notifications.push({
          player: player.player_name,
          phone: player.phone,
          success: smsResult.success,
          magicLink: magicLink
        });

      } catch (playerError) {
        console.error(`Error notifying ${player.player_name}:`, playerError);
        notifications.push({
          player: player.player_name,
          phone: player.phone,
          success: false,
          error: playerError.message
        });
      }
    }

    const successCount = notifications.filter(n => n.success).length;
    
    res.json({
      success: true,
      event: {
        title: event.title,
        date: eventDate,
        location: event.location
      },
      totalPlayers: players.length,
      successfulNotifications: successCount,
      notifications: notifications
    });

  } catch (error) {
    console.error('Error sending team notifications:', error);
    res.status(500).json({ error: 'Failed to send team notifications' });
  }
});

// Frontend routes - serve specific HTML files for different pages
app.get('/coach', (req, res) => {
  res.sendFile(path.join(__dirname, '../../frontend/coach.html'));
});

app.get('/player', (req, res) => {
  res.sendFile(path.join(__dirname, '../../frontend/player.html'));
});

app.get('/rsvp', (req, res) => {
  res.sendFile(path.join(__dirname, '../../frontend/rsvp.html'));
});

// Catch-all route - serve index.html for all other routes
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../../frontend/index.html'));
});

// Test database connection on startup
async function testConnection() {
  try {
    const result = await pool.query('SELECT NOW()');
    console.log('✅ Database connected successfully at:', result.rows[0].now);
  } catch (error) {
    console.error('❌ Database connection failed:', error.message);
  }
}

// Start server
app.listen(port, '0.0.0.0', () => {
  console.log(`⚽ Football Home API running on port ${port}`);
  testConnection();
});

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('Shutting down gracefully...');
  await pool.end();
  process.exit(0);
});