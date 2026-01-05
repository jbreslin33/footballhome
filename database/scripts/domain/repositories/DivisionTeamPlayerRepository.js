/**
 * Division Team Player Repository
 * All database operations for roster assignments (division_team_players)
 */
class DivisionTeamPlayerRepository {
  constructor(db) {
    this.db = db;
  }
  
  /**
   * Find roster entry by division_team_id and player_id
   */
  async find(divisionTeamId, playerId) {
    const result = await this.db.query(`
      SELECT id, division_team_id, player_id, jersey_number, is_active, joined_at, left_at
      FROM division_team_players
      WHERE division_team_id = $1 AND player_id = $2
    `, [divisionTeamId, playerId]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Upsert roster entry (insert or update if exists)
   */
  async upsert(divisionTeamId, playerId, data = {}) {
    const existing = await this.find(divisionTeamId, playerId);
    
    if (existing) {
      // Update
      await this.db.query(`
        UPDATE division_team_players SET
          jersey_number = COALESCE($1, jersey_number),
          is_active = COALESCE($2, is_active),
          left_at = $3
        WHERE id = $4
      `, [
        data.jerseyNumber, 
        data.isActive !== undefined ? data.isActive : null,
        data.leftAt || null,
        existing.id
      ]);
      
      return { id: existing.id, inserted: false };
    }
    
    // Insert new
    const result = await this.db.query(`
      INSERT INTO division_team_players (division_team_id, player_id, jersey_number, is_active, joined_at)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING id
    `, [
      divisionTeamId, 
      playerId, 
      data.jerseyNumber || null, 
      data.isActive !== undefined ? data.isActive : true,
      data.joinedAt || null
    ]);
    
    return { id: result.rows[0].id, inserted: true };
  }
  
  /**
   * Get all players for a division team
   */
  async findByDivisionTeam(divisionTeamId) {
    const result = await this.db.query(`
      SELECT 
        dtp.id,
        dtp.division_team_id,
        dtp.player_id,
        dtp.jersey_number,
        dtp.is_active,
        dtp.joined_at,
        dtp.left_at,
        p.first_name,
        p.last_name
      FROM division_team_players dtp
      JOIN players pl ON dtp.player_id = pl.id
      JOIN persons p ON pl.person_id = p.id
      WHERE dtp.division_team_id = $1
      ORDER BY dtp.jersey_number, p.last_name, p.first_name
    `, [divisionTeamId]);
    
    return result.rows;
  }
}

module.exports = DivisionTeamPlayerRepository;
