/**
 * Organization Repository
 * 
 * Handles all database operations for organizations.
 * Root of the soccer hierarchy.
 */
class OrganizationRepository {
  constructor(dbClient) {
    this.db = dbClient;
  }
  
  /**
   * Find organization by name
   */
  async findByName(name) {
    const result = await this.db.query(`
      SELECT id, name, short_name, website_url, is_active
      FROM organizations
      WHERE name = $1
    `, [name]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Find or create organization by name
   * Returns the organization ID
   */
  async findOrCreateByName(name) {
    // Try to find existing
    const existing = await this.db.query(`
      SELECT id FROM organizations
      WHERE name = $1
    `, [name]);
    
    if (existing.rows.length > 0) {
      return existing.rows[0].id;
    }
    
    // Create new
    const result = await this.db.query(`
      INSERT INTO organizations (name)
      VALUES ($1)
      RETURNING id
    `, [name]);
    
    return result.rows[0].id;
  }
  
  /**
   * Upsert organization using domain model
   */
  async upsert(organization) {
    const row = organization.toDbRow();
    
    const result = await this.db.query(`
      INSERT INTO organizations (name, short_name, website_url, is_active)
      VALUES ($1, $2, $3, $4)
      ON CONFLICT (name) DO UPDATE SET
        short_name = EXCLUDED.short_name,
        website_url = EXCLUDED.website_url,
        is_active = EXCLUDED.is_active
      RETURNING id, (xmax = 0) AS is_insert
    `, [row.name, row.short_name, row.website_url, row.is_active]);
    
    return {
      id: result.rows[0].id,
      inserted: result.rows[0].is_insert,
      updated: !result.rows[0].is_insert
    };
  }
}

module.exports = OrganizationRepository;
