/**
 * Conference Repository
 * 
 * Handles all database operations for conferences.
 * Fourth level in hierarchy - requires season_id FK.
 */
class ConferenceRepository {
  constructor(dbClient) {
    this.db = dbClient;
  }
  
  /**
   * Find conference by external_id (APSL's conference ID)
   */
  async findByExternalId(seasonId, externalId) {
    const result = await this.db.query(`
      SELECT id, name, season_id, external_id
      FROM conferences
      WHERE season_id = $1 AND external_id = $2
    `, [seasonId, externalId]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Find conference by name within a season
   */
  async findByName(seasonId, name) {
    const result = await this.db.query(`
      SELECT id, name, season_id, external_id
      FROM conferences
      WHERE season_id = $1 AND name = $2
    `, [seasonId, name]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Find all conferences for a season
   */
  async findBySeason(seasonId) {
    const result = await this.db.query(`
      SELECT id, name, season_id, external_id
      FROM conferences
      WHERE season_id = $1
      ORDER BY sort_order, name
    `, [seasonId]);
    
    return result.rows;
  }
  
  /**
   * Upsert conference using domain model
   */
  async upsert(conference) {
    const row = conference.toDbRow();
    
    // Upsert by name (unique constraint is on season_id + name)
    const result = await this.db.query(`
      INSERT INTO conferences (name, season_id, external_id)
      VALUES ($1, $2, $3)
      ON CONFLICT (season_id, name) DO UPDATE SET
        external_id = EXCLUDED.external_id
      RETURNING id, (xmax = 0) AS is_insert
    `, [row.name, row.season_id, row.external_id]);
    
    return {
      id: result.rows[0].id,
      inserted: result.rows[0].is_insert,
      updated: !result.rows[0].is_insert
    };
  }
  
  /**
   * Upsert many conferences (batch operation)
   */
  async upsertMany(conferences) {
    let totalInserted = 0;
    let totalUpdated = 0;
    
    for (const conference of conferences) {
      const result = await this.upsert(conference);
      
      if (result.inserted) totalInserted++;
      if (result.updated) totalUpdated++;
    }
    
    return { totalInserted, totalUpdated };
  }
}

module.exports = ConferenceRepository;
