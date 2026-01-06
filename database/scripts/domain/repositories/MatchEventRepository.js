/**
 * Match Event Repository
 * 
 * Handles CRUD operations for match_events table.
 * Records goals, assists, cards, substitutions, and other match events.
 */
class MatchEventRepository {
  constructor(client) {
    this.client = client;
  }
  
  /**
   * Create a match event entry
   */
  async create(data) {
    const { matchId, playerId, teamId, eventTypeId, minute, assistedByPlayerId } = data;
    
    const result = await this.client.query(
      `INSERT INTO match_events (match_id, player_id, team_id, event_type_id, minute, assisted_by_player_id)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [matchId, playerId, teamId, eventTypeId, minute, assistedByPlayerId || null]
    );
    
    return result.rows[0];
  }
  
  /**
   * Delete all events for a match
   */
  async deleteByMatch(matchId) {
    await this.client.query(
      'DELETE FROM match_events WHERE match_id = $1',
      [matchId]
    );
  }
  
  /**
   * Find events by match
   */
  async findByMatch(matchId) {
    const result = await this.client.query(
      `SELECT me.*, 
              p.person_id, per.first_name, per.last_name, 
              t.name as team_name,
              met.name as event_type_name,
              ap.person_id as assist_person_id, aper.first_name as assist_first_name, aper.last_name as assist_last_name
       FROM match_events me
       JOIN players p ON me.player_id = p.id
       JOIN persons per ON p.person_id = per.id
       JOIN teams t ON me.team_id = t.id
       JOIN match_event_types met ON me.event_type_id = met.id
       LEFT JOIN players ap ON me.assisted_by_player_id = ap.id
       LEFT JOIN persons aper ON ap.person_id = aper.id
       WHERE me.match_id = $1
       ORDER BY me.minute, me.id`,
      [matchId]
    );
    
    return result.rows;
  }
  
  /**
   * Find events by match and event type
   */
  async findByMatchAndType(matchId, eventTypeId) {
    const result = await this.client.query(
      `SELECT me.*, 
              p.person_id, per.first_name, per.last_name, 
              t.name as team_name,
              met.name as event_type_name
       FROM match_events me
       JOIN players p ON me.player_id = p.id
       JOIN persons per ON p.person_id = per.id
       JOIN teams t ON me.team_id = t.id
       JOIN match_event_types met ON me.event_type_id = met.id
       WHERE me.match_id = $1 AND me.event_type_id = $2
       ORDER BY me.minute, me.id`,
      [matchId, eventTypeId]
    );
    
    return result.rows;
  }
  
  /**
   * Get event type ID by name
   */
  async getEventTypeId(eventTypeName) {
    const result = await this.client.query(
      'SELECT id FROM match_event_types WHERE name = $1',
      [eventTypeName]
    );
    
    return result.rows.length > 0 ? result.rows[0].id : null;
  }
  
  /**
   * Get all event types
   */
  async getAllEventTypes() {
    const result = await this.client.query(
      'SELECT id, name FROM match_event_types ORDER BY id'
    );
    
    return result.rows;
  }
}

module.exports = MatchEventRepository;
