/**
 * Country Repository
 * 
 * Handles all database operations for countries.
 * Uses Country domain models.
 */
class CountryRepository {
  constructor(dbClient) {
    this.db = dbClient;
  }
  
  /**
   * Upsert a single country
   * Returns { inserted: boolean, updated: boolean }
   */
  async upsert(country, continentId) {
    const row = country.toDbRow(continentId);
    
    const result = await this.db.query(`
      INSERT INTO countries (code, name, fifa_code, continent_id, is_active)
      VALUES ($1, $2, $3, $4, $5)
      ON CONFLICT (code) DO UPDATE SET
        name = EXCLUDED.name,
        fifa_code = EXCLUDED.fifa_code,
        continent_id = EXCLUDED.continent_id,
        is_active = EXCLUDED.is_active
      RETURNING (xmax = 0) AS is_insert
    `, [row.code, row.name, row.fifa_code, row.continent_id, row.is_active]);
    
    const isInsert = result.rows[0].is_insert;
    return { inserted: isInsert, updated: !isInsert };
  }
  
  /**
   * Upsert many countries (batch operation)
   * Returns { totalInserted, totalUpdated }
   */
  async upsertMany(countries, continentMap) {
    let totalInserted = 0;
    let totalUpdated = 0;
    
    for (const country of countries) {
      const continentId = country.continentCode ? continentMap[country.continentCode] : null;
      const result = await this.upsert(country, continentId);
      
      if (result.inserted) totalInserted++;
      if (result.updated) totalUpdated++;
    }
    
    return { totalInserted, totalUpdated };
  }
  
  /**
   * Find country by code
   */
  async findByCode(code) {
    const result = await this.db.query(`
      SELECT c.code, c.name, c.fifa_code, c.continent_id, con.code as continent_code
      FROM countries c
      LEFT JOIN continents con ON c.continent_id = con.id
      WHERE c.code = $1
    `, [code]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Count countries by continent
   */
  async countByContinent() {
    const result = await this.db.query(`
      SELECT con.name as continent, COUNT(c.id) as count
      FROM continents con
      LEFT JOIN countries c ON c.continent_id = con.id
      GROUP BY con.id, con.name
      ORDER BY con.sort_order
    `);
    
    return result.rows;
  }
}

module.exports = CountryRepository;
