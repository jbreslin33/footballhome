/**
 * League Repository
 * 
 * Handles all database operations for leagues.
 * Second level in hierarchy - requires organization_id FK.
 */
class LeagueRepository {
  constructor(dbClient) {
    this.db = dbClient;
  }
  
  /**
   * Find league by name within an organization
   */
  async findByName(organizationId, name) {
    const result = await this.db.query(`
      SELECT id, name, organization_id, external_id, is_active
      FROM leagues
      WHERE organization_id = $1 AND name = $2
    `, [organizationId, name]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Find or create league by name within an organization
   * Returns the league ID
   */
  async findOrCreateByName(organizationId, name) {
    // Try to find existing
    const existing = await this.findByName(organizationId, name);
    
    if (existing) {
      return existing.id;
    }
    
    // Create new
    const result = await this.db.query(`
      INSERT INTO leagues (organization_id, name)
      VALUES ($1, $2)
      RETURNING id
    `, [organizationId, name]);
    
    return result.rows[0].id;
  }
  
  /**
   * Upsert league using domain model
   */
  async upsert(league) {
    const row = league.toDbRow();
    
    const result = await this.db.query(`
      INSERT INTO leagues (name, organization_id, external_id, is_active)
      VALUES ($1, $2, $3, $4)
      ON CONFLICT (organization_id, name) DO UPDATE SET
        external_id = EXCLUDED.external_id,
        is_active = EXCLUDED.is_active
      RETURNING id, (xmax = 0) AS is_insert
    `, [row.name, row.organization_id, row.external_id, row.is_active]);
    
    return {
      id: result.rows[0].id,
      inserted: result.rows[0].is_insert,
      updated: !result.rows[0].is_insert
    };
  }
}

module.exports = LeagueRepository;
