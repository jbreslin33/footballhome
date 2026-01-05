/**
 * Club Repository
 * All database operations for clubs
 */
class ClubRepository {
  constructor(db) {
    this.db = db;
  }
  
  /**
   * Find club by name and organization
   */
  async findByName(organizationId, name) {
    const result = await this.db.query(`
      SELECT id, organization_id, name, sport_id, logo_url, website, is_active
      FROM clubs
      WHERE organization_id = $1 AND name = $2
    `, [organizationId, name]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Upsert club (insert or update if exists)
   */
  async upsert(club) {
    const existing = await this.findByName(club.organizationId, club.name);
    
    if (existing) {
      const result = await this.db.query(`
        UPDATE clubs SET
          sport_id = $1,
          logo_url = $2,
          website = $3,
          is_active = $4
        WHERE id = $5
        RETURNING id
      `, [club.sportId, club.logoUrl, club.website, club.isActive, existing.id]);
      
      return { id: result.rows[0].id, inserted: false };
    }
    
    // Insert new
    const result = await this.db.query(`
      INSERT INTO clubs (organization_id, name, sport_id, logo_url, website, is_active)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id
    `, [club.organizationId, club.name, club.sportId, club.logoUrl, club.website, club.isActive]);
    
    return { id: result.rows[0].id, inserted: true };
  }
}

module.exports = ClubRepository;
