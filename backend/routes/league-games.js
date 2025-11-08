const express = require('express');
const router = express.Router();
const { authenticateToken, requireRole } = require('../middleware/auth');

// Database pool will be set by server.js
let pool;

// GET /api/league-games - Get all league games with optional filters
router.get('/', async (req, res) => {
  try {
    const { 
      team_id, 
      season, 
      competition, 
      status, 
      data_source,
      limit = 50,
      offset = 0 
    } = req.query;

    let query = `
      SELECT 
        lg.*,
        ht.name as home_team_name,
        at.name as away_team_name,
        v.name as venue_name,
        ld.name as division_name
      FROM league_games lg
      LEFT JOIN teams ht ON lg.home_team_id = ht.id
      LEFT JOIN teams at ON lg.away_team_id = at.id
      LEFT JOIN venues v ON lg.venue_id = v.id
      LEFT JOIN league_divisions ld ON lg.league_division_id = ld.id
      WHERE 1=1
    `;
    
    const params = [];
    let paramCount = 0;

    if (team_id) {
      paramCount++;
      query += ` AND (lg.home_team_id = $${paramCount} OR lg.away_team_id = $${paramCount})`;
      params.push(team_id);
    }

    if (season) {
      paramCount++;
      query += ` AND lg.season = $${paramCount}`;
      params.push(season);
    }

    if (competition) {
      paramCount++;
      query += ` AND lg.competition_name ILIKE $${paramCount}`;
      params.push(`%${competition}%`);
    }

    if (status) {
      paramCount++;
      query += ` AND lg.game_status = $${paramCount}`;
      params.push(status);
    }

    if (data_source) {
      paramCount++;
      query += ` AND lg.data_source = $${paramCount}`;
      params.push(data_source);
    }

    query += ` ORDER BY lg.scheduled_date DESC`;
    
    paramCount++;
    query += ` LIMIT $${paramCount}`;
    params.push(parseInt(limit));
    
    paramCount++;
    query += ` OFFSET $${paramCount}`;
    params.push(parseInt(offset));

    const result = await pool.query(query, params);
    
    res.json({
      success: true,
      games: result.rows,
      count: result.rows.length
    });

  } catch (error) {
    console.error('Error fetching league games:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to fetch league games' 
    });
  }
});

// GET /api/league-games/:id - Get specific league game with events and stats
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    // Get main game data
    const gameQuery = `
      SELECT 
        lg.*,
        ht.name as home_team_name,
        at.name as away_team_name,
        v.name as venue_name,
        ld.name as division_name
      FROM league_games lg
      LEFT JOIN teams ht ON lg.home_team_id = ht.id
      LEFT JOIN teams at ON lg.away_team_id = at.id
      LEFT JOIN venues v ON lg.venue_id = v.id
      LEFT JOIN league_divisions ld ON lg.league_division_id = ld.id
      WHERE lg.id = $1
    `;

    const gameResult = await pool.query(gameQuery, [id]);
    
    if (gameResult.rows.length === 0) {
      return res.status(404).json({ 
        success: false, 
        message: 'League game not found' 
      });
    }

    const game = gameResult.rows[0];

    // Get match events
    const eventsQuery = `
      SELECT 
        lme.*,
        t.name as team_name
      FROM league_match_events lme
      LEFT JOIN teams t ON lme.team_id = t.id
      WHERE lme.league_game_id = $1
      ORDER BY lme.minute ASC, lme.stoppage_minute ASC
    `;

    const eventsResult = await pool.query(eventsQuery, [id]);

    // Get player statistics
    const statsQuery = `
      SELECT 
        lmps.*,
        t.name as team_name
      FROM league_match_player_stats lmps
      LEFT JOIN teams t ON lmps.team_id = t.id
      WHERE lmps.league_game_id = $1
      ORDER BY lmps.team_id, lmps.is_starter DESC, lmps.player_name
    `;

    const statsResult = await pool.query(statsQuery, [id]);

    res.json({
      success: true,
      game: game,
      events: eventsResult.rows,
      playerStats: statsResult.rows
    });

  } catch (error) {
    console.error('Error fetching league game details:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to fetch league game details' 
    });
  }
});

// POST /api/league-games - Create new league game (for scraping)
router.post('/', authenticateToken, requireRole('admin'), async (req, res) => {
  try {
    const {
      season, home_team_id, away_team_id, scheduled_date,
      venue_id, competition_name, competition_round,
      league_game_id, external_url, data_source = 'manual',
      league_division_id, referee_name
    } = req.body;

    // Validate required fields
    if (!season || !home_team_id || !away_team_id || !scheduled_date) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: season, home_team_id, away_team_id, scheduled_date'
      });
    }

    // Check for duplicates if not from manual entry
    if (data_source !== 'manual') {
      const isDuplicate = await pool.query(
        'SELECT check_duplicate_league_game($1, $2, $3, $4)',
        [home_team_id, away_team_id, scheduled_date, venue_id]
      );

      if (isDuplicate.rows[0].check_duplicate_league_game) {
        return res.status(409).json({
          success: false,
          message: 'Duplicate game detected - game already exists for these teams on this date'
        });
      }
    }

    const insertQuery = `
      INSERT INTO league_games (
        season, home_team_id, away_team_id, scheduled_date,
        venue_id, competition_name, competition_round,
        league_game_id, external_url, data_source,
        league_division_id, referee_name
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
      RETURNING *
    `;

    const result = await pool.query(insertQuery, [
      season, home_team_id, away_team_id, scheduled_date,
      venue_id, competition_name, competition_round,
      league_game_id, external_url, data_source,
      league_division_id, referee_name
    ]);

    res.status(201).json({
      success: true,
      message: 'League game created successfully',
      game: result.rows[0]
    });

  } catch (error) {
    console.error('Error creating league game:', error);
    
    if (error.code === '23505') { // Unique constraint violation
      return res.status(409).json({
        success: false,
        message: 'Game already exists or duplicate external ID'
      });
    }

    res.status(500).json({ 
      success: false, 
      message: 'Failed to create league game' 
    });
  }
});

// PUT /api/league-games/:id/result - Update match result (for live scraping)
router.put('/:id/result', authenticateToken, requireRole('admin'), async (req, res) => {
  try {
    const { id } = req.params;
    const {
      home_score, away_score, home_ht_score, away_ht_score,
      attendance, game_status, raw_match_data
    } = req.body;

    const success = await pool.query(
      'SELECT update_league_game_stats($1, $2, $3, $4, $5, $6, $7)',
      [id, home_score, away_score, home_ht_score, away_ht_score, attendance, raw_match_data]
    );

    if (success.rows[0].update_league_game_stats) {
      res.json({
        success: true,
        message: 'Match result updated successfully'
      });
    } else {
      res.status(404).json({
        success: false,
        message: 'League game not found'
      });
    }

  } catch (error) {
    console.error('Error updating match result:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to update match result' 
    });
  }
});

// POST /api/league-games/:id/events - Add match event
router.post('/:id/events', authenticateToken, requireRole('admin'), async (req, res) => {
  try {
    const { id } = req.params;
    const {
      event_type, team_id, player_name, minute, 
      description, additional_data
    } = req.body;

    if (!event_type || !team_id) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: event_type, team_id'
      });
    }

    const eventId = await pool.query(
      'SELECT add_league_match_event($1, $2, $3, $4, $5, $6, $7)',
      [id, event_type, team_id, player_name, minute, description, additional_data]
    );

    res.status(201).json({
      success: true,
      message: 'Match event added successfully',
      event_id: eventId.rows[0].add_league_match_event
    });

  } catch (error) {
    console.error('Error adding match event:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to add match event' 
    });
  }
});

// Function to set database pool
const setDbPool = (dbPool) => {
  pool = dbPool;
};

module.exports = { router, setDbPool };