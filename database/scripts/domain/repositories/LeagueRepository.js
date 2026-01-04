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
   * Find league by slug within an organization
   */
  async findBySlug(organizationId, slug) {
    const result = await this.db.query(`
      SELECT id, name, display_name, organization_id, slug, is_active
      FROM leagues
      WHERE organization_id = $1 AND slug = $2
    `, [organizationId, slug]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Find or create league by name within an organization
   * Returns the league ID
   */
  async findOrCreateByName(organizationId, name, slug = null) {
    // Try to find existing
    const existing = await this.db.query(`
      SELECT id FROM leagues
      WHERE organization_id = $1 AND name = $2
    `, [organizationId, name]);
    
    if (existing.rows.length > 0) {
      return existing.rows[0].id;
    }
    
    // Create new
    const result = await this.db.query(`
      INSERT INTO leagues (organization_id, name, slug)
      VALUES ($1, $2, $3)
      RETURNING id
    `, [organizationId, name, slug || name.toLowerCase().replace(/\s+/g, '-')]);
    
    return result.rows[0].id;
  }
  
  /**
   * Upsert league using domain model
   */
  async upsert(league) {
    const row = league.toDbRow();
    
    const result = await this.db.query(`
      INSERT INTO leagues (name, display_name, organization_id, slug, is_active)
      VALUES ($1, $2, $3, $4, $5)
      ON CONFLICT (organization_id, slug) DO UPDATE SET
        name = EXCLUDED.name,
        display_name = EXCLUDED.display_name,
        is_active = EXCLUDED.is_active
      RETURNING id, (xmax = 0) AS is_insert
    `, [row.name, row.display_name, row.organization_id, row.slug, row.is_active]);
    
    return {
      id: result.rows[0].id,
      inserted: result.rows[0].is_insert,
      updated: !result.rows[0].is_insert
    };
  }
}

module.exports = LeagueRepository;
