/**
 * Scrape Target Service
 * 
 * Manages scrape_targets table:
 * - Query targets by type
 * - Track initialization state
 * - Update sync timestamps
 */
class ScrapeTargetService {
  constructor(dbClient) {
    this.db = dbClient;
  }
  
  /**
   * Get scrape target by source system and target type
   * @param {number} sourceSystemId - Source system ID
   * @param {number} targetTypeId - Target type ID
   * @returns {Promise<Object|null>} Scrape target or null
   */
  async getTarget(sourceSystemId, targetTypeId) {
    const result = await this.db.query(`
      SELECT id, url, is_initialized, last_synced_at, label
      FROM scrape_targets
      WHERE source_system_id = $1
        AND target_type_id = $2
        AND is_active = true
    `, [sourceSystemId, targetTypeId]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Get or create scrape target
   * @param {Object} params - Target parameters
   * @returns {Promise<Object>} Scrape target
   */
  async getOrCreate({ sourceSystemId, scraperTypeId, targetTypeId, url, label }) {
    // Try to find existing
    let target = await this.getTarget(sourceSystemId, targetTypeId);
    
    if (target) {
      return target;
    }
    
    // Create new
    const result = await this.db.query(`
      INSERT INTO scrape_targets (source_system_id, scraper_type_id, target_type_id, url, label)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING id, url, is_initialized, last_synced_at, label
    `, [sourceSystemId, scraperTypeId, targetTypeId, url, label]);
    
    return result.rows[0];
  }
  
  /**
   * Mark target as initialized after first scrape
   */
  async markInitialized(targetId) {
    await this.db.query(`
      UPDATE scrape_targets
      SET is_initialized = true,
          last_synced_at = NOW(),
          updated_at = NOW()
      WHERE id = $1
    `, [targetId]);
  }
  
  /**
   * Update sync timestamp after subsequent scrapes
   */
  async updateSyncTime(targetId) {
    await this.db.query(`
      UPDATE scrape_targets
      SET last_synced_at = NOW(),
          updated_at = NOW()
      WHERE id = $1
    `, [targetId]);
  }
  
  /**
   * Check if target needs initialization
   */
  async needsInitialization(targetId) {
    const result = await this.db.query(`
      SELECT is_initialized FROM scrape_targets WHERE id = $1
    `, [targetId]);
    
    return result.rows[0] && !result.rows[0].is_initialized;
  }
}

module.exports = ScrapeTargetService;
