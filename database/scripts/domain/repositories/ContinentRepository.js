/**
 * Continent Repository
 * 
 * Handles all database operations for continents.
 * Returns domain objects, abstracts DB implementation.
 */
class ContinentRepository {
  constructor(dbClient) {
    this.db = dbClient;
  }
  
  /**
   * Get all continents as a map: { code → id }
   * Used by parsers to resolve continent codes to IDs
   */
  async getContinentMap() {
    const result = await this.db.query(`
      SELECT id, code FROM continents
    `);
    
    const map = {};
    for (const row of result.rows) {
      map[row.code] = row.id;
    }
    
    return map;
  }
  
  /**
   * Find continent by code
   */
  async findByCode(code) {
    const result = await this.db.query(`
      SELECT id, code, name FROM continents
      WHERE code = $1
    `, [code]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Get all continents
   */
  async findAll() {
    const result = await this.db.query(`
      SELECT id, code, name, sort_order
      FROM continents
      ORDER BY sort_order
    `);
    
    return result.rows;
  }
}

module.exports = ContinentRepository;
