/**
 * Match Lineup Repository
 * 
 * Handles CRUD operations for match_lineups table.
 * Records which players started vs came on as substitutes.
 */
class MatchLineupRepository {
  constructor(client) {
    this.client = client;
  }
  
  /**
   * Create a match lineup entry
   */
  async create(data) {
    const { matchId, playerId, teamId, isStarter } = data;
    
    const result = await this.client.query(
      `INSERT INTO match_lineups (match_id, player_id, team_id, is_starter)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (match_id, player_id) 
       DO UPDATE SET
         team_id = EXCLUDED.team_id,
         is_starter = EXCLUDED.is_starter
       RETURNING *`,
      [matchId, playerId, teamId, isStarter]
    );
    
    return result.rows[0];
  }
  
  /**
   * Delete all lineups for a match
   */
  async deleteByMatch(matchId) {
    await this.client.query(
      'DELETE FROM match_lineups WHERE match_id = $1',
      [matchId]
    );
  }
  
  /**
   * Find lineups by match
   */
  async findByMatch(matchId) {
    const result = await this.client.query(
      `SELECT ml.*, p.person_id, per.first_name, per.last_name, t.name as team_name
       FROM match_lineups ml
       JOIN players p ON ml.player_id = p.id
       JOIN persons per ON p.person_id = per.id
       JOIN teams t ON ml.team_id = t.id
       WHERE ml.match_id = $1
       ORDER BY ml.is_starter DESC, per.last_name, per.first_name`,
      [matchId]
    );
    
    return result.rows;
  }
  
  /**
   * Find starters for a match
   */
  async findStarters(matchId) {
    const result = await this.client.query(
      `SELECT ml.*, p.person_id, per.first_name, per.last_name, t.name as team_name
       FROM match_lineups ml
       JOIN players p ON ml.player_id = p.id
       JOIN persons per ON p.person_id = per.id
       JOIN teams t ON ml.team_id = t.id
       WHERE ml.match_id = $1 AND ml.is_starter = true
       ORDER BY t.name, per.last_name, per.first_name`,
      [matchId]
    );
    
    return result.rows;
  }
  
  /**
   * Find substitutes for a match
   */
  async findSubstitutes(matchId) {
    const result = await this.client.query(
      `SELECT ml.*, p.person_id, per.first_name, per.last_name, t.name as team_name
       FROM match_lineups ml
       JOIN players p ON ml.player_id = p.id
       JOIN persons per ON p.person_id = per.id
       JOIN teams t ON ml.team_id = t.id
       WHERE ml.match_id = $1 AND ml.is_starter = false
       ORDER BY t.name, per.last_name, per.first_name`,
      [matchId]
    );
    
    return result.rows;
  }
}

module.exports = MatchLineupRepository;
