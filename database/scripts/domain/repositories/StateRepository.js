/**
 * State Repository
 * 
 * Handles all database operations for states/provinces.
 */
class StateRepository {
  constructor(dbClient) {
    this.db = dbClient;
  }
  
  /**
   * Find state by code and country
   */
  async findByCode(countryId, code) {
    const result = await this.db.query(`
      SELECT id, country_id, code, name, is_active
      FROM states
      WHERE country_id = $1 AND code = $2
    `, [countryId, code]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Upsert a single state
   */
  async upsert(state) {
    const row = state.toDbRow();
    
    const result = await this.db.query(`
      INSERT INTO states (country_id, code, name, is_active)
      VALUES ($1, $2, $3, $4)
      ON CONFLICT (country_id, code) DO UPDATE SET
        name = EXCLUDED.name,
        is_active = EXCLUDED.is_active
      RETURNING id, (xmax = 0) AS is_insert
    `, [row.country_id, row.code, row.name, row.is_active]);
    
    return {
      id: result.rows[0].id,
      inserted: result.rows[0].is_insert,
      updated: !result.rows[0].is_insert
    };
  }
  
  /**
   * Upsert many states (batch operation)
   */
  async upsertMany(states) {
    let totalInserted = 0;
    let totalUpdated = 0;
    
    for (const state of states) {
      const result = await this.upsert(state);
      
      if (result.inserted) totalInserted++;
      if (result.updated) totalUpdated++;
    }
    
    return { totalInserted, totalUpdated };
  }
  
  /**
   * Get all states for a country
   */
  async findByCountry(countryId) {
    const result = await this.db.query(`
      SELECT id, country_id, code, name, is_active
      FROM states
      WHERE country_id = $1
      ORDER BY name
    `, [countryId]);
    
    return result.rows;
  }
}

module.exports = StateRepository;
