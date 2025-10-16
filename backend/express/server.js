const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { Pool } = require('pg');

const app = express();
const port = process.env.PORT || 3000;

// Database connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://footballapp:footballpass123@db:5432/footballhome',
});

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'footballhome-api',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// Get all events for a team
app.get('/api/teams/:teamId/events', async (req, res) => {
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