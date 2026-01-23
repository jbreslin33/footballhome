/**
 * DivisionTeam Repository
 * 
 * Handles database operations for the division_teams junction table.
 * Links teams to divisions (seasonal team registrations).
 */
class DivisionTeamRepository {
  constructor(dbClient) {
    this.db = dbClient;
  }
  
  /**
   * Find division_team by composite key (current registration only)
   */
  async findByDivisionAndTeam(divisionId, teamId) {
    const result = await this.db.query(`
      SELECT id, division_id, team_id, registered_at, unregistered_at
      FROM division_teams
      WHERE division_id = $1 AND team_id = $2
        AND unregistered_at IS NULL
    `, [divisionId, teamId]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Find all teams in a division (current registrations only)
   */
  async findByDivision(divisionId) {
    const result = await this.db.query(`
      SELECT dt.id, dt.division_id, dt.team_id,
             dt.registered_at, dt.unregistered_at,
             t.name as team_name
      FROM division_teams dt
      JOIN teams t ON dt.team_id = t.id
      WHERE dt.division_id = $1
        AND dt.unregistered_at IS NULL
      ORDER BY t.name
    `, [divisionId]);
    
    return result.rows;
  }
  
  /**
   * Find all divisions a team is in (all history)
   */
  async findByTeam(teamId) {
    const result = await this.db.query(`
      SELECT dt.id, dt.division_id, dt.team_id, 
             dt.registered_at, dt.unregistered_at,
             d.name as division_name, d.season_id
      FROM division_teams dt
      JOIN divisions d ON dt.division_id = d.id
      WHERE dt.team_id = $1
      ORDER BY d.season_id DESC, dt.registered_at DESC
    `, [teamId]);
    
    return result.rows;
  }
  
  /**
   * Find active (current) divisions for a team
   */
  async findActiveByTeam(teamId) {
    const result = await this.db.query(`
      SELECT dt.id, dt.division_id, dt.team_id,
             dt.registered_at, dt.unregistered_at,
             d.name as division_name, d.season_id
      FROM division_teams dt
      JOIN divisions d ON dt.division_id = d.id
      WHERE dt.team_id = $1
        AND dt.unregistered_at IS NULL
      ORDER BY d.season_id DESC, d.name
    `, [teamId]);
    
    return result.rows;
  }
  
  /**
   * Register team in division (temporal pattern)
   * If already registered, returns existing active registration
   * @param {number} divisionId
   * @param {number} teamId
   */
  async register(divisionId, teamId) {
    // Check if already registered (unregistered_at IS NULL)
    const existing = await this.db.query(`
      SELECT id, division_id, team_id, registered_at, unregistered_at
      FROM division_teams
      WHERE division_id = $1 AND team_id = $2
        AND unregistered_at IS NULL
    `, [divisionId, teamId]);
    
    if (existing.rows.length > 0) {
      return existing.rows[0]; // Already registered
    }
    
    // Insert new registration
    const result = await this.db.query(`
      INSERT INTO division_teams (division_id, team_id, registered_at)
      VALUES ($1, $2, CURRENT_TIMESTAMP)
      RETURNING id, division_id, team_id, registered_at, unregistered_at
    `, [divisionId, teamId]);
    
    return result.rows[0];
  }
  
  /**
   * Unregister team from division (close the temporal period)
   */
  async unregister(divisionId, teamId) {
    const result = await this.db.query(`
      UPDATE division_teams
      SET unregistered_at = CURRENT_TIMESTAMP
      WHERE division_id = $1 AND team_id = $2
        AND unregistered_at IS NULL
      RETURNING id, division_id, team_id, registered_at, unregistered_at
    `, [divisionId, teamId]);
    
    return result.rows[0] || null;
  }
}

module.exports = DivisionTeamRepository;
