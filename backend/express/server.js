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
    version: '2.1.0',
    timestamp: new Date().toISOString(),
    normalized: true,
    many_to_many_roles: true
  });
});

// Twilio status endpoint
app.get('/api/twilio/status', (req, res) => {
  const isConfigured = !!(TWILIO_ACCOUNT_SID && TWILIO_AUTH_TOKEN && 
                          TWILIO_ACCOUNT_SID !== 'your-account-sid' && 
                          TWILIO_AUTH_TOKEN !== 'your-auth-token');
  
  res.json({
    configured: isConfigured,
    phone_number: isConfigured ? TWILIO_PHONE_NUMBER : null,
    status: isConfigured ? 'active' : 'mock_mode'
  });
});

// Authentication endpoints
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  
  try {
    // Look up user with role information using many-to-many structure
    const result = await pool.query(`
      SELECT 
        u.*,
        array_agg(r.name) FILTER (WHERE r.name IS NOT NULL AND ur.is_active = true) as roles,
        array_agg(r.display_name) FILTER (WHERE r.display_name IS NOT NULL AND ur.is_active = true) as role_displays
      FROM users u 
      LEFT JOIN user_roles ur ON u.id = ur.user_id AND ur.is_active = true
      LEFT JOIN roles r ON ur.role_id = r.id
      WHERE u.email = $1 AND u.is_active = true
      GROUP BY u.id
    `, [email]);
    
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
      'admin@thunderfc.com': 'admin123',
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
        roles: user.roles || []
      };
    }

    // Get team member info including position
    const memberResult = await pool.query(`
      SELECT tm.jersey_number, tm.is_captain, p.display_name as position_name
      FROM team_members tm
      LEFT JOIN positions p ON tm.position_id = p.id
      WHERE tm.user_id = $1 AND tm.is_active = true
      LIMIT 1
    `, [user.id]);

    const memberInfo = memberResult.rows[0] || {};
    
    res.json({
      success: true,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        roles: user.roles || [],
        role_displays: user.role_displays || [],
        primary_role: (user.roles && user.roles[0]) || null,
        position: memberInfo.position_name || null,
        jersey_number: memberInfo.jersey_number || null,
        is_captain: memberInfo.is_captain || false
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

// Update user profile - now handles normalized schema
const updateProfileHandler = async (req, res) => {
    if (!req.session.user) {
        return res.status(401).json({ success: false, message: 'Not authenticated' });
    }

    const { name, phone, position_id, jersey_number } = req.body;
    
    try {
        // Update user basic info
        await pool.query(
            'UPDATE users SET name = $1, phone = $2, updated_at = NOW() WHERE id = $3',
            [name, phone, req.session.user.id]
        );
        
        // Update team member info if position or jersey provided
        if (position_id !== undefined || jersey_number !== undefined) {
            await pool.query(`
                UPDATE team_members 
                SET position_id = COALESCE($1, position_id), 
                    jersey_number = COALESCE($2, jersey_number)
                WHERE user_id = $3 AND is_active = true
            `, [position_id || null, jersey_number || null, req.session.user.id]);
        }
        
        res.json({
            success: true,
            message: 'Profile updated successfully'
        });
    } catch (error) {
        console.error('Error updating profile:', error);
        res.status(500).json({ success: false, message: 'Database error' });
    }
};

// Support both POST and PUT methods for profile updates
app.post('/api/auth/update-profile', updateProfileHandler);
app.put('/api/auth/update-profile', updateProfileHandler);

// Get current user - updated for normalized schema
app.get('/api/auth/me', async (req, res) => {
    if (!req.session.user) {
        return res.status(401).json({ success: false, message: 'Not authenticated' });
    }
    
    try {
        // Fetch user data with roles and team member info
        const result = await pool.query(`
            SELECT 
                u.id, u.email, u.name, u.phone, u.date_of_birth,
                u.emergency_contact, u.emergency_phone, u.is_active,
                array_agg(DISTINCT r.name) FILTER (WHERE r.name IS NOT NULL AND ur.is_active = true) as roles,
                array_agg(DISTINCT r.display_name) FILTER (WHERE r.display_name IS NOT NULL AND ur.is_active = true) as role_displays,
                tm.jersey_number, tm.is_captain, tm.is_active as team_active,
                p.display_name as position, p.abbreviation as position_abbr,
                t.name as team_name, s.display_name as sport
            FROM users u 
            LEFT JOIN user_roles ur ON u.id = ur.user_id AND ur.is_active = true
            LEFT JOIN roles r ON ur.role_id = r.id
            LEFT JOIN team_members tm ON u.id = tm.user_id AND tm.is_active = true
            LEFT JOIN positions p ON tm.position_id = p.id
            LEFT JOIN teams t ON tm.team_id = t.id
            LEFT JOIN sports s ON t.sport_id = s.id
            WHERE u.id = $1 AND u.is_active = true
            GROUP BY u.id, tm.jersey_number, tm.is_captain, tm.is_active, p.display_name, p.abbreviation, t.name, s.display_name
        `, [req.session.user.id]);
        
        if (result.rows.length === 0) {
            // User no longer exists in database, clear session
            req.session.destroy();
            return res.status(401).json({ success: false, message: 'User not found' });
        }
        
        const user = result.rows[0];
        res.json({ 
            success: true, 
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                phone: user.phone,
                roles: user.roles || [],
                role_displays: user.role_displays || [],
                primary_role: (user.roles && user.roles[0]) || null,
                position: user.position,
                jersey_number: user.jersey_number,
                is_captain: user.is_captain,
                team_name: user.team_name,
                sport: user.sport,
                is_active: user.is_active
            }
        });
    } catch (error) {
        console.error('Error fetching user data:', error);
        res.status(500).json({ success: false, message: 'Database error' });
    }
});

// Get all events - updated for normalized schema
app.get('/api/events', requireAuth, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        e.id,
        e.title,
        e.description,
        et.display_name as event_type,
        et.name as event_type_code,
        e.event_date,
        e.location,
        e.duration_minutes,
        e.max_players,
        e.cancelled,
        e.created_at,
        u.name as created_by_name,
        t.name as team_name,
        s.display_name as sport
      FROM events e
      JOIN users u ON e.created_by = u.id
      JOIN event_types et ON e.event_type_id = et.id
      JOIN teams t ON e.team_id = t.id
      JOIN sports s ON t.sport_id = s.id
      ORDER BY e.event_date DESC
    `);

    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching events:', error);
    res.status(500).json({ error: 'Failed to fetch events' });
  }
});

// Get all events for a team - updated for normalized schema
app.get('/api/teams/:teamId/events', requireAuth, async (req, res) => {
  try {
    const { teamId } = req.params;
    
    const result = await pool.query(`
      SELECT 
        e.id,
        e.title,
        e.description,
        et.display_name as event_type,
        et.name as event_type_code,
        e.event_date,
        e.location,
        e.duration_minutes,
        e.max_players,
        e.cancelled,
        e.created_at,
        u.name as created_by_name
      FROM events e
      JOIN users u ON e.created_by = u.id
      JOIN event_types et ON e.event_type_id = et.id
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

// Create new event - updated for normalized schema
app.post('/api/events', async (req, res) => {
  try {
    const {
      team_id,
      title,
      description,
      event_type_name,
      event_date,
      location,
      duration_minutes,
      max_players
    } = req.body;

    // Get event type ID from name and team's sport
    const eventTypeResult = await pool.query(`
      SELECT et.id 
      FROM event_types et
      JOIN teams t ON et.sport_id = t.sport_id
      WHERE et.name = $1 AND t.id = $2
    `, [event_type_name || 'training', team_id]);

    if (eventTypeResult.rows.length === 0) {
      return res.status(400).json({ error: 'Invalid event type for this sport' });
    }

    const event_type_id = eventTypeResult.rows[0].id;
    const created_by = req.session?.user?.id || '550e8400-e29b-41d4-a716-446655440100';

    const result = await pool.query(`
      INSERT INTO events (
        team_id, created_by, event_type_id, title, description,
        event_date, location, duration_minutes, max_players
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING *
    `, [team_id, created_by, event_type_id, title, description, event_date, location, duration_minutes, max_players]);

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

// RSVP to event - updated for normalized schema
app.post('/api/events/:eventId/rsvp', async (req, res) => {
  try {
    const { eventId } = req.params;
    const { user_id, status_name, notes } = req.body;

    // Get RSVP status ID from name
    const statusResult = await pool.query(
      'SELECT id FROM rsvp_statuses WHERE name = $1',
      [status_name || 'maybe']
    );

    if (statusResult.rows.length === 0) {
      return res.status(400).json({ error: 'Invalid RSVP status' });
    }

    const rsvp_status_id = statusResult.rows[0].id;

    // Use UPSERT to handle existing RSVPs
    const result = await pool.query(`
      INSERT INTO rsvps (event_id, user_id, rsvp_status_id, notes)
      VALUES ($1, $2, $3, $4)
      ON CONFLICT (event_id, user_id)
      DO UPDATE SET 
        rsvp_status_id = EXCLUDED.rsvp_status_id,
        notes = EXCLUDED.notes,
        response_date = CURRENT_TIMESTAMP
      RETURNING *
    `, [eventId, user_id, rsvp_status_id, notes]);

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

// Get RSVPs for an event - updated for normalized schema
app.get('/api/events/:eventId/rsvps', async (req, res) => {
  try {
    const { eventId } = req.params;

    const result = await pool.query(`
      SELECT 
        r.id,
        rs.name as status,
        rs.display_name as status_display,
        rs.color as status_color,
        r.notes,
        r.response_date,
        u.name as user_name,
        u.email as user_email
      FROM rsvps r
      JOIN users u ON r.user_id = u.id
      JOIN rsvp_statuses rs ON r.rsvp_status_id = rs.id
      WHERE r.event_id = $1
      ORDER BY r.response_date DESC
    `, [eventId]);

    const summary = await pool.query(`
      SELECT 
        rs.name as status,
        rs.display_name,
        rs.color,
        COUNT(*) as count
      FROM rsvps r
      JOIN rsvp_statuses rs ON r.rsvp_status_id = rs.id
      WHERE r.event_id = $1
      GROUP BY rs.name, rs.display_name, rs.color, rs.sort_order
      ORDER BY rs.sort_order
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

// Validate and get RSVP info from magic link - updated for normalized schema
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
        et.display_name as event_type,
        u.name as player_name,
        rs.name as current_rsvp,
        rs.display_name as current_rsvp_display
      FROM magic_tokens mt
      JOIN events e ON mt.event_id = e.id
      JOIN event_types et ON e.event_type_id = et.id
      JOIN users u ON mt.user_id = u.id
      LEFT JOIN rsvps r ON r.event_id = mt.event_id AND r.user_id = mt.user_id
      LEFT JOIN rsvp_statuses rs ON r.rsvp_status_id = rs.id
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
      currentRsvpDisplay: tokenData.current_rsvp_display,
      alreadyUsed: !!tokenData.used_at
    });
  } catch (error) {
    console.error('Error validating magic link:', error);
    res.status(500).json({ error: 'Failed to validate link' });
  }
});

// Submit RSVP via magic link - updated for normalized schema
app.post('/api/rsvp/:token', async (req, res) => {
  try {
    const { token } = req.params;
    const { status, notes } = req.body;

    // Get RSVP status ID
    const statusResult = await pool.query(
      'SELECT id FROM rsvp_statuses WHERE name = $1',
      [status]
    );

    if (statusResult.rows.length === 0) {
      return res.status(400).json({ error: 'Invalid RSVP status' });
    }

    const rsvp_status_id = statusResult.rows[0].id;

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
      INSERT INTO rsvps (event_id, user_id, rsvp_status_id, notes)
      VALUES ($1, $2, $3, $4)
      ON CONFLICT (event_id, user_id)
      DO UPDATE SET 
        rsvp_status_id = EXCLUDED.rsvp_status_id,
        notes = EXCLUDED.notes,
        response_date = CURRENT_TIMESTAMP
    `, [tokenData.event_id, tokenData.user_id, rsvp_status_id, notes || null]);

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

// Send RSVP reminder to specific player - updated for normalized schema
app.post('/api/events/:eventId/notify-player', async (req, res) => {
  try {
    const { eventId } = req.params;
    const { userId } = req.body;

    // Get event and user info with normalized schema
    const eventResult = await pool.query(`
      SELECT 
        e.title, e.event_date, e.location, 
        et.display_name as event_type, 
        u.name as player_name, u.phone
      FROM events e
      JOIN event_types et ON e.event_type_id = et.id
      CROSS JOIN users u
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

// Send RSVP reminders to entire team - updated for normalized schema
app.post('/api/events/:eventId/notify-team', async (req, res) => {
  try {
    const { eventId } = req.params;

    // Get event info and all team members with normalized schema
    const result = await pool.query(`
      SELECT 
        e.title, e.event_date, e.location, 
        et.display_name as event_type, 
        e.team_id,
        u.id as user_id, u.name as player_name, u.phone
      FROM events e
      JOIN event_types et ON e.event_type_id = et.id
      JOIN team_members tm ON e.team_id = tm.team_id
      JOIN users u ON tm.user_id = u.id
      JOIN user_roles ur ON u.id = ur.user_id AND ur.is_active = true
      JOIN roles r ON ur.role_id = r.id
      WHERE e.id = $1 AND r.name = 'player' AND u.phone IS NOT NULL AND tm.is_active = true AND u.is_active = true
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

// Get available sports
app.get('/api/sports', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT id, name, display_name, default_event_duration, typical_team_size
      FROM sports 
      ORDER BY display_name
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching sports:', error);
    res.status(500).json({ error: 'Failed to fetch sports' });
  }
});

// Get positions for a sport
app.get('/api/sports/:sportId/positions', async (req, res) => {
  try {
    const { sportId } = req.params;
    const result = await pool.query(`
      SELECT id, name, display_name, abbreviation
      FROM positions 
      WHERE sport_id = $1
      ORDER BY sort_order, display_name
    `, [sportId]);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching positions:', error);
    res.status(500).json({ error: 'Failed to fetch positions' });
  }
});

// Get event types for a sport
app.get('/api/sports/:sportId/event-types', async (req, res) => {
  try {
    const { sportId } = req.params;
    const result = await pool.query(`
      SELECT id, name, display_name, default_duration, requires_opponent
      FROM event_types 
      WHERE sport_id = $1
      ORDER BY display_name
    `, [sportId]);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching event types:', error);
    res.status(500).json({ error: 'Failed to fetch event types' });
  }
});

// Get RSVP statuses
app.get('/api/rsvp-statuses', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT id, name, display_name, color
      FROM rsvp_statuses 
      ORDER BY sort_order
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching RSVP statuses:', error);
    res.status(500).json({ error: 'Failed to fetch RSVP statuses' });
  }
});

// Get all available roles
app.get('/api/roles', requireAuth, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT id, name, display_name, description, permissions
      FROM roles 
      ORDER BY display_name
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching roles:', error);
    res.status(500).json({ error: 'Failed to fetch roles' });
  }
});

// Get user's roles
app.get('/api/users/:userId/roles', requireAuth, async (req, res) => {
  try {
    const { userId } = req.params;
    const result = await pool.query(`
      SELECT 
        ur.id as assignment_id,
        r.id as role_id,
        r.name,
        r.display_name,
        ur.assigned_at,
        ur.is_active,
        ur.expires_at,
        ur.notes,
        assigner.name as assigned_by_name
      FROM user_roles ur
      JOIN roles r ON ur.role_id = r.id
      LEFT JOIN users assigner ON ur.assigned_by = assigner.id
      WHERE ur.user_id = $1
      ORDER BY ur.assigned_at DESC
    `, [userId]);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching user roles:', error);
    res.status(500).json({ error: 'Failed to fetch user roles' });
  }
});

// Assign role to user
app.post('/api/users/:userId/roles', requireAuth, async (req, res) => {
  try {
    const { userId } = req.params;
    const { roleId, notes, expiresAt } = req.body;
    const assignedBy = req.session.user.id;

    // Check if user already has this role
    const existing = await pool.query(
      'SELECT id FROM user_roles WHERE user_id = $1 AND role_id = $2',
      [userId, roleId]
    );

    if (existing.rows.length > 0) {
      // Update existing assignment
      await pool.query(`
        UPDATE user_roles 
        SET is_active = true, assigned_by = $1, notes = $2, expires_at = $3, assigned_at = CURRENT_TIMESTAMP
        WHERE user_id = $4 AND role_id = $5
      `, [assignedBy, notes, expiresAt, userId, roleId]);
    } else {
      // Create new assignment
      await pool.query(`
        INSERT INTO user_roles (user_id, role_id, assigned_by, notes, expires_at)
        VALUES ($1, $2, $3, $4, $5)
      `, [userId, roleId, assignedBy, notes, expiresAt]);
    }

    res.json({ success: true, message: 'Role assigned successfully' });
  } catch (error) {
    console.error('Error assigning role:', error);
    res.status(500).json({ error: 'Failed to assign role' });
  }
});

// Remove/deactivate role from user
app.delete('/api/users/:userId/roles/:roleId', requireAuth, async (req, res) => {
  try {
    const { userId, roleId } = req.params;
    
    await pool.query(`
      UPDATE user_roles 
      SET is_active = false 
      WHERE user_id = $1 AND role_id = $2
    `, [userId, roleId]);

    res.json({ success: true, message: 'Role removed successfully' });
  } catch (error) {
    console.error('Error removing role:', error);
    res.status(500).json({ error: 'Failed to remove role' });
  }
});

// Helper function to check if user has specific role
async function userHasRole(userId, roleName) {
  const result = await pool.query(`
    SELECT 1 FROM user_roles ur
    JOIN roles r ON ur.role_id = r.id
    WHERE ur.user_id = $1 AND r.name = $2 AND ur.is_active = true
    AND (ur.expires_at IS NULL OR ur.expires_at > CURRENT_TIMESTAMP)
  `, [userId, roleName]);
  
  return result.rows.length > 0;
}

// Frontend routes - serve specific HTML files for different pages
app.get('/coach', (req, res) => {
  res.sendFile(path.join(__dirname, '../../frontend/coach.html'));
});

app.get('/coach-profile', (req, res) => {
  res.sendFile(path.join(__dirname, '../../frontend/coach-profile.html'));
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
  console.log(`⚽ Football Home API running on port ${port} (Many-to-Many Roles v2.1)`);
  testConnection();
});

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('Shutting down gracefully...');
  await pool.end();
  process.exit(0);
});