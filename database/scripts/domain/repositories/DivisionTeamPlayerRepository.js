/**
 * Division Team Player Repository
 * All database operations for roster assignments (division_team_players)
 * 
 * HISTORY TRACKING (FULLY NORMALIZED):
 * - Multiple rows per player allowed (composite PK with joined_at)
 * - Each row represents one period of team membership
 * - Current roster: WHERE left_at IS NULL
 * - Transfers: close old period (set left_at), create new period (new row)
 * - No is_active column - derived from left_at IS NULL
 */
class DivisionTeamPlayerRepository {
  constructor(db) {
    this.db = db;
  }
  
  /**
   * Find CURRENT roster entry for player on specific team
   */
  async findActive(divisionTeamId, playerId) {
    const result = await this.db.query(`
      SELECT division_team_id, player_id, jersey_number, joined_at, left_at
      FROM division_team_players
      WHERE division_team_id = $1 AND player_id = $2 AND left_at IS NULL
      ORDER BY joined_at DESC
      LIMIT 1
    `, [divisionTeamId, playerId]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Find ALL roster entries for player (history)
   */
  async findPlayerHistory(playerId) {
    const result = await this.db.query(`
      SELECT division_team_id, player_id, jersey_number, joined_at, left_at
      FROM division_team_players
      WHERE player_id = $1
      ORDER BY joined_at DESC
    `, [playerId]);
    
    return result.rows;
  }
  
  /**
   * Close active roster period (player leaving team)
   */
  async closeActivePeriod(divisionTeamId, playerId) {
    const result = await this.db.query(`
      UPDATE division_team_players 
      SET left_at = CURRENT_TIMESTAMP
      WHERE division_team_id = $1 AND player_id = $2 AND left_at IS NULL
      RETURNING division_team_id, player_id, joined_at
    `, [divisionTeamId, playerId]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Upsert roster entry with transfer history support
   * If player already active on this team: update jersey number
   * If player on different team: close old period, create new
   * If player not on any team: create new period
   */
  async upsert(divisionTeamId, playerId, data = {}) {
    // Check if player is already active on THIS team
    const activeOnThisTeam = await this.findActive(divisionTeamId, playerId);
    
    if (activeOnThisTeam) {
      // Update existing active period (jersey number might change)
      await this.db.query(`
        UPDATE division_team_players SET
          jersey_number = COALESCE($1, jersey_number)
        WHERE division_team_id = $2 AND player_id = $3 AND joined_at = $4
      `, [data.jerseyNumber, divisionTeamId, playerId, activeOnThisTeam.joined_at]);
      
      return { divisionTeamId, playerId, inserted: false, transferred: false };
    }
    
    // Check if player is active on ANY other team (transfer scenario)
    const anyActivePeriod = await this.db.query(`
      SELECT division_team_id, player_id, joined_at
      FROM division_team_players
      WHERE player_id = $1 AND left_at IS NULL
      LIMIT 1
    `, [playerId]);
    
    if (anyActivePeriod.rows.length > 0) {
      // Player transferring from another team - close old period
      await this.db.query(`
        UPDATE division_team_players 
        SET left_at = CURRENT_TIMESTAMP
        WHERE division_team_id = $1 AND player_id = $2 AND joined_at = $3
      `, [anyActivePeriod.rows[0].division_team_id, playerId, anyActivePeriod.rows[0].joined_at]);
    }
    
    // Create new active period
    const result = await this.db.query(`
      INSERT INTO division_team_players (division_team_id, player_id, jersey_number, joined_at)
      VALUES ($1, $2, $3, CURRENT_TIMESTAMP)
      RETURNING division_team_id, player_id, joined_at
    `, [divisionTeamId, playerId, data.jerseyNumber || null]);
    
    return { 
      divisionTeamId: result.rows[0].division_team_id,
      playerId: result.rows[0].player_id,
      joinedAt: result.rows[0].joined_at,
      inserted: true, 
      transferred: anyActivePeriod.rows.length > 0 
    };
  }
  
  /**
   * Get all CURRENT players for a division team (current roster)
   */
  async findByDivisionTeam(divisionTeamId, includeHistory = false) {
    const whereClause = includeHistory
      ? 'dtp.division_team_id = $1'
      : 'dtp.division_team_id = $1 AND dtp.left_at IS NULL';
    
    const result = await this.db.query(`
      SELECT 
        dtp.division_team_id,
        dtp.player_id,
        dtp.jersey_number,
        dtp.joined_at,
        dtp.left_at,
        p.first_name,
        p.last_name
      FROM division_team_players dtp
      JOIN players pl ON dtp.player_id = pl.id
      JOIN persons p ON pl.person_id = p.id
      WHERE ${whereClause}
      ORDER BY CASE WHEN dtp.left_at IS NULL THEN 0 ELSE 1 END, dtp.joined_at DESC, p.last_name, p.first_name
    `, [divisionTeamId]);
    
    return result.rows;
  }
}

module.exports = DivisionTeamPlayerRepository;

