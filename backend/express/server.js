const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { Pool } = require('pg');
const twilio = require('twilio');
const sgMail = require('@sendgrid/mail');
const path = require('path');
const { 
  generateToken, 
  hashPassword, 
  comparePassword, 
  blacklistToken,
  requireJWTAuth, 
  optionalJWTAuth,
  requireRole,
  requireAdmin,
  requireCoachOrAdmin 
} = require('./middleware/auth');

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

// JWT Authentication is now handled by middleware/auth.js
// Legacy session-based authentication has been replaced

// Serve static files from frontend directory
app.use(express.static(path.join(__dirname, '../../frontend')));

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'footballhome-api',
    version: '3.0.0',
    timestamp: new Date().toISOString(),
    normalized: true,
    many_to_many_roles: true,
    fourth_normal_form: true,
    practices_matches_separated: true
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
    // Add retry logic for database connection issues
    let result;
    let retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        // Look up user with role information using many-to-many structure
        result = await pool.query(`
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
        break; // Success, exit retry loop
      } catch (dbError) {
        retryCount++;
        console.log(`Database connection attempt ${retryCount}/${maxRetries} failed:`, dbError.message);
        
        if (retryCount >= maxRetries) {
          throw dbError; // Re-throw if max retries reached
        }
        
        // Wait before retry (exponential backoff)
        await new Promise(resolve => setTimeout(resolve, Math.pow(2, retryCount) * 1000));
      }
    }
    
    if (result.rows.length === 0) {
      return res.status(401).json({
        success: false,
        error: 'Invalid email or password'
      });
    }
    
    const user = result.rows[0];
    
    // Check if user has a hashed password in database
    let isValidPassword = false;
    
    if (user.password_hash) {
      // Use bcrypt to compare hashed password
      isValidPassword = await comparePassword(password, user.password_hash);
    } else {
      // Fallback to demo password mapping for existing users without hashed passwords
      const passwordMap = {
        'admin@thunderfc.com': 'admin123',
        'coach@thunderfc.com': 'coach123',
        'player@thunderfc.com': 'player123', 
        'keeper@thunderfc.com': 'keeper123',
        'striker@thunderfc.com': 'striker123',
        'defender@thunderfc.com': 'defender123',
        'demo@footballhome.org': 'demo'
      };
      
      isValidPassword = passwordMap[email] === password;
      
      // If login successful with demo password, hash and store it
      if (isValidPassword) {
        const hashedPassword = await hashPassword(password);
        await pool.query(
          'UPDATE users SET password_hash = $1 WHERE id = $2',
          [hashedPassword, user.id]
        );
        console.log(`✅ Migrated password to hash for user: ${email}`);
      }
    }
    
    if (!isValidPassword) {
      return res.status(401).json({
        success: false,
        error: 'Invalid email or password'
      });
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
    
    // Generate JWT token
    const token = generateToken({
      id: user.id,
      email: user.email,
      roles: user.roles || []
    });
    
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
      token: token
    });
    
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      error: 'Login failed'
    });
  }
});

app.post('/api/auth/logout', requireJWTAuth, async (req, res) => {
  try {
    // Blacklist the current JWT token
    if (req.token) {
      await blacklistToken(req.token);
    }
    
    res.json({ 
      success: true, 
      message: 'Logged out successfully' 
    });
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Logout failed' 
    });
  }
});

// Update user profile - now handles normalized schema with JWT auth
const updateProfileHandler = async (req, res) => {
    const { name, phone, position_id, jersey_number } = req.body;
    
    try {
        // Update user basic info
        await pool.query(
            'UPDATE users SET name = $1, phone = $2, updated_at = NOW() WHERE id = $3',
            [name, phone, req.user.id]
        );
        
        // Update team member info if position or jersey provided
        if (position_id !== undefined || jersey_number !== undefined) {
            await pool.query(`
                UPDATE team_members 
                SET position_id = COALESCE($1, position_id), 
                    jersey_number = COALESCE($2, jersey_number)
                WHERE user_id = $3 AND is_active = true
            `, [position_id || null, jersey_number || null, req.user.id]);
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
app.post('/api/auth/update-profile', requireJWTAuth, updateProfileHandler);
app.put('/api/auth/update-profile', requireJWTAuth, updateProfileHandler);

// Get current user - updated for normalized schema with JWT auth
app.get('/api/auth/me', requireJWTAuth, async (req, res) => {
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
        `, [req.user.id]);
        
        if (result.rows.length === 0) {
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

// Get all events with practices/matches data - normalized structure
app.get('/api/events', requireJWTAuth, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        e.id,
        e.title,
        e.description,
        et.display_name as event_type,
        et.name as event_type_code,
        et.category as event_category,
        e.event_date,
        e.location,
        e.duration_minutes,
        e.max_players,
        e.cancelled,
        e.created_at,
        u.name as created_by_name,
        t.name as team_name,
        s.display_name as sport,
        -- Practice-specific data
        p.focus_areas,
        p.drill_plan,
        p.equipment_needed,
        p.fitness_focus,
        p.skill_level,
        p.weather_dependent,
        p.indoor_alternative_location,
        p.notes as practice_notes,
        -- Match-specific data
        m.opponent_team_id,
        ot.name as opponent_team_name,
        has.display_name as home_away_status,
        m.competition_name,
        m.competition_round,
        m.referee_name,
        m.home_team_score,
        m.away_team_score,
        m.match_status,
        m.weather_conditions,
        m.attendance,
        m.match_report
      FROM events e
      JOIN users u ON e.created_by = u.id
      JOIN event_types et ON e.event_type_id = et.id
      JOIN teams t ON e.team_id = t.id
      JOIN sports s ON t.sport_id = s.id
      LEFT JOIN practices p ON e.id = p.id
      LEFT JOIN matches m ON e.id = m.id
      LEFT JOIN teams ot ON m.opponent_team_id = ot.id
      LEFT JOIN home_away_statuses has ON m.home_away_status_id = has.id
      ORDER BY e.event_date DESC
    `);

    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching events:', error);
    res.status(500).json({ error: 'Failed to fetch events' });
  }
});

// Get all events for a team with practices/matches data - normalized structure
app.get('/api/teams/:teamId/events', requireJWTAuth, async (req, res) => {
  try {
    const { teamId } = req.params;
    
    const result = await pool.query(`
      SELECT 
        e.id,
        e.title,
        e.description,
        et.display_name as event_type,
        et.name as event_type_code,
        et.category as event_category,
        e.event_date,
        v.name as location,
        e.duration_minutes,
        e.max_players,
        e.cancelled,
        e.created_at,
        u.name as created_by_name,
        -- Practice-specific data
        p.focus_areas,
        p.drill_plan,
        p.equipment_needed,
        p.fitness_focus,
        p.skill_level,
        -- Match-specific data
        m.opponent_team_id,
        ot.name as opponent_team_name,
        has.display_name as home_away_status,
        m.competition_name,
        m.match_status,
        m.home_team_score,
        m.away_team_score,
        -- Current user's RSVP status
        rs.name as user_rsvp_status,
        rs.display_name as user_rsvp_display
      FROM events e
      JOIN users u ON e.created_by = u.id
      JOIN event_types et ON e.event_type_id = et.id
      LEFT JOIN venues v ON e.venue_id = v.id
      LEFT JOIN practices p ON e.id = p.id
      LEFT JOIN matches m ON e.id = m.id
      LEFT JOIN teams ot ON m.opponent_team_id = ot.id
      LEFT JOIN home_away_statuses has ON m.home_away_status_id = has.id
      LEFT JOIN rsvps r ON e.id = r.event_id AND r.user_id = $2
      LEFT JOIN rsvp_statuses rs ON r.rsvp_status_id = rs.id
      WHERE e.team_id = $1
      ORDER BY e.event_date DESC
    `, [teamId, req.user.id]);

    // Format events to match frontend expectations
    const formattedEvents = result.rows.map(event => ({
      id: event.id,
      title: event.title,
      description: event.description,
      event_date: event.event_date.toISOString().split('T')[0], // Convert to YYYY-MM-DD
      event_time: event.event_date.toTimeString().substring(0, 5), // Convert to HH:MM
      location: event.location,
      event_type: event.event_type,
      created_at: event.created_at,
      user_rsvp_status: event.user_rsvp_status,
      user_rsvp_display: event.user_rsvp_display
    }));

    res.json({
      success: true,
      team_id: teamId,
      events: formattedEvents
    });
  } catch (error) {
    console.error('Error fetching events:', error);
    res.status(500).json({ error: 'Failed to fetch events' });
  }
});

// Get practices only
app.get('/api/practices', requireJWTAuth, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        e.id, e.title, e.description, e.event_date, e.location, e.duration_minutes,
        e.max_players, e.cancelled, u.name as created_by_name, t.name as team_name,
        p.focus_areas, p.drill_plan, p.equipment_needed, p.fitness_focus, 
        p.skill_level, p.weather_dependent, p.indoor_alternative_location, p.notes
      FROM events e
      JOIN event_types et ON e.event_type_id = et.id
      JOIN practices p ON e.id = p.id
      JOIN users u ON e.created_by = u.id
      JOIN teams t ON e.team_id = t.id
      WHERE et.category = 'practice'
      ORDER BY e.event_date DESC
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching practices:', error);
    res.status(500).json({ error: 'Failed to fetch practices' });
  }
});

// Get matches only
app.get('/api/matches', requireJWTAuth, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        e.id, e.title, e.description, e.event_date, e.location, e.duration_minutes,
        e.max_players, e.cancelled, u.name as created_by_name, t.name as team_name,
        m.opponent_team_id, ot.name as opponent_team_name, has.display_name as home_away_status,
        m.competition_name, m.competition_round, m.referee_name, m.home_team_score, 
        m.away_team_score, m.match_status, m.weather_conditions, m.attendance, m.match_report
      FROM events e
      JOIN event_types et ON e.event_type_id = et.id
      JOIN matches m ON e.id = m.id
      JOIN users u ON e.created_by = u.id
      JOIN teams t ON e.team_id = t.id
      LEFT JOIN teams ot ON m.opponent_team_id = ot.id
      LEFT JOIN home_away_statuses has ON m.home_away_status_id = has.id
      WHERE et.category = 'match'
      ORDER BY e.event_date DESC
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching matches:', error);
    res.status(500).json({ error: 'Failed to fetch matches' });
  }
});

// Create new event - updated for normalized schema
app.post('/api/events', async (req, res) => {
  try {
    console.log('Create event request body:', req.body);
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
    console.log('Extracted location:', location);

    // Get event type ID from name and team's sport
    const eventTypeResult = await pool.query(`
      SELECT et.id 
      FROM event_types et
      JOIN teams t ON et.sport_id = t.sport_id
      WHERE et.name = $1 AND t.id = $2
    `, [event_type_name || 'training', team_id]);

    if (eventTypeResult.rows.length === 0) {
      return res.status(400).json({ success: false, error: 'Invalid event type for this sport' });
    }

    const event_type_id = eventTypeResult.rows[0].id;
    const created_by = req.user?.id || '550e8400-e29b-41d4-a716-446655440100';

    // Handle venue - find existing or create new
    let venue_id = null;
    if (location) {
      console.log('Looking for venue:', location);
      // First try to find existing venue by name
      const existingVenue = await pool.query(`
        SELECT id FROM venues WHERE name = $1 LIMIT 1
      `, [location]);
      
      console.log('Found existing venues:', existingVenue.rows.length);
      if (existingVenue.rows.length > 0) {
        venue_id = existingVenue.rows[0].id;
        console.log('Using existing venue_id:', venue_id);
      } else {
        // Create a new basic venue
        const newVenue = await pool.query(`
          INSERT INTO venues (name, short_name, venue_type, city, capacity, owned_by_team)
          VALUES ($1, $2, 'field', 'Unknown', 30, false)
          RETURNING id
        `, [location, location]);
        venue_id = newVenue.rows[0].id;
      }
    }

    const result = await pool.query(`
      INSERT INTO events (
        team_id, created_by, event_type_id, title, description,
        event_date, venue_id, duration_minutes, max_players
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING *
    `, [team_id, created_by, event_type_id, title, description, event_date, venue_id, duration_minutes, max_players]);

    const eventData = result.rows[0];
    const eventDateTime = new Date(eventData.event_date);
    
    // Get venue name for frontend compatibility
    let venueName = location; // fallback to original location
    if (eventData.venue_id) {
      const venueResult = await pool.query(`
        SELECT name FROM venues WHERE id = $1
      `, [eventData.venue_id]);
      if (venueResult.rows.length > 0) {
        venueName = venueResult.rows[0].name;
      }
    }
    
    // Format the response to match frontend expectations
    const formattedEvent = {
      ...eventData,
      event_type: event_type_name || 'training',
      event_time: eventDateTime.toTimeString().split(' ')[0].substring(0, 5), // HH:MM format
      location: venueName // Add location field for frontend compatibility
    };

    res.status(201).json({
      success: true,
      event: formattedEvent
    });
  } catch (error) {
    console.error('Error creating event:', error);
    res.status(500).json({ success: false, error: 'Failed to create event' });
  }
});

// RSVP to event - updated for normalized schema
app.post('/api/events/:eventId/rsvp', requireJWTAuth, async (req, res) => {
  try {
    const { eventId } = req.params;
    const { status, notes } = req.body;
    const user_id = req.user.id; // Get user ID from authenticated session

    const status_name = status || 'attending'; // Default to attending

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
      success: true,
      status: 'rsvp_updated',
      message: 'RSVP submitted successfully',
      rsvp: result.rows[0]
    });
  } catch (error) {
    console.error('Error updating RSVP:', error);
    res.status(500).json({ error: 'Failed to update RSVP' });
  }
});

// Remove/delete RSVP
app.delete('/api/events/:eventId/rsvp', requireJWTAuth, async (req, res) => {
  try {
    const { eventId } = req.params;
    const user_id = req.user.id;

    // Delete the RSVP
    const result = await pool.query(
      'DELETE FROM rsvps WHERE event_id = $1 AND user_id = $2 RETURNING *',
      [eventId, user_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ 
        success: false, 
        error: 'No RSVP found to remove' 
      });
    }

    res.json({
      success: true,
      status: 'rsvp_removed',
      message: 'RSVP removed successfully'
    });
  } catch (error) {
    console.error('Error removing RSVP:', error);
    res.status(500).json({ error: 'Failed to remove RSVP' });
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

// Get all available roles with their permissions (4NF compliant)
app.get('/api/roles', requireJWTAuth, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        r.id, 
        r.name, 
        r.display_name, 
        r.description,
        r.is_system_role,
        array_agg(
          json_build_object(
            'id', p.id,
            'name', p.name,
            'display_name', p.display_name,
            'category', p.category
          )
        ) FILTER (WHERE p.id IS NOT NULL) as permissions
      FROM roles r
      LEFT JOIN role_permissions rp ON r.id = rp.role_id
      LEFT JOIN permissions p ON rp.permission_id = p.id
      GROUP BY r.id, r.name, r.display_name, r.description, r.is_system_role
      ORDER BY r.display_name
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching roles:', error);
    res.status(500).json({ error: 'Failed to fetch roles' });
  }
});

// Get user's permissions from normalized structure
app.get('/api/user/:userId/permissions', requireJWTAuth, async (req, res) => {
  const { userId } = req.params;
  
  try {
    const result = await pool.query(`
      SELECT DISTINCT
        p.id,
        p.name,
        p.display_name,
        p.description,
        p.category,
        r.name as role_name,
        r.display_name as role_display_name
      FROM users u
      JOIN user_roles ur ON u.id = ur.user_id AND ur.is_active = true
      JOIN roles r ON ur.role_id = r.id
      JOIN role_permissions rp ON r.id = rp.role_id
      JOIN permissions p ON rp.permission_id = p.id
      WHERE u.id = $1 AND u.is_active = true
      ORDER BY p.category, p.name
    `, [userId]);
    
    // Group permissions by category
    const permissionsByCategory = result.rows.reduce((acc, row) => {
      if (!acc[row.category]) {
        acc[row.category] = [];
      }
      acc[row.category].push({
        id: row.id,
        name: row.name,
        display_name: row.display_name,
        description: row.description,
        granted_via_role: row.role_display_name
      });
      return acc;
    }, {});
    
    res.json({
      user_id: userId,
      permissions_by_category: permissionsByCategory,
      total_permissions: result.rows.length
    });
  } catch (error) {
    console.error('Error fetching user permissions:', error);
    res.status(500).json({ error: 'Failed to fetch user permissions' });
  }
});

// Get user's roles
app.get('/api/user/:userId/roles', requireJWTAuth, async (req, res) => {
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
app.post('/api/users/:userId/roles', requireJWTAuth, async (req, res) => {
  try {
    const { userId } = req.params;
    const { roleId, notes, expiresAt } = req.body;
    const assignedBy = req.user.id;

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
app.delete('/api/users/:userId/roles/:roleId', requireJWTAuth, async (req, res) => {
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