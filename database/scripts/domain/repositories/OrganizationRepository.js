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
   * Find organization by slug
   */
  async findBySlug(slug) {
    const result = await this.db.query(`
      SELECT id, name, display_name, slug, website, is_active
      FROM organizations
      WHERE slug = $1
    `, [slug]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Find or create organization by name
   * Returns the organization ID
   */
  async findOrCreateByName(name, slug = null) {
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
      INSERT INTO organizations (name, slug)
      VALUES ($1, $2)
      RETURNING id
    `, [name, slug || name.toLowerCase().replace(/\s+/g, '-')]);
    
    return result.rows[0].id;
  }
  
  /**
   * Upsert organization using domain model
   */
  async upsert(organization) {
    const row = organization.toDbRow();
    
    const result = await this.db.query(`
      INSERT INTO organizations (name, display_name, slug, website, is_active)
      VALUES ($1, $2, $3, $4, $5)
      ON CONFLICT (slug) DO UPDATE SET
        name = EXCLUDED.name,
        display_name = EXCLUDED.display_name,
        website = EXCLUDED.website,
        is_active = EXCLUDED.is_active
      RETURNING id, (xmax = 0) AS is_insert
    `, [row.name, row.display_name, row.slug, row.website, row.is_active]);
    
    return {
      id: result.rows[0].id,
      inserted: result.rows[0].is_insert,
      updated: !result.rows[0].is_insert
    };
  }
}

module.exports = OrganizationRepository;
