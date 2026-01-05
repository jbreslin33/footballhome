/**
 * DivisionTeam Repository
 * 
 * Handles database operations for the division_teams junction table.
 * Links teams to divisions (roster assignments).
 */
class DivisionTeamRepository {
  constructor(dbClient) {
    this.db = dbClient;
  }
  
  /**
   * Find division_team by composite key
   */
  async findByDivisionAndTeam(divisionId, teamId) {
    const result = await this.db.query(`
      SELECT division_id, team_id, reserve_of_team_id, is_active
      FROM division_teams
      WHERE division_id = $1 AND team_id = $2
    `, [divisionId, teamId]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Find all teams in a division
   */
  async findByDivision(divisionId) {
    const result = await this.db.query(`
      SELECT dt.division_id, dt.team_id, dt.reserve_of_team_id, dt.is_active,
             t.display_name, t.short_name
      FROM division_teams dt
      JOIN teams t ON dt.team_id = t.id
      WHERE dt.division_id = $1
      ORDER BY t.display_name
    `, [divisionId]);
    
    return result.rows;
  }
  
  /**
   * Find all divisions a team is in
   */
  async findByTeam(teamId) {
    const result = await this.db.query(`
      SELECT dt.division_id, dt.team_id, dt.reserve_of_team_id, dt.is_active,
             d.name as division_name, d.season_id
      FROM division_teams dt
      JOIN divisions d ON dt.division_id = d.id
      WHERE dt.team_id = $1
      ORDER BY d.season_id DESC, d.name
    `, [teamId]);
    
    return result.rows;
  }
  
  /**
   * Upsert division_team link
   * @param {number} divisionId
   * @param {number} teamId
   * @param {number|null} reserveOfTeamId - Optional: if this team is a reserve team
   * @param {boolean} isActive - Default: true
   */
  async upsert(divisionId, teamId, reserveOfTeamId = null, isActive = true) {
    const result = await this.db.query(`
      INSERT INTO division_teams (division_id, team_id, reserve_of_team_id, is_active)
      VALUES ($1, $2, $3, $4)
      ON CONFLICT (division_id, team_id)
      DO UPDATE SET
        reserve_of_team_id = EXCLUDED.reserve_of_team_id,
        is_active = EXCLUDED.is_active
      RETURNING division_id, team_id, reserve_of_team_id, is_active
    `, [divisionId, teamId, reserveOfTeamId, isActive]);
    
    return result.rows[0];
  }
  
  /**
   * Remove a team from a division
   */
  async delete(divisionId, teamId) {
    const result = await this.db.query(`
      DELETE FROM division_teams
      WHERE division_id = $1 AND team_id = $2
      RETURNING division_id, team_id
    `, [divisionId, teamId]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Mark a team as inactive in a division (soft delete)
   */
  async markInactive(divisionId, teamId) {
    const result = await this.db.query(`
      UPDATE division_teams
      SET is_active = false
      WHERE division_id = $1 AND team_id = $2
      RETURNING division_id, team_id, is_active
    `, [divisionId, teamId]);
    
    return result.rows[0] || null;
  }
}

module.exports = DivisionTeamRepository;
