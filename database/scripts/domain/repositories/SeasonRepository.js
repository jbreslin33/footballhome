/**
 * Season Repository
 * 
 * Handles all database operations for seasons.
 * Third level in hierarchy - requires league_id FK.
 */
class SeasonRepository {
  constructor(dbClient) {
    this.db = dbClient;
  }
  
  /**
   * Find season by name within a league
   */
  async findByName(leagueId, name) {
    const result = await this.db.query(`
      SELECT id, name, league_id, start_date, end_date, is_active
      FROM seasons
      WHERE league_id = $1 AND name = $2
    `, [leagueId, name]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Find or create season by name within a league
   * Returns the season ID
   */
  async findOrCreateByName(leagueId, name) {
    // Try to find existing
    const existing = await this.findByName(leagueId, name);
    
    if (existing) {
      return existing.id;
    }
    
    // Create new
    const result = await this.db.query(`
      INSERT INTO seasons (league_id, name)
      VALUES ($1, $2)
      RETURNING id
    `, [leagueId, name]);
    
    return result.rows[0].id;
  }
  
  /**
   * Upsert season using domain model
   */
  async upsert(season) {
    const row = season.toDbRow();
    
    const result = await this.db.query(`
      INSERT INTO seasons (name, league_id, start_date, end_date, is_active)
      VALUES ($1, $2, $3, $4, $5)
      ON CONFLICT (league_id, name) DO UPDATE SET
        start_date = EXCLUDED.start_date,
        end_date = EXCLUDED.end_date,
        is_active = EXCLUDED.is_active
      RETURNING id, (xmax = 0) AS is_insert
    `, [row.name, row.league_id, row.start_date, row.end_date, row.is_active]);
    
    return {
      id: result.rows[0].id,
      inserted: result.rows[0].is_insert,
      updated: !result.rows[0].is_insert
    };
  }
}

module.exports = SeasonRepository;
