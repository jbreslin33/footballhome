/**
 * ScrapedTeam Repository
 * All database operations for teams from external sources
 */
class ScrapedTeamRepository {
  constructor(db) {
    this.db = db;
  }
  
  /**
   * Find team by name
   */
  async findByName(name) {
    const result = await this.db.query(`
      SELECT id, name, club_id, city, logo_url, source_system_id, external_id
      FROM teams
      WHERE name = $1
    `, [name]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Find team by external ID and source system
   */
  async findByExternalId(sourceSystemId, externalId) {
    const result = await this.db.query(`
      SELECT id, name, club_id, city, logo_url, source_system_id, external_id
      FROM teams
      WHERE source_system_id = $1 AND external_id = $2
    `, [sourceSystemId, externalId]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Upsert team (insert or update if name/external_id exists)
   */
  async upsert(team) {
    const row = team.toDbRow();
    
    // Try to find existing by external_id first (most reliable)
    if (row.external_id && row.source_system_id) {
      const existing = await this.findByExternalId(row.source_system_id, row.external_id);
      
      if (existing) {
        const result = await this.db.query(`
          UPDATE teams SET
            name = $1,
            club_id = $2,
            city = $3,
            logo_url = $4
          WHERE id = $5
          RETURNING id
        `, [row.name, row.club_id, row.city, row.logo_url, existing.id]);
        
        return { id: result.rows[0].id, inserted: false };
      }
    }
    
    // Try to find by name (fallback for teams without external_id)
    const existingByName = await this.findByName(row.name);
    if (existingByName) {
      const result = await this.db.query(`
        UPDATE teams SET
          club_id = $1,
          city = $2,
          logo_url = $3,
          source_system_id = $4,
          external_id = $5
        WHERE id = $6
        RETURNING id
      `, [
        row.club_id, row.city, row.logo_url, 
        row.source_system_id, row.external_id,
        existingByName.id
      ]);
      
      return { id: result.rows[0].id, inserted: false };
    }
    
    // Insert new
    const result = await this.db.query(`
      INSERT INTO teams (name, club_id, city, logo_url, source_system_id, external_id)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id
    `, [row.name, row.club_id, row.city, row.logo_url, row.source_system_id, row.external_id]);
    
    return { id: result.rows[0].id, inserted: true };
  }
  
  /**
   * Find all teams by source system
   */
  async findBySourceSystem(sourceSystemId) {
    const result = await this.db.query(`
      SELECT id, name, club_id, city, logo_url, source_system_id, external_id
      FROM teams
      WHERE source_system_id = $1
    `, [sourceSystemId]);
    
    return result.rows;
  }
  
  /**
   * Upsert many teams (batch operation)
   */
  async upsertMany(teams) {
    let totalInserted = 0;
    let totalUpdated = 0;
    
    for (const team of teams) {
      const result = await this.upsert(team);
      if (result.inserted) {
        totalInserted++;
      } else {
        totalUpdated++;
      }
    }
    
    return { inserted: totalInserted, updated: totalUpdated };
  }
}

module.exports = ScrapedTeamRepository;
